-- =============================================================================
-- OSMI - Seeds de Producción
-- 004_desfragmentado.sql
-- IDEMPOTENTE (CON ON CONFLICT DO UPDATE)
-- =============================================================================
--
-- Propósito: Datos reales del artista Desfragmentado
-- Estos datos son PERMANENTES y se usan en producción
-- IDEMPOTENTE: se puede ejecutar múltiples veces sin errores
-- Si el evento ya existe, se ACTUALIZA con los nuevos valores
--
-- Ubicación: Av. Chapultepec #605, Colonia Americana, Guadalajara, Jalisco
-- Coordenadas: 20.733479525052278, -103.3811594054298
--
-- =============================================================================

-- =============================================================================
-- 1. USUARIO DEL ARTISTA
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
    'desfragmentado@osmi.com',
    'desfragmentado',
    '$2a$10$QVrZ9DqgHMR.8I3VwFK/1O8ZxK8ZxK8ZxK8ZxK8ZxK8ZxK8ZxK8ZxK',
    'Desfragmentado',
    true,
    true,
    true
) ON CONFLICT (email) DO NOTHING;

-- =============================================================================
-- 2. ORGANIZADOR (ARTISTA)
-- =============================================================================

INSERT INTO ticketing.organizers (
    public_uuid,
    name,
    slug,
    contact_email,
    contact_phone,
    description,
    logo_url,
    is_verified,
    is_active,
    verification_status,
    approval_status,
    social_links
) VALUES (
    gen_random_uuid(),
    'Desfragmentado',
    'desfragmentado',
    'desfragmentado@osmi.com',
    '3345998987',
    'Artista y productor musical. Especializado en colaboraciones únicas.',
    'https://res.cloudinary.com/dkasxv8fj/image/upload/v1779219665/WhatsApp_Image_2026-05-09_at_2.02.54_PM_mxqy93.jpg',
    true,
    true,
    'verified',
    'approved',
    '{
        "instagram": "https://www.instagram.com/desfragmentado_el_mc_legendari?igsh=azV1ZmJ5Z3R4N2M5",
        "spotify": "https://open.spotify.com/artist/3o9iSbT2VLRof2zLNQJFNO?si=Q2GWMAImT7OzSC1skgrmRw&utm_source=native-share-menu",
        "youtube": "https://www.youtube.com/@desfragmentadoo",
        "tiktok": "https://www.tiktok.com/@desfragmentado",
        "facebook": "https://www.facebook.com/Desfragmentado1405",
        "soundcloud": "https://soundcloud.com/desfragmentado-music"
    }'::jsonb
) ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- 3. VENUE (ESTUDIO DE GRABACIÓN)
-- =============================================================================

INSERT INTO ticketing.venues (
    public_uuid,
    name,
    slug,
    venue_type,
    description,
    address_line1,
    city,
    state,
    country,
    latitude,
    longitude,
    capacity,
    is_active,
    images
) VALUES (
    gen_random_uuid(),
    'Estudio Frequency404',
    'estudio-frequency404',
    'studio',
    'Estudio de grabación profesional con equipo casero profesional.',
    'Av. Chapultepec #605, Colonia Americana',
    'Guadalajara',
    'Jalisco',
    'MX',
    20.733479525052278,
    -103.3811594054298,
    100,
    true,
    '[
        "https://res.cloudinary.com/dkasxv8fj/image/upload/v1779219665/WhatsApp_Image_2026-05-09_at_2.02.54_PM_mxqy93.jpg",
        "https://res.cloudinary.com/dkasxv8fj/image/upload/v1779177598/studio2.jpg"
    ]'::jsonb
) ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- 4. EVENTO (COLABORACIÓN PRINCIPAL - SIEMPRE ACTIVO)
-- =============================================================================

DO $$
DECLARE
    v_organizer_id BIGINT;
    v_venue_id BIGINT;
    v_event_type_id INTEGER;
    v_event_public_uuid UUID;
