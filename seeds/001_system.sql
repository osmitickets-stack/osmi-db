-- =============================================================================
-- OSMI - Sistema de Seeds
-- 001_system.sql
-- =============================================================================
--
-- Propósito: Datos permanentes del sistema
-- Estos datos NUNCA cambian por cliente
-- Se ejecutan en cualquier entorno (desarrollo, staging, producción)
--
-- =============================================================================

-- =============================================================================
-- 1. ROLES (auth.roles)
-- =============================================================================

INSERT INTO auth.roles (name) VALUES
    ('super_admin'),
    ('admin'),
    ('organizer'),
    ('staff'),
    ('customer')
ON CONFLICT (name) DO NOTHING;

-- =============================================================================
-- 2. IDIOMAS (global.supported_languages)
-- =============================================================================

INSERT INTO global.supported_languages (code, name, native_name, is_active, is_default, sort_order) VALUES
    ('es', 'Spanish', 'Español', true, true, 1),
    ('en', 'English', 'English', true, false, 2),
    ('pt', 'Portuguese', 'Português', true, false, 3)
ON CONFLICT (code) DO NOTHING;

-- =============================================================================
-- 3. MONEDAS (global.supported_currencies)
-- =============================================================================

INSERT INTO global.supported_currencies (code, name, symbol, decimal_places, is_active, is_default) VALUES
    ('MXN', 'Mexican Peso', '$', 2, true, true),
    ('USD', 'US Dollar', 'US$', 2, true, false),
    ('EUR', 'Euro', '€', 2, true, false)
ON CONFLICT (code) DO NOTHING;

-- =============================================================================
-- 4. CONFIGURACIÓN DEL SISTEMA (global.system_config)
-- =============================================================================

INSERT INTO global.system_config (config_key, config_value, data_type, description, category) VALUES
    ('app.name', '"OSMI Ticketing"', 'string', 'Nombre de la aplicación', 'general'),
    ('app.version', '"2025.1.0"', 'string', 'Versión de la aplicación', 'general'),
    ('ticket.reservation_timeout', '900', 'number', 'Tiempo de reserva en segundos', 'ticketing'),
    ('payment.default_currency', '"MXN"', 'string', 'Moneda por defecto', 'billing'),
    ('security.max_login_attempts', '5', 'number', 'Intentos máximos de login', 'security')
ON CONFLICT (config_key) DO NOTHING;

-- =============================================================================
-- FIN DE 001_system.sql
-- =============================================================================
