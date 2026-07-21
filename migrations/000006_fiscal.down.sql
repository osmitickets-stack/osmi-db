-- =============================================================================
-- OSMI DATABASE
-- Rollback 000006 — Fiscal Schema
-- =============================================================================

-- 1. Triggers
DROP TRIGGER IF EXISTS trg_update_invoices ON fiscal.invoices;
DROP TRIGGER IF EXISTS trg_update_country_config ON fiscal.country_config;

-- 2. Tablas
DROP TABLE IF EXISTS fiscal.invoices CASCADE;
DROP TABLE IF EXISTS fiscal.country_config CASCADE;

-- 3. Sequences
DROP SEQUENCE IF EXISTS fiscal.invoices_id_seq;
DROP SEQUENCE IF EXISTS fiscal.country_config_id_seq;

-- =============================================================================
-- FIN DEL ROLLBACK 000006
-- =============================================================================