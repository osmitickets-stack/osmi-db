-- =============================================================================
-- OSMI DATABASE
-- Migración 000012 — Add Global Tables
-- =============================================================================
--
-- Esta migración crea las tablas globales que faltaron en 000001.
-- 
-- Tablas creadas:
--   ✅ global.supported_languages
--   ✅ global.supported_currencies
--   ✅ global.system_config
--
-- =============================================================================

-- =============================================================================
-- 1. global.supported_languages
-- =============================================================================

CREATE TABLE IF NOT EXISTS global.supported_languages (
    code VARCHAR(10) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    native_name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    is_default BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- =============================================================================
-- 2. global.supported_currencies
-- =============================================================================

CREATE TABLE IF NOT EXISTS global.supported_currencies (
    code VARCHAR(3) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    symbol VARCHAR(10) NOT NULL,
    decimal_places INTEGER DEFAULT 2,
    exchange_rate NUMERIC(15,6) DEFAULT 1.0,
    is_active BOOLEAN DEFAULT true,
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- =============================================================================
-- 3. global.system_config
-- =============================================================================

CREATE TABLE IF NOT EXISTS global.system_config (
    id SERIAL PRIMARY KEY,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value JSONB NOT NULL,
    data_type VARCHAR(50) DEFAULT 'string',
    description TEXT,
    category VARCHAR(50) DEFAULT 'general',
    is_public BOOLEAN DEFAULT false,
    is_encrypted BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- =============================================================================
-- 4. ÍNDICES
-- =============================================================================

CREATE INDEX IF NOT EXISTS idx_system_config_category ON global.system_config (category);

-- =============================================================================
-- FIN DE LA MIGRACIÓN 000012
-- =============================================================================
