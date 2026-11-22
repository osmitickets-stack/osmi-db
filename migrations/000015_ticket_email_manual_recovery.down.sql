-- Refuse rollback once a sixth attempt exists or has been authorized.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM notifications.ticket_email_jobs
        WHERE max_attempts <> 5 OR attempts > 5
    ) OR EXISTS (
        SELECT 1 FROM notifications.ticket_email_attempts
        WHERE attempt_number > 5
    ) THEN
        RAISE EXCEPTION 'ticket email manual recovery must be reconciled before rollback';
    END IF;
END $$;

ALTER TABLE notifications.ticket_email_attempts
    DROP CONSTRAINT ticket_email_attempts_attempt_number_check,
    ADD CONSTRAINT ticket_email_attempts_attempt_number_check
        CHECK (attempt_number BETWEEN 1 AND 5);

ALTER TABLE notifications.ticket_email_jobs
    DROP CONSTRAINT ticket_email_jobs_attempts_check,
    DROP COLUMN max_attempts,
    ADD CONSTRAINT ticket_email_jobs_attempts_check
        CHECK (attempts >= 0 AND attempts <= 5);