BEGIN
    SELECT id INTO v_organizer_id FROM ticketing.organizers WHERE slug = 'desfragmentado';
    SELECT id INTO v_venue_id FROM ticketing.venues WHERE slug = 'estudio-frequency404';
    SELECT id INTO v_event_type_id FROM catalog.event_types WHERE slug = 'experiencias';

    -- ========================================================================
    -- 4.1 EVENTO - UPSERT (INSERT + UPDATE)
    -- Si existe, actualiza; si no, inserta.
    -- ========================================================================

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
        venue_name,
        address_full,
        city,
        state,
        country,
        latitude,
        longitude,
        status,
        visibility,
        is_featured,
        is_free,
        max_attendees,
        min_attendees,
        tags,
        cover_image_url,
        banner_image_url,
        settings,
        published_at
    ) VALUES (
        gen_random_uuid(),
        v_organizer_id,
        v_venue_id,
        v_event_type_id,
        'colaboracion-desfragmentado',
        'Colabora con Desfragmentado',
        'Grabá una canción, produce un tema o colaborá con el artista',
        'Desfragmentado abre sus puertas para colaboraciones únicas. Podés grabar una canción, producir un tema o tener una sesión de composición con el artista. Cada colaboración es única y se adapta a tus necesidades.

🎵 **Opciones de colaboración:**
- Grabación de una canción completa
- Producción musical
- Sesión de composición
- Feature en un tema existente
- Producción ejecutiva

🔥 **Incluye:**
- Estudio de grabación profesional
- Ingeniero de sonido
- Mezcla y masterización básica
- 2 horas de sesión

⚠️ **Requisitos:**
- Tener la letra y melodía definida
- Contar con los músicos necesarios (si aplica)
- Llegar 30 minutos antes de la sesión',
        'America/Mexico_City',
        NOW() + INTERVAL '1 day',
        NOW() + INTERVAL '1 day' + INTERVAL '365 days',
        'Estudio Frequency404',
        'Av. Chapultepec #605, Colonia Americana',
        'Guadalajara',
        'Jalisco',
        'MX',
        20.733479525052278,
        -103.3811594054298,
        'published',
        'public',
        true,
        false,
        100,
        1,
        '["colaboracion", "grabacion", "produccion", "musica", "desfragmentado"]'::jsonb,
        'https://res.cloudinary.com/dkasxv8fj/image/upload/v1779219665/WhatsApp_Image_2026-05-09_at_2.02.54_PM_mxqy93.jpg',
        'https://res.cloudinary.com/dkasxv8fj/image/upload/v1779219665/WhatsApp_Image_2026-05-09_at_2.02.54_PM_mxqy93.jpg',
        '{
            "allow_cancellations": true,
            "cancellation_deadline_hours": 48,
            "allow_transfers": true,
            "require_id": true,
            "checkin_method": "qr_code"
        }'::jsonb,
        NOW()
    ) ON CONFLICT (slug) DO UPDATE SET
        organizer_id = EXCLUDED.organizer_id,
        venue_id = EXCLUDED.venue_id,
        event_type_id = EXCLUDED.event_type_id,
        name = EXCLUDED.name,
        short_description = EXCLUDED.short_description,
        description = EXCLUDED.description,
        timezone = EXCLUDED.timezone,
        starts_at = EXCLUDED.starts_at,
        ends_at = EXCLUDED.ends_at,
        venue_name = EXCLUDED.venue_name,
        address_full = EXCLUDED.address_full,
        city = EXCLUDED.city,
        state = EXCLUDED.state,
        country = EXCLUDED.country,
        latitude = EXCLUDED.latitude,
        longitude = EXCLUDED.longitude,
        status = EXCLUDED.status,
        visibility = EXCLUDED.visibility,
        is_featured = EXCLUDED.is_featured,
        is_free = EXCLUDED.is_free,
        max_attendees = EXCLUDED.max_attendees,
        min_attendees = EXCLUDED.min_attendees,
        tags = EXCLUDED.tags,
        cover_image_url = EXCLUDED.cover_image_url,
        banner_image_url = EXCLUDED.banner_image_url,
        settings = EXCLUDED.settings,
        published_at = EXCLUDED.published_at,
        updated_at = NOW()
    RETURNING public_uuid INTO v_event_public_uuid;

    -- =========================================================================
    -- 5. CATEGORÍAS (NIVELES DE COLABORACIÓN) - IDEMPOTENTE
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
            (
                gen_random_uuid(),
                v_event_public_uuid,
                'Colaboración Premium',
                'colaboracion-premium',
                'Grabación de una canción completa con producción ejecutiva del artista. Incluye 4 horas de estudio, mezcla, masterización y lanzamiento en plataformas.',
                'star',
                '#F1C40F',
                10,
                true,
                1
            ),
            (
                gen_random_uuid(),
                v_event_public_uuid,
                'Colaboración Estándar',
                'colaboracion-estandar',
                'Grabación de una canción con producción básica. Incluye 2 horas de estudio, mezcla y masterización básica.',
                'music',
                '#3498DB',
                20,
                true,
                2
            ),
            (
                gen_random_uuid(),
                v_event_public_uuid,
                'Sesión de Composición',
                'sesion-composicion',
                'Sesión de 3 horas para componer una canción junto al artista. Ideal para artistas emergentes que quieren aprender del proceso creativo.',
                'pen',
                '#2ECC71',
                15,
                true,
                3
            ),
            (
                gen_random_uuid(),
                v_event_public_uuid,
                'Feature en Tema',
                'feature-tema',
                'El artista graba un feature en tu tema existente. Incluye 1 hora de grabación y producción vocal.',
                'mic',
                '#9B59B6',
                5,
                true,
                4
            )
        ON CONFLICT (event_id, slug) DO NOTHING;
    END IF;

    -- =========================================================================
    -- 6. TICKET TYPES (SERVICIOS) - IDEMPOTENTE
    -- =========================================================================

    IF v_event_public_uuid IS NOT NULL THEN
        DECLARE
            v_event_id BIGINT;
        BEGIN
            SELECT id INTO v_event_id FROM ticketing.events WHERE public_uuid = v_event_public_uuid;

            IF v_event_id IS NOT NULL THEN
                -- Colaboración Premium
                IF NOT EXISTS (SELECT 1 FROM ticketing.ticket_types WHERE event_id = v_event_id AND name = 'Premium - Canción Completa') THEN
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
                        tax_rate,
                        benefits
                    ) VALUES (
                        gen_random_uuid(),
                        v_event_id,
                        'Premium - Canción Completa',
                        'Grabación completa con producción ejecutiva. 4 horas de estudio, mezcla, masterización y lanzamiento.',
                        25000,
                        'MXN',
                        10,
                        1,
                        1,
                        NOW(),
                        true,
                        0.16,
                        '["Producción ejecutiva", "4 horas de estudio", "Ingeniero de sonido", "Mezcla profesional", "Masterización", "Lanzamiento en plataformas"]'::jsonb
                    );
                END IF;

                -- Colaboración Estándar
                IF NOT EXISTS (SELECT 1 FROM ticketing.ticket_types WHERE event_id = v_event_id AND name = 'Estándar - Canción') THEN
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
                        tax_rate,
                        benefits
                    ) VALUES (
                        gen_random_uuid(),
                        v_event_id,
                        'Estándar - Canción',
                        'Grabación de una canción con producción básica. 2 horas de estudio, mezcla y masterización básica.',
                        12000,
                        'MXN',
                        20,
                        1,
                        1,
                        NOW(),
                        true,
                        0.16,
                        '["2 horas de estudio", "Ingeniero de sonido", "Mezcla básica", "Masterización básica"]'::jsonb
                    );
                END IF;

                -- Sesión de Composición
                IF NOT EXISTS (SELECT 1 FROM ticketing.ticket_types WHERE event_id = v_event_id AND name = 'Sesión de Composición') THEN
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
                        tax_rate,
                        benefits
                    ) VALUES (
                        gen_random_uuid(),
                        v_event_id,
                        'Sesión de Composición',
                        'Sesión de 3 horas para componer junto al artista. Ideal para aprender del proceso creativo.',
                        8000,
                        'MXN',
                        15,
                        1,
                        1,
                        NOW(),
                        true,
                        0.16,
                        '["3 horas de sesión", "Acompañamiento del artista", "Material de trabajo", "Grabación de la sesión"]'::jsonb
                    );
                END IF;

                -- Feature en Tema
                IF NOT EXISTS (SELECT 1 FROM ticketing.ticket_types WHERE event_id = v_event_id AND name = 'Feature en Tema') THEN
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
                        tax_rate,
                        benefits
                    ) VALUES (
                        gen_random_uuid(),
                        v_event_id,
                        'Feature en Tema',
                        'El artista graba un feature en tu tema existente. 1 hora de grabación y producción vocal.',
                        15000,
                        'MXN',
                        5,
                        1,
                        1,
                        NOW(),
                        true,
                        0.16,
                        '["1 hora de grabación", "Producción vocal", "Ingeniero de sonido", "Mezcla vocal"]'::jsonb
                    );
                END IF;

                -- Foto con Desfragmentado (Prueba de compra)
                IF NOT EXISTS (SELECT 1 FROM ticketing.ticket_types WHERE event_id = v_event_id AND name = 'Sesión de una foto con Desfra') THEN
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
                        tax_rate,
                        benefits
                    ) VALUES (
                        gen_random_uuid(),
                        v_event_id,
                        'Sesión de una foto con Desfra',
                        'Sesión de una foto junto al artista. Ideal para conocerlo.',
                        10,
                        'MXN',
                        1500,
                        1,
                        1,
                        NOW(),
                        true,
                        0.16,
                        '["1 foto", "Acompañamiento del artista", "Sesión de 5 minutos"]'::jsonb
                    );
                END IF;

            END IF;
        END;
    END IF;
END $$;

-- =============================================================================
-- FIN DE 004_desfragmentado.sql
-- =============================================================================