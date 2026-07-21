-- =============================================================================
-- OSMI DATABASE
-- Migración 000004 — Ticketing Schema
-- =============================================================================
--
-- Esta migración crea el módulo de Ticketing (núcleo del negocio):
--   ✅ ticketing.venues
--   ✅ ticketing.organizers
--   ✅ ticketing.categories
--   ✅ ticketing.events
--   ✅ ticketing.ticket_types
--   ✅ ticketing.tickets
--   ✅ Constraints (PK, UNIQUE, FK, CHECK)
--   ✅ Indexes
--   ✅ Triggers
--   ✅ Funciones de negocio
--
-- Dependencias:
--   - 000001_initial_schema (dominios, función update_updated_at)
--   - 000002_auth (auth.users)
--   - 000003_crm (crm.customers)
--
-- =============================================================================

-- =============================================================================
-- 1. FUNCIONES DE NEGOCIO (deben existir antes de los triggers)
-- =============================================================================

-- =============================================================================
-- ticketing.generate_ticket_code()
-- Genera código único para cada ticket al insertar
-- =============================================================================

CREATE OR REPLACE FUNCTION ticketing.generate_ticket_code()
RETURNS TRIGGER AS $$
DECLARE
    v_event_prefix VARCHAR(3);
    v_type_prefix VARCHAR(2);
    v_random_part VARCHAR(8);
    v_attempt_code VARCHAR(50);
    v_attempt INTEGER := 0;
BEGIN
    -- Obtener prefijos del evento y tipo de ticket
    SELECT 
        UPPER(SUBSTRING(e.slug FROM 1 FOR 3)),
        UPPER(SUBSTRING(tt.name FROM 1 FOR 2))
    INTO 
        v_event_prefix,
        v_type_prefix
    FROM ticketing.events e
    JOIN ticketing.ticket_types tt ON tt.id = NEW.ticket_type_id
    WHERE e.id = NEW.event_id;
    
    -- Generar código único
    WHILE v_attempt < 10 LOOP
        v_random_part := UPPER(SUBSTRING(encode(gen_random_bytes(6), 'base64') FROM 1 FOR 8));
        v_random_part := REPLACE(REPLACE(v_random_part, '/', '0'), '+', '1');
        v_random_part := REPLACE(REPLACE(v_random_part, '=', '2'), '-', '3');
        
        v_attempt_code := v_event_prefix || v_type_prefix || v_random_part;
        
        IF NOT EXISTS (SELECT 1 FROM ticketing.tickets WHERE code = v_attempt_code) THEN
            NEW.code := v_attempt_code;
            NEW.secret_hash := encode(
                digest(
                    v_attempt_code || gen_random_bytes(32) || EXTRACT(EPOCH FROM NOW())::TEXT,
                    'sha256'
                ),
                'hex'
            );
            RETURN NEW;
        END IF;
        
        v_attempt := v_attempt + 1;
    END LOOP;
    
    RAISE EXCEPTION 'No se pudo generar un código de ticket único';
END;
$$ LANGUAGE plpgsql;

ALTER FUNCTION ticketing.generate_ticket_code() OWNER TO osmi;

-- =============================================================================
-- ticketing.check_ticket_availability()
-- Verifica disponibilidad de tickets para un tipo específico
-- =============================================================================

CREATE OR REPLACE FUNCTION ticketing.check_ticket_availability(
    p_ticket_type_id BIGINT,
    p_quantity INTEGER
)
RETURNS JSONB AS $$
DECLARE
    v_ticket_type RECORD;
    v_available INTEGER;
    v_result JSONB;
