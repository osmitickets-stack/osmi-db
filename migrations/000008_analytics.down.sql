-- =============================================================================
-- OSMI DATABASE
-- Rollback 000008 — Analytics Schema
-- =============================================================================

-- 1. Views
DROP VIEW IF EXISTS analytics.sales_report CASCADE;

-- 2. Triggers
DROP TRIGGER IF EXISTS trg_update_event_metrics ON analytics.event_metrics;
DROP TRIGGER IF EXISTS trg_update_daily_metrics ON analytics.daily_metrics;

-- 3. Indexes
DROP INDEX IF EXISTS analytics.idx_event_metrics_event_id;
DROP INDEX IF EXISTS analytics.idx_daily_metrics_date;

-- 4. Tablas
DROP TABLE IF EXISTS analytics.event_metrics CASCADE;
DROP TABLE IF EXISTS analytics.daily_metrics CASCADE;

-- 5. Sequences
DROP SEQUENCE IF EXISTS analytics.event_metrics_id_seq;
DROP SEQUENCE IF EXISTS analytics.daily_metrics_id_seq;

-- =============================================================================
-- FIN DEL ROLLBACK 000008
-- =============================================================================