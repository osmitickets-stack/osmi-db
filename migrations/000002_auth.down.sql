-- =============================================================================
-- OSMI DATABASE
-- Rollback 000002 — Auth Schema
-- =============================================================================

-- 1. Triggers
DROP TRIGGER IF EXISTS trg_update_sessions ON auth.sessions;
DROP TRIGGER IF EXISTS trg_update_users ON auth.users;

-- 2. Indexes
DROP INDEX IF EXISTS auth.idx_sessions_expires;
DROP INDEX IF EXISTS auth.idx_sessions_user;
DROP INDEX IF EXISTS auth.idx_users_is_active;
DROP INDEX IF EXISTS auth.idx_users_email;

-- 3. Tablas
DROP TABLE IF EXISTS auth.sessions CASCADE;
DROP TABLE IF EXISTS auth.users CASCADE;
DROP TABLE IF EXISTS auth.roles CASCADE;

-- 4. Sequences
DROP SEQUENCE IF EXISTS auth.sessions_id_seq;
DROP SEQUENCE IF EXISTS auth.users_id_seq;
DROP SEQUENCE IF EXISTS auth.roles_id_seq;

-- =============================================================================
-- FIN DEL ROLLBACK 000002
-- =============================================================================