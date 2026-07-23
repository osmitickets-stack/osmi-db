-- =============================================================================
-- OSMI DATABASE
-- Rollback 000011 — Catalog Event Types
-- =============================================================================

-- 1. Eliminar índices
DROP INDEX IF EXISTS catalog.idx_event_types_is_active;
DROP INDEX IF EXISTS catalog.idx_event_types_slug;
DROP INDEX IF EXISTS ticketing.idx_events_event_type_id;

-- 2. Eliminar columna de ticketing.events
ALTER TABLE ticketing.events DROP COLUMN IF EXISTS event_type_id;

-- 3. Eliminar tabla catalog.event_types
DROP TABLE IF EXISTS catalog.event_types CASCADE;

-- 4. Eliminar schema catalog (si está vacío)
DROP SCHEMA IF EXISTS catalog CASCADE;

-- =============================================================================
-- FIN DEL ROLLBACK 000011
-- =============================================================================