BEGIN
    SELECT 
        *,
        (total_quantity - sold_quantity - reserved_quantity) as available_qty
    INTO v_ticket_type
    FROM ticketing.ticket_types
    WHERE id = p_ticket_type_id
    FOR UPDATE SKIP LOCKED;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object(
            'available', false,
            'reason', 'Ticket type not found'
        );
    END IF;
    
    v_available := v_ticket_type.available_qty;
    
    IF NOT v_ticket_type.is_active THEN
        v_result := jsonb_build_object(
            'available', false,
            'reason', 'Ticket type is inactive'
        );
    ELSIF v_ticket_type.sale_starts_at > NOW() THEN
        v_result := jsonb_build_object(
            'available', false,
            'reason', 'Sale has not started'
        );
    ELSIF v_ticket_type.sale_ends_at IS NOT NULL AND v_ticket_type.sale_ends_at < NOW() THEN
        v_result := jsonb_build_object(
            'available', false,
            'reason', 'Sale has ended'
        );
    ELSIF v_available <= 0 THEN
        v_result := jsonb_build_object(
            'available', false,
            'reason', 'Sold out'
        );
    ELSIF v_available < p_quantity THEN
        v_result := jsonb_build_object(
            'available', false,
            'reason', 'Not enough tickets available',
            'available_quantity', v_available
        );
    ELSIF p_quantity > v_ticket_type.max_per_order THEN
        v_result := jsonb_build_object(
            'available', false,
            'reason', 'Exceeds maximum per order'
        );
    ELSIF p_quantity < v_ticket_type.min_per_order THEN
        v_result := jsonb_build_object(
            'available', false,
            'reason', 'Below minimum per order'
        );
    ELSE
        v_result := jsonb_build_object(
            'available', true,
            'available_quantity', v_available,
            'ticket_type', jsonb_build_object(
                'id', v_ticket_type.id,
                'name', v_ticket_type.name,
                'price', v_ticket_type.base_price,
                'currency', v_ticket_type.currency
            )
        );
    END IF;
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

ALTER FUNCTION ticketing.check_ticket_availability(p_ticket_type_id BIGINT, p_quantity INTEGER) OWNER TO osmi;

-- =============================================================================
-- 2. TABLAS
-- =============================================================================

-- =============================================================================
-- ticketing.venues
-- =============================================================================

