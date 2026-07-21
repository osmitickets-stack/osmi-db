-- =============================================================================
-- OSMI DATABASE
-- Migración 000001 — Initial Schema
-- =============================================================================
--
-- Esta migración crea la base de datos inicial con:
--   ✅ Extensiones necesarias
--   ✅ Schemas organizados por módulo
--   ✅ Dominios globales y específicos
--   ✅ Funciones compartidas
--
-- =============================================================================

-- =============================================================================
-- 1. EXTENSIONES
-- =============================================================================

-- UUID v4
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Criptografía
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Estadísticas de rendimiento
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Búsqueda de texto y similitud
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
CREATE EXTENSION IF NOT EXISTS unaccent;

-- Índices avanzados
CREATE EXTENSION IF NOT EXISTS btree_gin;
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- PostGIS (espacial)
CREATE EXTENSION IF NOT EXISTS postgis;

-- =============================================================================
-- 2. SCHEMAS
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS crm;
CREATE SCHEMA IF NOT EXISTS global;
CREATE SCHEMA IF NOT EXISTS ticketing;
CREATE SCHEMA IF NOT EXISTS billing;
CREATE SCHEMA IF NOT EXISTS fiscal;
CREATE SCHEMA IF NOT EXISTS notifications;
CREATE SCHEMA IF NOT EXISTS analytics;
CREATE SCHEMA IF NOT EXISTS audit;
CREATE SCHEMA IF NOT EXISTS integration;

-- =============================================================================
-- 3. DOMINIOS
-- =============================================================================

-- =============================================================================
-- Schema: global
-- =============================================================================

-- email_address
CREATE DOMAIN global.email_address AS VARCHAR(320)
CHECK (VALUE ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- phone_number
CREATE DOMAIN global.phone_number AS VARCHAR(20)
CHECK (
    VALUE ~ '^\+[1-9][0-9]{1,14}$' OR
    VALUE ~ '^[0-9]{8,15}$'
);

-- currency_code (ISO 4217)
CREATE DOMAIN global.currency_code AS VARCHAR(3)
CHECK (VALUE ~ '^[A-Z]{3}$');

-- percentage (0-1 con 4 decimales)
CREATE DOMAIN global.percentage AS NUMERIC(5,4)
CHECK (VALUE >= 0 AND VALUE <= 1);

-- country_code (ISO 3166)
CREATE DOMAIN global.country_code AS VARCHAR(2)
CHECK (VALUE ~ '^[A-Z]{2}$');

-- timezone_name
CREATE DOMAIN global.timezone_name AS VARCHAR(50)
CHECK (
    VALUE ~ '^[A-Za-z_]+/[A-Za-z_]+$' OR
    VALUE = 'UTC'
);

-- =============================================================================
-- Schema: ticketing
-- =============================================================================

-- event_status
CREATE DOMAIN ticketing.event_status AS VARCHAR(20)
CHECK (VALUE IN (
    'draft', 'scheduled', 'published', 'live',
    'cancelled', 'completed', 'sold_out', 'archived'
));

-- ticket_status
CREATE DOMAIN ticketing.ticket_status AS VARCHAR(20)
CHECK (VALUE IN (
    'available', 'reserved', 'sold', 'checked_in',
    'cancelled', 'refunded', 'expired'
));

-- =============================================================================
-- Schema: billing
-- =============================================================================

-- payment_status
CREATE DOMAIN billing.payment_status AS VARCHAR(20)
CHECK (VALUE IN (
    'pending', 'processing', 'completed', 'failed',
    'refunded', 'disputed', 'chargeback', 'expired'
));

-- =============================================================================
-- 4. FUNCIONES COMPARTIDAS
-- =============================================================================

-- =============================================================================
-- update_updated_at()
-- Función compartida para actualizar timestamps en todos los módulos
-- =============================================================================

CREATE OR REPLACE FUNCTION auth.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- FIN DE LA MIGRACIÓN 000001
-- =============================================================================-- Test workflow
