-- =============================================================================
-- OSMI - Sistema de Seeds
-- 003_demo.sql
-- =============================================================================
--
-- Propósito: Datos de demostración para desarrollo
-- SOLO se ejecuta en entornos de desarrollo
--
-- =============================================================================

-- =============================================================================
-- 1. USUARIO DEMO
-- =============================================================================

INSERT INTO auth.users (
    email,
    username,
    password_hash,
    full_name,
    is_active,
    is_superuser,
    is_staff
) VALUES (
    'demo@osmi.com',
    'demo',
    '$2a$10$QVrZ9DqgHMR.8I3VwFK/1O8ZxK8ZxK8ZxK8ZxK8ZxK8ZxK8ZxK8ZxK',
    'Usuario Demo',
    true,
    true,
    true
) ON CONFLICT (email) DO NOTHING;

-- =============================================================================
-- 2. ORGANIZADOR DEMO
-- =============================================================================

INSERT INTO ticketing.organizers (
    public_uuid,
    name,
    slug,
    contact_email,
    contact_phone,
    description,
    is_verified,
    is_active,
    verification_status,
    approval_status
) VALUES (
    gen_random_uuid(),
    'Osmi Demo Organizer',
    'osmi-demo-organizer',
    'demo@osmi.com',
    '+521234567890',
    'Organizador de demostración para Osmi Ticketing',
    true,
    true,
    'verified',
    'approved'
) ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- 3. VENUE DEMO
-- =============================================================================

INSERT INTO ticketing.venues (
    public_uuid,
    name,
    slug,
    venue_type,
    address_line1,
    city,
    country,
    capacity,
    is_active
) VALUES (
    gen_random_uuid(),
    'Osmi Arena',
    'osmi-arena',
    'indoor',
    'Av. Principal #123',
    'Ciudad de México',
    'MX',
    5000,
    true
) ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- 4. EVENTO DEMO
-- =============================================================================

-- Primero obtener IDs de organizador y venue
DO $$
DECLARE
    v_organizer_id BIGINT;
    v_venue_id BIGINT;
    v_event_type_id INTEGER;
BEGIN
    SELECT id INTO v_organizer_id FROM ticketing.organizers WHERE slug = 'osmi-demo-organizer';
    SELECT id INTO v_venue_id FROM ticketing.venues WHERE slug = 'osmi-arena';
    SELECT id INTO v_event_type_id FROM catalog.event_types WHERE slug = 'conciertos';

    INSERT INTO ticketing.events (
        public_uuid,
        organizer_id,
        venue_id,
        event_type_id,
        slug,
        name,
        short_description,
        description,
        timezone,
        starts_at,
        ends_at,
        city,
        country,
        status,
        visibility,
        is_featured,
        is_free,
        max_attendees,
        allow_reservations,
        published_at
    ) VALUES (
        gen_random_uuid(),
        v_organizer_id,
        v_venue_id,
        v_event_type_id,
        'osmi-festival-demo',
        'Osmi Festival 2025',
        'El festival de demostración de Osmi',
        'Evento de demostración para mostrar todas las funcionalidades de Osmi Ticketing.',
        'America/Mexico_City',
        NOW() + INTERVAL '30 days',
        NOW() + INTERVAL '30 days' + INTERVAL '6 hours',
        'Ciudad de México',
        'MX',
        'published',
        'public',
        true,
        false,
        1000,
        true,
        NOW()
    );
END $$;

-- =============================================================================
-- 5. CATEGORÍAS DEL EVENTO (Zonas)
-- =============================================================================

DO $$
DECLARE
    v_event_public_uuid UUID;
BEGIN
    SELECT public_uuid INTO v_event_public_uuid FROM ticketing.events WHERE slug = 'osmi-festival-demo';

    IF v_event_public_uuid IS NOT NULL THEN
        INSERT INTO ticketing.categories (
            public_uuid,
            event_id,
            name,
            slug,
            description,
            icon,
            color_hex,
            capacity,
            is_active,
            sort_order
        ) VALUES
            (gen_random_uuid(), v_event_public_uuid, 'VIP', 'vip', 'Zona VIP con acceso preferente', 'star', '#F1C40F', 100, true, 1),
            (gen_random_uuid(), v_event_public_uuid, 'General', 'general', 'Zona general', 'users', '#3498DB', 500, true, 2),
            (gen_random_uuid(), v_event_public_uuid, 'Palco', 'palco', 'Palcos con vista privilegiada', 'crown', '#9B59B6', 50, true, 3),
            (gen_random_uuid(), v_event_public_uuid, 'Backstage', 'backstage', 'Acceso tras bambalinas', 'lock', '#2ECC71', 20, true, 4);
    END IF;
END $$;

-- =============================================================================
-- 6. TICKET TYPES
-- =============================================================================

DO $$
DECLARE
    v_event_id BIGINT;
BEGIN
    SELECT id INTO v_event_id FROM ticketing.events WHERE slug = 'osmi-festival-demo';

    IF v_event_id IS NOT NULL THEN
        INSERT INTO ticketing.ticket_types (
            public_uuid,
            event_id,
            name,
            description,
            base_price,
            currency,
            total_quantity,
            max_per_order,
            min_per_order,
            sale_starts_at,
            is_active,
            tax_rate
        ) VALUES
            (gen_random_uuid(), v_event_id, 'VIP Ticket', 'Acceso VIP con beneficios exclusivos', 2500, 'MXN', 100, 4, 1, NOW(), true, 0.16),
            (gen_random_uuid(), v_event_id, 'General Ticket', 'Acceso general al evento', 850, 'MXN', 500, 10, 1, NOW(), true, 0.16),
            (gen_random_uuid(), v_event_id, 'Palco Ticket', 'Acceso a palco privado', 3500, 'MXN', 50, 2, 1, NOW(), true, 0.16),
            (gen_random_uuid(), v_event_id, 'Backstage Pass', 'Acceso backstage y meet & greet', 5000, 'MXN', 20, 1, 1, NOW(), true, 0.16);
    END IF;
END $$;

-- =============================================================================
-- FIN DE 003_demo.sql
-- =============================================================================
