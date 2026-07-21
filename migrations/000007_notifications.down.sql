-- =============================================================================
-- OSMI DATABASE
-- Rollback 000007 — Notifications Schema
-- =============================================================================

-- 1. Triggers
DROP TRIGGER IF EXISTS trg_update_messages ON notifications.messages;
DROP TRIGGER IF EXISTS trg_update_templates ON notifications.templates;

-- 2. Indexes
DROP INDEX IF EXISTS notifications.idx_messages_next_retry_at;
DROP INDEX IF EXISTS notifications.idx_messages_scheduled_for;
DROP INDEX IF EXISTS notifications.idx_messages_recipient_email;
DROP INDEX IF EXISTS notifications.idx_messages_status;

-- 3. Tablas
DROP TABLE IF EXISTS notifications.messages CASCADE;
DROP TABLE IF EXISTS notifications.templates CASCADE;

-- 4. Sequences
DROP SEQUENCE IF EXISTS notifications.messages_id_seq;
DROP SEQUENCE IF EXISTS notifications.templates_id_seq;

-- =============================================================================
-- FIN DEL ROLLBACK 000007
-- =============================================================================