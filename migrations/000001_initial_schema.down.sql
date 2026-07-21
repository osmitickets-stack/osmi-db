-- =============================================================================
-- OSMI DATABASE
-- Rollback 000001 — Initial Schema
-- =============================================================================

-- 1. Funciones compartidas
DROP FUNCTION IF EXISTS auth.update_updated_at();

-- 2. Dominios
DROP DOMAIN IF EXISTS billing.payment_status;
DROP DOMAIN IF EXISTS ticketing.ticket_status;
DROP DOMAIN IF EXISTS ticketing.event_status;
DROP DOMAIN IF EXISTS global.timezone_name;
DROP DOMAIN IF EXISTS global.country_code;
DROP DOMAIN IF EXISTS global.percentage;
DROP DOMAIN IF EXISTS global.currency_code;
DROP DOMAIN IF EXISTS global.phone_number;
DROP DOMAIN IF EXISTS global.email_address;

-- 3. Schemas
DROP SCHEMA IF EXISTS integration CASCADE;
DROP SCHEMA IF EXISTS audit CASCADE;
DROP SCHEMA IF EXISTS analytics CASCADE;
DROP SCHEMA IF EXISTS notifications CASCADE;
DROP SCHEMA IF EXISTS fiscal CASCADE;
DROP SCHEMA IF EXISTS billing CASCADE;
DROP SCHEMA IF EXISTS ticketing CASCADE;
DROP SCHEMA IF EXISTS global CASCADE;
DROP SCHEMA IF EXISTS crm CASCADE;
DROP SCHEMA IF EXISTS auth CASCADE;

-- 4. Extensiones (comentadas por seguridad)
-- DROP EXTENSION IF EXISTS postgis CASCADE;
-- DROP EXTENSION IF EXISTS btree_gist CASCADE;
-- DROP EXTENSION IF EXISTS btree_gin CASCADE;
-- DROP EXTENSION IF EXISTS unaccent CASCADE;
-- DROP EXTENSION IF EXISTS fuzzystrmatch CASCADE;
-- DROP EXTENSION IF EXISTS pg_trgm CASCADE;
-- DROP EXTENSION IF EXISTS pg_stat_statements CASCADE;
-- DROP EXTENSION IF EXISTS pgcrypto CASCADE;
-- DROP EXTENSION IF EXISTS "uuid-ossp" CASCADE;

-- =============================================================================
-- FIN DEL ROLLBACK 000001
-- =============================================================================