-- =============================================================================
-- OSMI DATABASE
-- Rollback 000004 — Ticketing Schema
-- =============================================================================

-- 1. Triggers
DROP TRIGGER IF EXISTS trg_generate_ticket_code ON ticketing.tickets;
DROP TRIGGER IF EXISTS trg_update_tickets ON ticketing.tickets;
DROP TRIGGER IF EXISTS trg_update_ticket_types ON ticketing.ticket_types;
DROP TRIGGER IF EXISTS trg_update_events ON ticketing.events;
DROP TRIGGER IF EXISTS update_categories_updated_at ON ticketing.categories;
DROP TRIGGER IF EXISTS trg_update_organizers ON ticketing.organizers;
DROP TRIGGER IF EXISTS trg_update_venues ON ticketing.venues;

-- 2. Funciones
DROP FUNCTION IF EXISTS ticketing.check_ticket_availability(p_ticket_type_id BIGINT, p_quantity INTEGER);
DROP FUNCTION IF EXISTS ticketing.generate_ticket_code();

-- 3. Tablas
DROP TABLE IF EXISTS ticketing.tickets CASCADE;
DROP TABLE IF EXISTS ticketing.ticket_types CASCADE;
DROP TABLE IF EXISTS ticketing.events CASCADE;
DROP TABLE IF EXISTS ticketing.categories CASCADE;
DROP TABLE IF EXISTS ticketing.organizers CASCADE;
DROP TABLE IF EXISTS ticketing.venues CASCADE;

-- 4. Sequences
DROP SEQUENCE IF EXISTS ticketing.tickets_id_seq;
DROP SEQUENCE IF EXISTS ticketing.ticket_types_id_seq;
DROP SEQUENCE IF EXISTS ticketing.events_id_seq;
DROP SEQUENCE IF EXISTS ticketing.categories_id_seq;
DROP SEQUENCE IF EXISTS ticketing.organizers_id_seq;
DROP SEQUENCE IF EXISTS ticketing.venues_id_seq;

-- =============================================================================
-- FIN DEL ROLLBACK 000004
-- =============================================================================