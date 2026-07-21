-- =============================================================================
-- OSMI DATABASE
-- Rollback 000005 — Billing Schema
-- =============================================================================

-- 1. Triggers
DROP TRIGGER IF EXISTS trg_update_refunds ON billing.refunds;
DROP TRIGGER IF EXISTS trg_update_payments ON billing.payments;
DROP TRIGGER IF EXISTS trg_update_order_items ON billing.order_items;
DROP TRIGGER IF EXISTS trg_update_orders ON billing.orders;
DROP TRIGGER IF EXISTS trg_update_payment_providers ON billing.payment_providers;

-- 2. Indexes
DROP INDEX IF EXISTS billing.idx_payments_provider_transaction_id;
DROP INDEX IF EXISTS billing.idx_payments_status;
DROP INDEX IF EXISTS billing.idx_payments_order_id;
DROP INDEX IF EXISTS billing.idx_order_items_ticket_type_id;
DROP INDEX IF EXISTS billing.idx_order_items_order_id;
DROP INDEX IF EXISTS billing.idx_orders_reservation_expires;
DROP INDEX IF EXISTS billing.idx_orders_customer_email;
DROP INDEX IF EXISTS billing.idx_orders_created_at;
DROP INDEX IF EXISTS billing.idx_orders_status;
DROP INDEX IF EXISTS billing.idx_orders_customer_id;

-- 3. Tablas
DROP TABLE IF EXISTS billing.refunds CASCADE;
DROP TABLE IF EXISTS billing.payments CASCADE;
DROP TABLE IF EXISTS billing.order_items CASCADE;
DROP TABLE IF EXISTS billing.orders CASCADE;
DROP TABLE IF EXISTS billing.payment_providers CASCADE;

-- 4. Sequences
DROP SEQUENCE IF EXISTS billing.refunds_id_seq;
DROP SEQUENCE IF EXISTS billing.payments_id_seq;
DROP SEQUENCE IF EXISTS billing.order_items_id_seq;
DROP SEQUENCE IF EXISTS billing.orders_id_seq;
DROP SEQUENCE IF EXISTS billing.payment_providers_id_seq;

-- =============================================================================
-- FIN DEL ROLLBACK 000005
-- =============================================================================