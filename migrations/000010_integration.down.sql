-- =============================================================================
-- OSMI DATABASE
-- Rollback 000010 — Integration Schema
-- =============================================================================

-- 1. Triggers
DROP TRIGGER IF EXISTS trg_update_webhooks ON integration.webhooks;

-- 2. Tablas
DROP TABLE IF EXISTS integration.api_calls CASCADE;
DROP TABLE IF EXISTS integration.webhooks CASCADE;

-- 3. Sequences
DROP SEQUENCE IF EXISTS integration.api_calls_id_seq;
DROP SEQUENCE IF EXISTS integration.webhooks_id_seq;

-- =============================================================================
-- FIN DEL ROLLBACK 000010
-- =============================================================================