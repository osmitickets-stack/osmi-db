-- =============================================================================
-- OSMI - Seed de Proveedores de Pago
-- 003_payment_providers.sql
-- =============================================================================
--
-- Propósito: Datos iniciales de proveedores de pago
-- Estos datos son PERMANENTES y se usan en producción
-- IDEMPOTENTE: se puede ejecutar múltiples veces sin errores
--
-- =============================================================================

INSERT INTO billing.payment_providers (
    code,
    name,
    provider_type,
    is_active,
    is_online,
    supports_refunds,
    min_amount,
    max_amount,
    supported_currencies,
    supported_countries,
    config,
    created_at,
    updated_at
) VALUES
(
    'stripe',
    'Stripe',
    'gateway',
    true,
    true,
    true,
    0.01,
    999999.99,
    '{MXN,USD,EUR}',
    '{MX,US,CA,EU}',
    '{"webhook_secret": ""}'::jsonb,
    NOW(),
    NOW()
),
(
    'paypal',
    'PayPal',
    'gateway',
    true,
    true,
    true,
    0.01,
    999999.99,
    '{MXN,USD,EUR}',
    '{MX,US,CA,EU}',
    '{"webhook_secret": ""}'::jsonb,
    NOW(),
    NOW()
),
(
    'oxxo',
    'OXXO Pay',
    'method',
    true,
    false,
    false,
    1.00,
    10000.00,
    '{MXN}',
    '{MX}',
    '{}'::jsonb,
    NOW(),
    NOW()
),
(
    'card',
    'Credit/Debit Card',
    'method',
    true,
    true,
    true,
    0.01,
    999999.99,
    '{MXN,USD,EUR}',
    '{MX,US,CA,EU}',
    '{}'::jsonb,
    NOW(),
    NOW()
)
ON CONFLICT (code) DO NOTHING;