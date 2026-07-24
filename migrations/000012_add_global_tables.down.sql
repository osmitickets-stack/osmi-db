-- =============================================================================
-- OSMI DATABASE
-- Rollback 000012 — Add Global Tables
-- =============================================================================

-- 1. Eliminar índices
DROP INDEX IF EXISTS global.idx_system_config_category;

-- 2. Eliminar tablas
DROP TABLE IF EXISTS global.system_config CASCADE;
DROP TABLE IF EXISTS global.supported_currencies CASCADE;
DROP TABLE IF EXISTS global.supported_languages CASCADE;

-- =============================================================================
-- FIN DEL ROLLBACK 000012
-- =============================================================================
