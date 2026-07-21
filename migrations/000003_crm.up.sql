-- =============================================================================
-- OSMI DATABASE
-- Migración 000003 — CRM Schema
-- =============================================================================
--
-- Esta migración crea el módulo de CRM (Customer Relationship Management):
--   ✅ crm.customers
--   ✅ Constraints (PK, UNIQUE, FK)
--   ✅ Indexes
--   ✅ Triggers
--
-- Dependencias:
--   - 000001_initial_schema (dominios, función update_updated_at)
--   - 000002_auth (auth.users)
--
-- =============================================================================

-- =============================================================================
-- 1. TABLAS
-- =============================================================================

-- =============================================================================
-- crm.customers
-- =============================================================================

CREATE TABLE crm.customers (
    id bigint NOT NULL,
    public_uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id bigint,
    full_name character varying(255) NOT NULL,
    email global.email_address NOT NULL,
    phone global.phone_number,
    company_name character varying(255),
    address_line1 character varying(255),
    address_line2 character varying(255),
    city character varying(100),
    state character varying(100),
    postal_code character varying(20),
    country global.country_code,
    tax_id character varying(50),
    tax_id_type character varying(30) DEFAULT 'other'::character varying,
    tax_name character varying(255),
    requires_invoice boolean DEFAULT false,
    communication_preferences jsonb DEFAULT '{"sms": false, "push": true, "email": true}'::jsonb,
    total_spent numeric(15,2) DEFAULT 0,
    total_orders integer DEFAULT 0,
    total_tickets integer DEFAULT 0,
    avg_order_value numeric(10,2) DEFAULT 0,
    first_order_at timestamp with time zone,
    last_order_at timestamp with time zone,
    last_purchase_at timestamp with time zone,
    is_active boolean DEFAULT true,
    is_vip boolean DEFAULT false,
    vip_since timestamp with time zone,
    customer_segment character varying(50) DEFAULT 'new'::character varying,
    lifetime_value numeric(15,2) DEFAULT 0,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE SEQUENCE crm.customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE crm.customers_id_seq OWNED BY crm.customers.id;

ALTER TABLE ONLY crm.customers ALTER COLUMN id SET DEFAULT nextval('crm.customers_id_seq'::regclass);

-- =============================================================================
-- 2. CONSTRAINTS
-- =============================================================================

ALTER TABLE ONLY crm.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);

ALTER TABLE ONLY crm.customers
    ADD CONSTRAINT customers_public_uuid_key UNIQUE (public_uuid);

ALTER TABLE ONLY crm.customers
    ADD CONSTRAINT customers_user_id_key UNIQUE (user_id);

ALTER TABLE ONLY crm.customers
    ADD CONSTRAINT customers_email_key UNIQUE (email);

ALTER TABLE ONLY crm.customers
    ADD CONSTRAINT customers_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);

-- =============================================================================
-- 3. INDEXES
-- =============================================================================

CREATE INDEX idx_customers_email ON crm.customers USING btree (email);
CREATE INDEX idx_customers_user_id ON crm.customers USING btree (user_id);
CREATE INDEX idx_customers_is_active ON crm.customers USING btree (is_active);
CREATE INDEX idx_customers_country ON crm.customers USING btree (country);
CREATE INDEX idx_customers_created_at ON crm.customers USING btree (created_at);

-- =============================================================================
-- 4. TRIGGERS
-- =============================================================================

-- Nota: En el schema.sql original, crm.customers tiene 2 triggers que hacen lo mismo.
-- Este trigger usa auth.update_updated_at() (la función compartida).
-- El trigger redundante (trg_customers_update) usando public.update_updated_at()
-- se omite porque ya existe este trigger.

CREATE TRIGGER trg_update_customers BEFORE UPDATE ON crm.customers FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();

-- =============================================================================
-- FIN DE LA MIGRACIÓN 000003
-- =============================================================================