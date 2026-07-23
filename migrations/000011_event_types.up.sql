-- =============================================================================
-- OSMI DATABASE
-- Migración 000011 — Catalog Event Types
-- =============================================================================
--
-- Esta migración crea el catálogo de tipos de eventos.
-- Reemplaza el campo de texto libre 'category' en ticketing.events
-- por una relación FK a catalog.event_types.
--
-- =============================================================================

-- =============================================================================
-- 1. CREAR SCHEMA catalog (si no existe)
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS catalog;

-- =============================================================================
-- 2. CREAR TABLA catalog.event_types
-- =============================================================================

CREATE TABLE catalog.event_types (
    id SERIAL PRIMARY KEY,
    public_uuid UUID DEFAULT gen_random_uuid() NOT NULL,
    slug VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    color_hex VARCHAR(7) DEFAULT '#3498db',
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now() NOT NULL
);

-- =============================================================================
-- 3. ÍNDICES
-- =============================================================================

CREATE INDEX idx_event_types_slug ON catalog.event_types (slug);
CREATE INDEX idx_event_types_is_active ON catalog.event_types (is_active) WHERE is_active = true;

-- =============================================================================
-- 4. AGREGAR COLUMNA event_type_id A ticketing.events
-- =============================================================================

ALTER TABLE ticketing.events
ADD COLUMN event_type_id INTEGER REFERENCES catalog.event_types(id);

-- =============================================================================
-- 5. ÍNDICE PARA LA NUEVA COLUMNA
-- =============================================================================

CREATE INDEX idx_events_event_type_id ON ticketing.events (event_type_id);

-- =============================================================================
-- 6. MIGRAR DATOS EXISTENTES (si hay eventos con category)
-- =============================================================================

-- NOTA: Esta sección se completa si existen datos existentes.
-- Si no hay datos, se puede omitir.
-- =============================================================================

-- =============================================================================
-- FIN DE LA MIGRACIÓN 000011
-- =============================================================================
