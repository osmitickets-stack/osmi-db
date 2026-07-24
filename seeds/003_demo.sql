-- =============================================================================
-- OSMI - Sistema de Seeds
-- 003_demo.sql
-- =============================================================================
--
-- Propósito: Datos de demostración para desarrollo
-- SOLO se ejecuta en entornos de desarrollo
-- ES IDEMPOTENTE: se puede ejecutar múltiples veces sin errores
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
    'inauguracion@osmi.com',
    'inauguracion',
    '$2a$10$QVrZ9DqgHMR.8I3VwFK/1O8ZxK8ZxK8ZxK8ZxK8ZxK8ZxK8ZxK8ZxK',
    'osmi-inauguracion',
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
    'Osmi Organizer',
    'osmi-organizer',
    'inauguracion@osmi.com',
    '+523345998987',
    'Organizador de inauguracion para Osmi Ticketing',
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
    'Osmi wings',
    'osmi-wings',
    'indoor',
    'Av. chapultepec #605',
    'guadalajara',
    'MX',
    1000,
    true
) ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- 4. EVENTO DEMO (IDEMPOTENTE)
-- =============================================================================

DO $$
DECLARE
    v_organizer_id BIGINT;
    v_venue_id BIGINT;
    v_event_type_id INTEGER;
    v_event_public_uuid UUID;
BEGIN
    SELECT id INTO v_organizer_id FROM ticketing.organizers WHERE slug = 'osmi-organizer';
    SELECT id INTO v_venue_id FROM ticketing.venues WHERE slug = 'osmi-wings';
    SELECT id INTO v_event_type_id FROM catalog.event_types WHERE slug = 'conciertos';

    -- Verificar si el evento ya existe
    SELECT public_uuid INTO v_event_public_uuid FROM ticketing.events WHERE slug = 'osmi-festival-inauguracion';

    IF v_event_public_uuid IS NULL THEN
        -- Insertar evento
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
            'osmi-festival-inauguracion',
            'Osmi Festival 2026',
            'El festival de inauguracion de Osmi',
            'Evento de demostración para mostrar todas las funcionalidades de Osmi Ticketing.',
            'America/Mexico_City',
            NOW() + INTERVAL '120 days',
            NOW() + INTERVAL '120 days' + INTERVAL '6 hours',
            'Guadalajara',
            'MX',
            'published',
            'public',
            true,
            false,
            1000,
            true,
            NOW()
        )
        RETURNING public_uuid INTO v_event_public_uuid;
    END IF;

    -- =========================================================================
    -- 5. CATEGORÍAS DEL EVENTO (Zonas) - IDEMPOTENTE
    -- Usa ON CONFLICT con la restricción UNIQUE (event_id, slug)
    -- =========================================================================

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
            (gen_random_uuid(), v_event_public_uuid, 'Backstage', 'backstage', 'Acceso tras bambalinas', 'lock', '#2ECC71', 20, true, 4)
        ON CONFLICT (event_id, slug) DO NOTHING;
    END IF;

    -- =========================================================================
    -- 6. TICKET TYPES - IDEMPOTENTE
    -- No hay UNIQUE (event_id, name), usamos verificación previa
    -- =========================================================================

    IF v_event_public_uuid IS NOT NULL THEN
        -- Obtener el ID del evento para ticket_types
        DECLARE
            v_event_id BIGINT;
        BEGIN
            SELECT id INTO v_event_id FROM ticketing.events WHERE public_uuid = v_event_public_uuid;

            IF v_event_id IS NOT NULL THEN
                -- VIP Ticket
                IF NOT EXISTS (SELECT 1 FROM ticketing.ticket_types WHERE event_id = v_event_id AND name = 'VIP Ticket') THEN
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
                    ) VALUES (
                        gen_random_uuid(),
                        v_event_id,
                        'VIP Ticket',
                        'Acceso VIP con beneficios exclusivos',
                        2500,
                        'MXN',
                        100,
                        4,
                        1,
                        NOW(),
                        true,
                        0.16
                    );
                END IF;

                -- General Ticket
                IF NOT EXISTS (SELECT 1 FROM ticketing.ticket_types WHERE event_id = v_event_id AND name = 'General Ticket') THEN
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
                    ) VALUES (
                        gen_random_uuid(),
                        v_event_id,
                        'General Ticket',
                        'Acceso general al evento',
                        850,
                        'MXN',
                        500,
                        10,
                        1,
                        NOW(),
                        true,
                        0.16
                    );
                END IF;

                -- Palco Ticket
                IF NOT EXISTS (SELECT 1 FROM ticketing.ticket_types WHERE event_id = v_event_id AND name = 'Palco Ticket') THEN
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
                    ) VALUES (
                        gen_random_uuid(),
                        v_event_id,
                        'Palco Ticket',
                        'Acceso a palco privado',
                        3500,
                        'MXN',
                        50,
                        2,
                        1,
                        NOW(),
                        true,
                        0.16
                    );
                END IF;

                -- Backstage Pass
                IF NOT EXISTS (SELECT 1 FROM ticketing.ticket_types WHERE event_id = v_event_id AND name = 'Backstage Pass') THEN
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
                    ) VALUES (
                        gen_random_uuid(),
                        v_event_id,
                        'Backstage Pass',
                        'Acceso backstage y meet & greet',
                        5000,
                        'MXN',
                        20,
                        1,
                        1,
                        NOW(),
                        true,
                        0.16
                    );
                END IF;
            END IF;
        END;
    END IF;
END $$;

-- =============================================================================
-- FIN DE 003_demo.sql
-- =============================================================================