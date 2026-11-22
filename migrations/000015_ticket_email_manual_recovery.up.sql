-- Normal jobs keep five attempts. A single exhausted job can be authorized for
-- one additional attempt without deleting its prior attempts or changing the
-- retry limit for any other order.
ALTER TABLE notifications.ticket_email_jobs
    ADD COLUMN max_attempts integer NOT NULL DEFAULT 5
    CHECK (max_attempts IN (5, 6));

ALTER TABLE notifications.ticket_email_jobs
    DROP CONSTRAINT ticket_email_jobs_attempts_check,
    ADD CONSTRAINT ticket_email_jobs_attempts_check
        CHECK (attempts >= 0 AND attempts <= max_attempts);

ALTER TABLE notifications.ticket_email_attempts
    DROP CONSTRAINT ticket_email_attempts_attempt_number_check,
    ADD CONSTRAINT ticket_email_attempts_attempt_number_check
        CHECK (attempt_number BETWEEN 1 AND 6);
