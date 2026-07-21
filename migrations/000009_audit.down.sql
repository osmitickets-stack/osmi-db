-- =============================================================================
-- OSMI DATABASE
-- Rollback 000009 — Audit Schema
-- =============================================================================

-- 1. Indexes
DROP INDEX IF EXISTS audit.idx_stripe_events_created;
DROP INDEX IF EXISTS audit.idx_stripe_events_type;
DROP INDEX IF EXISTS audit.idx_stripe_events_event_id;
DROP INDEX IF EXISTS audit.idx_security_logs_severity;
DROP INDEX IF EXISTS audit.idx_data_changes_changed_at;
DROP INDEX IF EXISTS audit.idx_data_changes_table_record;

-- 2. Tablas
DROP TABLE IF EXISTS audit.stripe_events CASCADE;
DROP TABLE IF EXISTS audit.security_logs CASCADE;
DROP TABLE IF EXISTS audit.data_changes CASCADE;

-- 3. Sequences
DROP SEQUENCE IF EXISTS audit.stripe_events_id_seq;
DROP SEQUENCE IF EXISTS audit.security_logs_id_seq;
DROP SEQUENCE IF EXISTS audit.data_changes_id_seq;

-- =============================================================================
-- FIN DEL ROLLBACK 000009
-- =============================================================================