CREATE TABLE ticketing.venues (
    id bigint NOT NULL,
    public_uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    description text,
    venue_type character varying(50) DEFAULT 'indoor'::character varying,
    address_line1 character varying(255) NOT NULL,
    address_line2 character varying(255),
    city character varying(100) NOT NULL,
    state character varying(100),
    postal_code character varying(20),
    country global.country_code NOT NULL,
    latitude numeric(10,8),
    longitude numeric(11,8),
    geolocation public.geography(Point,4326),
    capacity integer,
    seating_capacity integer,
    standing_capacity integer,
    facilities jsonb DEFAULT '[]'::jsonb,
    accessibility_features jsonb DEFAULT '[]'::jsonb,
    contact_email global.email_address,
    contact_phone global.phone_number,
    images jsonb DEFAULT '[]'::jsonb,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE SEQUENCE ticketing.venues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ticketing.venues_id_seq OWNED BY ticketing.venues.id;

ALTER TABLE ONLY ticketing.venues ALTER COLUMN id SET DEFAULT nextval('ticketing.venues_id_seq'::regclass);

-- =============================================================================
-- ticketing.organizers
-- =============================================================================

CREATE TABLE ticketing.organizers (
    id bigint NOT NULL,
    public_uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    description text,
    logo_url text,
    legal_name character varying(255),
    tax_id character varying(50),
    tax_id_type character varying(30),
    country global.country_code,
    contact_email global.email_address NOT NULL,
    contact_phone global.phone_number,
    address_line1 character varying(255),
    address_line2 character varying(255),
    city character varying(100),
    state character varying(100),
    postal_code character varying(20),
    is_verified boolean DEFAULT false,
    is_active boolean DEFAULT true,
    verification_status character varying(20) DEFAULT 'pending'::character varying,
    total_events integer DEFAULT 0,
    total_tickets_sold bigint DEFAULT 0,
    organizer_rating numeric(3,2) DEFAULT 0,
    rating_count integer DEFAULT 0,
    social_links jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    user_id bigint,
    approval_status character varying(20) DEFAULT 'pending'::character varying
);

CREATE SEQUENCE ticketing.organizers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ticketing.organizers_id_seq OWNED BY ticketing.organizers.id;

ALTER TABLE ONLY ticketing.organizers ALTER COLUMN id SET DEFAULT nextval('ticketing.organizers_id_seq'::regclass);

-- =============================================================================
-- ticketing.events
-- =============================================================================

CREATE TABLE ticketing.events (
    id bigint NOT NULL,
    public_uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    organizer_id bigint NOT NULL,
    primary_category_id bigint,
    venue_id bigint,
    slug character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    short_description character varying(500),
    description text,
    event_type character varying(30) DEFAULT 'in_person'::character varying,
    cover_image_url text,
    banner_image_url text,
    gallery_images jsonb DEFAULT '[]'::jsonb,
    timezone global.timezone_name DEFAULT 'UTC'::character varying NOT NULL,
    starts_at timestamp with time zone NOT NULL,
    ends_at timestamp with time zone NOT NULL,
    doors_open_at timestamp with time zone,
    doors_close_at timestamp with time zone,
    venue_name character varying(255),
    address_full text,
    city character varying(100),
    state character varying(100),
    country global.country_code,
    status ticketing.event_status DEFAULT 'draft'::character varying,
    visibility character varying(20) DEFAULT 'public'::character varying,
    is_featured boolean DEFAULT false,
    is_free boolean DEFAULT false,
    max_attendees integer,
    min_attendees integer DEFAULT 0,
    tags jsonb DEFAULT '[]'::jsonb,
    age_restriction integer,
    requires_approval boolean DEFAULT false,
    allow_reservations boolean DEFAULT true,
    reservation_duration_minutes integer DEFAULT 15,
    view_count integer DEFAULT 0,
    favorite_count integer DEFAULT 0,
    share_count integer DEFAULT 0,
    meta_title character varying(255),
    meta_description text,
    settings jsonb DEFAULT '{"require_id": false, "checkin_method": "qr_code", "allow_transfers": true, "allow_cancellations": true, "cancellation_deadline_hours": 24}'::jsonb,
    published_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    latitude numeric(10,8),
    longitude numeric(11,8),
    CONSTRAINT events_check CHECK ((ends_at > starts_at)),
    CONSTRAINT events_check1 CHECK (((max_attendees IS NULL) OR (max_attendees >= min_attendees)))
);

CREATE SEQUENCE ticketing.events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ticketing.events_id_seq OWNED BY ticketing.events.id;

ALTER TABLE ONLY ticketing.events ALTER COLUMN id SET DEFAULT nextval('ticketing.events_id_seq'::regclass);

-- =============================================================================
-- ticketing.categories
-- =============================================================================

CREATE TABLE ticketing.categories (
    id bigint NOT NULL,
    public_uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    event_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    slug character varying(100) NOT NULL,
    description text,
    icon character varying(50),
    color_hex character varying(7) DEFAULT '#3498db'::character varying,
    parent_id bigint,
    level integer DEFAULT 1,
    path character varying(500) DEFAULT ''::character varying,
    capacity integer DEFAULT 0 NOT NULL,
    total_events integer DEFAULT 0,
    total_tickets_sold bigint DEFAULT 0,
    total_revenue numeric(15,2) DEFAULT 0,
    is_active boolean DEFAULT true,
    is_featured boolean DEFAULT false,
    sort_order integer DEFAULT 0,
    meta_title character varying(255),
    meta_description text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE SEQUENCE ticketing.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ticketing.categories_id_seq OWNED BY ticketing.categories.id;

ALTER TABLE ONLY ticketing.categories ALTER COLUMN id SET DEFAULT nextval('ticketing.categories_id_seq'::regclass);


-- =============================================================================
-- ticketing.ticket_types
-- =============================================================================

CREATE TABLE ticketing.ticket_types (
    id bigint NOT NULL,
    public_uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    event_id bigint NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    ticket_class character varying(50) DEFAULT 'standard'::character varying,
    base_price numeric(12,2) NOT NULL,
    currency global.currency_code DEFAULT 'MXN'::character varying,
    tax_rate global.percentage DEFAULT 0.16,
    service_fee_type character varying(20) DEFAULT 'percentage'::character varying,
    service_fee_value numeric(10,2) DEFAULT 0,
    total_quantity integer NOT NULL,
    reserved_quantity integer DEFAULT 0,
    sold_quantity integer DEFAULT 0,
    max_per_order integer DEFAULT 10,
    min_per_order integer DEFAULT 1,
    sale_starts_at timestamp with time zone DEFAULT now(),
    sale_ends_at timestamp with time zone,
    is_active boolean DEFAULT true,
    requires_approval boolean DEFAULT false,
    is_hidden boolean DEFAULT false,
    sales_channel character varying(50) DEFAULT 'all'::character varying,
    benefits jsonb DEFAULT '[]'::jsonb,
    access_type character varying(50) DEFAULT 'general'::character varying,
    validation_rules jsonb DEFAULT '{"requires_id": false, "age_restriction": 0, "requires_membership": false}'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    available_quantity integer GENERATED ALWAYS AS (((total_quantity - sold_quantity) - reserved_quantity)) STORED,
    is_sold_out boolean GENERATED ALWAYS AS ((((total_quantity - sold_quantity) - reserved_quantity) <= 0)) STORED,
    CONSTRAINT ticket_types_base_price_check CHECK ((base_price >= (0)::numeric)),
    CONSTRAINT ticket_types_check CHECK (((sold_quantity + reserved_quantity) <= total_quantity)),
    CONSTRAINT ticket_types_check1 CHECK ((max_per_order >= min_per_order)),
    CONSTRAINT ticket_types_check2 CHECK (((sale_ends_at IS NULL) OR (sale_ends_at > sale_starts_at))),
    CONSTRAINT ticket_types_reserved_quantity_check CHECK ((reserved_quantity >= 0)),
    CONSTRAINT ticket_types_sold_quantity_check CHECK ((sold_quantity >= 0)),
    CONSTRAINT ticket_types_total_quantity_check CHECK ((total_quantity >= 0))
);

CREATE SEQUENCE ticketing.ticket_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ticketing.ticket_types_id_seq OWNED BY ticketing.ticket_types.id;

ALTER TABLE ONLY ticketing.ticket_types ALTER COLUMN id SET DEFAULT nextval('ticketing.ticket_types_id_seq'::regclass);

-- =============================================================================
-- ticketing.tickets
-- =============================================================================

CREATE TABLE ticketing.tickets (
    id bigint NOT NULL,
    public_uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    ticket_type_id bigint NOT NULL,
    event_id bigint NOT NULL,
    customer_id bigint,
    order_id bigint,
    code character varying(50) NOT NULL,
    secret_hash text NOT NULL,
    qr_code_data text,
    status ticketing.ticket_status DEFAULT 'available'::character varying,
    final_price numeric(12,2) NOT NULL,
    currency global.currency_code NOT NULL,
    tax_amount numeric(12,2) DEFAULT 0 NOT NULL,
    attendee_name character varying(255),
    attendee_email global.email_address,
    attendee_phone global.phone_number,
    checked_in_at timestamp with time zone,
    checked_in_by bigint,
    checkin_method character varying(50),
    checkin_location character varying(100),
    reserved_at timestamp with time zone,
    reserved_by bigint,
    reservation_expires_at timestamp with time zone,
    transfer_token uuid,
    transferred_from bigint,
    transferred_at timestamp with time zone,
    validation_count integer DEFAULT 0,
    last_validated_at timestamp with time zone,
    sold_at timestamp with time zone,
    cancelled_at timestamp with time zone,
    refunded_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT tickets_check CHECK (((status)::text = ANY ((ARRAY['available'::character varying, 'reserved'::character varying, 'sold'::character varying, 'checked_in'::character varying, 'cancelled'::character varying, 'refunded'::character varying, 'expired'::character varying])::text[]))),
    CONSTRAINT tickets_check1 CHECK (((checked_in_at IS NULL) OR (checked_in_at >= sold_at))),
    CONSTRAINT tickets_validation_count_check CHECK ((validation_count >= 0))
);

CREATE SEQUENCE ticketing.tickets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ticketing.tickets_id_seq OWNED BY ticketing.tickets.id;

ALTER TABLE ONLY ticketing.tickets ALTER COLUMN id SET DEFAULT nextval('ticketing.tickets_id_seq'::regclass);

-- =============================================================================
-- 3. CONSTRAINTS
-- =============================================================================

-- =============================================================================
-- ticketing.venues
-- =============================================================================

ALTER TABLE ONLY ticketing.venues
    ADD CONSTRAINT venues_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ticketing.venues
    ADD CONSTRAINT venues_public_uuid_key UNIQUE (public_uuid);

ALTER TABLE ONLY ticketing.venues
    ADD CONSTRAINT venues_slug_key UNIQUE (slug);

-- =============================================================================
-- ticketing.organizers
-- =============================================================================

ALTER TABLE ONLY ticketing.organizers
    ADD CONSTRAINT organizers_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ticketing.organizers
    ADD CONSTRAINT organizers_public_uuid_key UNIQUE (public_uuid);

ALTER TABLE ONLY ticketing.organizers
    ADD CONSTRAINT organizers_slug_key UNIQUE (slug);

ALTER TABLE ONLY ticketing.organizers
    ADD CONSTRAINT organizers_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);

-- =============================================================================
-- ticketing.events
-- =============================================================================

ALTER TABLE ONLY ticketing.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ticketing.events
    ADD CONSTRAINT events_public_uuid_key UNIQUE (public_uuid);

ALTER TABLE ONLY ticketing.events
    ADD CONSTRAINT events_slug_key UNIQUE (slug);

ALTER TABLE ONLY ticketing.events
    ADD CONSTRAINT events_organizer_id_fkey FOREIGN KEY (organizer_id) REFERENCES ticketing.organizers(id);

ALTER TABLE ONLY ticketing.events
    ADD CONSTRAINT events_venue_id_fkey FOREIGN KEY (venue_id) REFERENCES ticketing.venues(id);

-- =============================================================================
-- ticketing.categories
-- =============================================================================

ALTER TABLE ONLY ticketing.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ticketing.categories
    ADD CONSTRAINT categories_public_uuid_key UNIQUE (public_uuid);

ALTER TABLE ONLY ticketing.categories
    ADD CONSTRAINT unique_event_category_name UNIQUE (event_id, name);

ALTER TABLE ONLY ticketing.categories
    ADD CONSTRAINT unique_event_category_slug UNIQUE (event_id, slug);

ALTER TABLE ONLY ticketing.categories
    ADD CONSTRAINT fk_categories_event FOREIGN KEY (event_id) REFERENCES ticketing.events(public_uuid) ON DELETE CASCADE;

-- =============================================================================
-- ticketing.ticket_types
-- =============================================================================

ALTER TABLE ONLY ticketing.ticket_types
    ADD CONSTRAINT ticket_types_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ticketing.ticket_types
    ADD CONSTRAINT ticket_types_public_uuid_key UNIQUE (public_uuid);

ALTER TABLE ONLY ticketing.ticket_types
    ADD CONSTRAINT ticket_types_event_id_fkey FOREIGN KEY (event_id) REFERENCES ticketing.events(id) ON DELETE CASCADE;

-- =============================================================================
-- ticketing.tickets
-- =============================================================================

ALTER TABLE ONLY ticketing.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ticketing.tickets
    ADD CONSTRAINT tickets_public_uuid_key UNIQUE (public_uuid);

ALTER TABLE ONLY ticketing.tickets
    ADD CONSTRAINT tickets_code_unique UNIQUE (code);

-- Nota: tickets_code_key y tickets_code_unique son el mismo constraint en el schema.sql
-- Ambos son UNIQUE (code). Se mantiene solo tickets_code_unique.

ALTER TABLE ONLY ticketing.tickets
    ADD CONSTRAINT tickets_ticket_type_id_fkey FOREIGN KEY (ticket_type_id) REFERENCES ticketing.ticket_types(id);

ALTER TABLE ONLY ticketing.tickets
    ADD CONSTRAINT tickets_event_id_fkey FOREIGN KEY (event_id) REFERENCES ticketing.events(id);

ALTER TABLE ONLY ticketing.tickets
    ADD CONSTRAINT tickets_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES crm.customers(id);

ALTER TABLE ONLY ticketing.tickets
    ADD CONSTRAINT tickets_checked_in_by_fkey FOREIGN KEY (checked_in_by) REFERENCES auth.users(id);

ALTER TABLE ONLY ticketing.tickets
    ADD CONSTRAINT tickets_reserved_by_fkey FOREIGN KEY (reserved_by) REFERENCES auth.users(id);

ALTER TABLE ONLY ticketing.tickets
    ADD CONSTRAINT tickets_transferred_from_fkey FOREIGN KEY (transferred_from) REFERENCES crm.customers(id);

-- =============================================================================
-- 4. INDEXES
-- =============================================================================

-- =============================================================================
-- ticketing.venues
-- =============================================================================

CREATE INDEX idx_venues_slug ON ticketing.venues USING btree (slug);
CREATE INDEX idx_venues_country_city ON ticketing.venues USING btree (country, city);
CREATE INDEX idx_venues_geolocation ON ticketing.venues USING gist (geolocation);

-- =============================================================================
-- ticketing.organizers
-- =============================================================================

CREATE INDEX idx_organizers_slug ON ticketing.organizers USING btree (slug);
CREATE INDEX idx_organizers_is_active ON ticketing.organizers USING btree (is_active);

-- =============================================================================
-- ticketing.categories
-- =============================================================================

CREATE INDEX idx_categories_event_id ON ticketing.categories USING btree (event_id);
CREATE INDEX idx_categories_public_uuid ON ticketing.categories USING btree (public_uuid);
CREATE INDEX idx_categories_is_active ON ticketing.categories USING btree (is_active) WHERE (is_active = true);

-- =============================================================================
-- ticketing.events
-- =============================================================================

CREATE INDEX idx_events_slug ON ticketing.events USING btree (slug);
CREATE INDEX idx_events_organizer_id ON ticketing.events USING btree (organizer_id);
CREATE INDEX idx_events_status ON ticketing.events USING btree (status);
CREATE INDEX idx_events_starts_at ON ticketing.events USING btree (starts_at);
CREATE INDEX idx_events_country_city ON ticketing.events USING btree (country, city);
CREATE INDEX idx_events_is_featured ON ticketing.events USING btree (is_featured);

-- =============================================================================
-- ticketing.ticket_types
-- =============================================================================

CREATE INDEX idx_ticket_types_event_id ON ticketing.ticket_types USING btree (event_id);
CREATE INDEX idx_ticket_types_is_active ON ticketing.ticket_types USING btree (is_active);
CREATE INDEX idx_ticket_types_sale_dates ON ticketing.ticket_types USING btree (sale_starts_at, sale_ends_at);
CREATE INDEX idx_ticket_types_is_sold_out ON ticketing.ticket_types USING btree (is_sold_out);

-- =============================================================================
-- ticketing.tickets
-- =============================================================================

CREATE INDEX idx_tickets_code ON ticketing.tickets USING btree (code);
CREATE INDEX idx_tickets_event_id_status ON ticketing.tickets USING btree (event_id, status);
CREATE INDEX idx_tickets_customer_id ON ticketing.tickets USING btree (customer_id);
CREATE INDEX idx_tickets_order_id ON ticketing.tickets USING btree (order_id);
CREATE INDEX idx_tickets_reservation_expires ON ticketing.tickets USING btree (reservation_expires_at) WHERE ((status)::text = 'reserved'::text);
CREATE INDEX idx_tickets_checked_in_at ON ticketing.tickets USING btree (checked_in_at) WHERE (checked_in_at IS NOT NULL);

-- =============================================================================
-- 5. TRIGGERS
-- =============================================================================

-- =============================================================================
-- ticketing.venues
-- =============================================================================

CREATE TRIGGER trg_update_venues BEFORE UPDATE ON ticketing.venues FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();

-- =============================================================================
-- ticketing.organizers
-- =============================================================================

CREATE TRIGGER trg_update_organizers BEFORE UPDATE ON ticketing.organizers FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();

-- =============================================================================
-- ticketing.categories
-- =============================================================================

-- Nota: categories usa public.update_updated_at() en el schema.sql original
-- Reemplazamos con auth.update_updated_at() para consistencia
CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON ticketing.categories FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();

-- =============================================================================
-- ticketing.events
-- =============================================================================

CREATE TRIGGER trg_update_events BEFORE UPDATE ON ticketing.events FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();

-- =============================================================================
-- ticketing.ticket_types
-- =============================================================================

CREATE TRIGGER trg_update_ticket_types BEFORE UPDATE ON ticketing.ticket_types FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();

-- =============================================================================
-- ticketing.tickets
-- =============================================================================

CREATE TRIGGER trg_update_tickets BEFORE UPDATE ON ticketing.tickets FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();

CREATE TRIGGER trg_generate_ticket_code BEFORE INSERT ON ticketing.tickets FOR EACH ROW EXECUTE FUNCTION ticketing.generate_ticket_code();

-- =============================================================================
-- FIN DE LA MIGRACIÓN 000004
-- =============================================================================