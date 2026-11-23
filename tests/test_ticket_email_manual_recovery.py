"""Exercise migrations 14 and 15 against a disposable local Docker database.

Run explicitly with Python; never targets a remote Docker context or production DB.
"""

import json
import subprocess
import sys
import tempfile
import time
import uuid
from pathlib import Path
from types import SimpleNamespace


ROOT = Path(__file__).resolve().parents[1]
CONTAINER = f"osmi-email-recovery15-{uuid.uuid4().hex[:10]}"


def run(*args, input_text=None, check=True):
    # Docker CLI on Windows may leave captured pipe handles open. Temporary
    # files avoid an indefinite communicate()/reader-thread join.
    with tempfile.TemporaryFile(mode="w+t", encoding="utf-8") as out, \
            tempfile.TemporaryFile(mode="w+t", encoding="utf-8") as err:
        process = subprocess.run(
            args, input=input_text, text=True, stdout=out, stderr=err, timeout=30
        )
        out.seek(0)
        err.seek(0)
        result = SimpleNamespace(returncode=process.returncode, stdout=out.read(), stderr=err.read())
    if check and result.returncode:
        raise RuntimeError(f"command failed: {args[0]} {args[1]}")
    return result


def sql(statement, *, database="osmidb_test", expect_failure=False):
    result = run(
        "docker", "exec", "-i", CONTAINER, "psql", "-X", "-w", "-v",
        "ON_ERROR_STOP=1", "-U", "postgres", "-d", database, "-At",
        input_text=statement, check=False,
    )
    if (result.returncode == 0) == expect_failure:
        raise AssertionError("SQL outcome differs from expectation")
    return result.stdout.strip()


def main():
    context = run("docker", "context", "inspect", "--format", "{{json .Endpoints.docker.Host}}")
    endpoint = json.loads(context.stdout.strip())
    system = run("docker", "info", "--format", "{{.OperatingSystem}}")
    if not endpoint.startswith("npipe://") or "Docker Desktop" not in system.stdout:
        raise RuntimeError("local Docker Desktop context required")
    if run("docker", "image", "inspect", "postgres:16-alpine", check=False).returncode:
        raise RuntimeError("POSTGRES_IMAGE_MISSING")
    print("LOCAL_DOCKER_PREFLIGHT_PASS", flush=True)

    created = False
    try:
        created = True
        run(
            "docker", "run", "--rm", "--pull", "never", "-d", "--name", CONTAINER,
            "-e", "POSTGRES_PASSWORD=local-test-only",
            "-e", "POSTGRES_HOST_AUTH_METHOD=trust",
            "postgres:16-alpine",
        )
        print("LOCAL_POSTGRES_STARTED", flush=True)
        for _ in range(30):
            ready = run("docker", "exec", CONTAINER, "pg_isready", "-U", "postgres", check=False)
            if ready.returncode == 0:
                break
            time.sleep(1)
        else:
            raise RuntimeError("local database did not become ready")
        print("LOCAL_POSTGRES_READY", flush=True)

        sql("CREATE DATABASE osmidb_test;", database="postgres")
        sql("CREATE SCHEMA billing; CREATE SCHEMA notifications; "
            "CREATE TABLE billing.orders(id bigint PRIMARY KEY);")
        sql((ROOT / "migrations/000014_ticket_email_outbox.up.sql").read_text(encoding="utf-8"))
        sql("INSERT INTO billing.orders VALUES (1),(2),(3); "
            "INSERT INTO notifications.ticket_email_jobs(order_id,status,attempts) "
            "VALUES (1,'exhausted',5),(2,'exhausted',5);")
        sql("INSERT INTO notifications.ticket_email_attempts(job_id,attempt_number,status) "
            "SELECT 1,n,'transport_failed' FROM generate_series(1,5) AS n;")
        sql((ROOT / "migrations/000015_ticket_email_manual_recovery.up.sql").read_text(encoding="utf-8"))
        print("MIGRATION15_UP_PASS")

        baseline = sql("SELECT string_agg(order_id||':'||max_attempts,',' ORDER BY order_id) "
                       "FROM notifications.ticket_email_jobs;")
        assert baseline == "1:5,2:5", baseline
        sql("INSERT INTO notifications.ticket_email_jobs(order_id) VALUES (3);")
        assert sql("SELECT max_attempts FROM notifications.ticket_email_jobs WHERE order_id=3;") == "5"
        sql("UPDATE notifications.ticket_email_jobs SET attempts=6 WHERE order_id=2;", expect_failure=True)
        print("NORMAL_FIVE_LIMIT_PASS")

        sql("UPDATE notifications.ticket_email_jobs SET max_attempts=6,status='retrying', "
            "next_attempt_at=NOW() WHERE order_id=1 AND status='exhausted' "
            "AND attempts=5 AND max_attempts=5;")
        claimable = sql("SELECT order_id FROM notifications.ticket_email_jobs "
                        "WHERE attempts<max_attempts AND status='retrying' "
                        "AND next_attempt_at<=NOW();")
        assert claimable == "1", claimable
        sql("UPDATE notifications.ticket_email_jobs SET attempts=6,status='sending' WHERE order_id=1; "
            "INSERT INTO notifications.ticket_email_attempts(job_id,attempt_number) VALUES (1,6);")
        assert sql("SELECT count(*) FROM notifications.ticket_email_attempts WHERE job_id=1;") == "6"
        assert sql("SELECT count(*) FROM notifications.ticket_email_attempts "
                   "WHERE job_id=1 AND attempt_number<=5 AND status='transport_failed';") == "5"
        sql("INSERT INTO notifications.ticket_email_attempts(job_id,attempt_number) VALUES (1,7);", expect_failure=True)
        sql((ROOT / "migrations/000015_ticket_email_manual_recovery.down.sql").read_text(encoding="utf-8"),
            expect_failure=True)
        assert sql("SELECT max_attempts FROM notifications.ticket_email_jobs WHERE order_id=1;") == "6"
        print("SIXTH_ATTEMPT_AUDIT_AND_ROLLBACK_GUARD_PASS")
    finally:
        if created:
            run("docker", "stop", CONTAINER, check=False)


if __name__ == "__main__":
    try:
        main()
    except (AssertionError, RuntimeError, OSError, subprocess.TimeoutExpired) as exc:
        marker = str(exc) if str(exc) == "POSTGRES_IMAGE_MISSING" else "MIGRATION15_LOCAL_TEST_FAIL"
        print(marker, file=sys.stderr)
        sys.exit(1)
