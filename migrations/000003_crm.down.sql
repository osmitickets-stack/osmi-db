-- =============================================================================
-- OSMI DATABASE
-- Rollback 000003 — CRM Schema
-- =============================================================================

-- 1. Triggers
DROP TRIGGER IF EXISTS trg_update_customers ON crm.customers;

-- 2. Indexes
DROP INDEX IF EXISTS crm.idx_customers_created_at;
DROP INDEX IF EXISTS crm.idx_customers_country;
DROP INDEX IF EXISTS crm.idx_customers_is_active;
DROP INDEX IF EXISTS crm.idx_customers_user_id;
DROP INDEX IF EXISTS crm.idx_customers_email;

-- 3. Tabla
DROP TABLE IF EXISTS crm.customers CASCADE;

-- 4. Sequence
DROP SEQUENCE IF EXISTS crm.customers_id_seq;

-- =============================================================================
-- FIN DEL ROLLBACK 000003
-- =============================================================================