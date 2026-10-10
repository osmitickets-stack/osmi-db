-- =============================================================================
-- OSMI DATABASE
-- Rollback 000013 — Event Staff Authorization
-- =============================================================================

DROP TRIGGER IF EXISTS trg_update_event_staff
ON ticketing.event_staff;

DROP TABLE IF EXISTS ticketing.event_staff;