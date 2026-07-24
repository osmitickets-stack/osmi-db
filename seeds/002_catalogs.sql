-- =============================================================================
-- OSMI - Sistema de Seeds
-- 002_catalogs.sql
-- =============================================================================
--
-- Propósito: Catálogos base del sistema
-- Tipos de eventos, países, estados, métodos de pago, etc.
--
-- =============================================================================

-- =============================================================================
-- 1. TIPOS DE EVENTOS (catalog.event_types)
-- =============================================================================

INSERT INTO catalog.event_types (slug, name, description, icon, color_hex, sort_order, is_active) VALUES
    ('conciertos', 'Conciertos', 'Conciertos y espectáculos musicales', 'music', '#E74C3C', 1, true),
    ('festivales', 'Festivales', 'Festivales culturales y musicales', 'festival', '#F39C12', 2, true),
    ('deportes', 'Deportes', 'Eventos deportivos', 'sports', '#3498DB', 3, true),
    ('teatro', 'Teatro', 'Obras de teatro y artes escénicas', 'theater', '#9B59B6', 4, true),
    ('comedia', 'Comedia', 'Espectáculos de comedia', 'comedy', '#2ECC71', 5, true),
    ('conferencias', 'Conferencias', 'Conferencias y charlas', 'conference', '#1ABC9C', 6, true),
    ('experiencias', 'Experiencias', 'Experiencias únicas', 'experiences', '#E67E22', 7, true),
    ('gastronomia', 'Gastronomía', 'Eventos gastronómicos', 'food', '#E74C3C', 8, true),
    ('familiares', 'Familiares', 'Eventos para toda la familia', 'family', '#2ECC71', 9, true),
    ('culturales', 'Culturales', 'Eventos culturales', 'culture', '#9B59B6', 10, true)
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- 2. ESTADOS DE EVENTO (para referencia, ya existen como DOMAIN)
-- =============================================================================

-- NOTA: Los estados de evento ya están definidos como DOMAIN:
-- ticketing.event_status: draft, scheduled, published, live, cancelled, completed, sold_out, archived
-- ticketing.ticket_status: available, reserved, sold, checked_in, cancelled, refunded, expired
-- billing.payment_status: pending, processing, completed, failed, refunded, disputed, chargeback, expired

-- =============================================================================
-- FIN DE 002_catalogs.sql
-- =============================================================================
