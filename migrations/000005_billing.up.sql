-- =============================================================================
-- OSMI DATABASE
-- Migración 000005 — Billing Schema
-- =============================================================================
--
-- Esta migración crea el módulo de Facturación:
--   ✅ billing.payment_providers
--   ✅ billing.orders
--   ✅ billing.order_items
--   ✅ billing.payments
--   ✅ billing.refunds
--   ✅ Constraints (PK, UNIQUE, FK, CHECK)
--   ✅ Indexes
--   ✅ Triggers
--
-- Dependencias:
--   - 000001_initial_schema (dominios, función update_updated_at)
--   - 000002_auth (auth.users)
--   - 000003_crm (crm.customers)
--   - 000004_ticketing (ticketing.ticket_types)
--
-- =============================================================================

-- =============================================================================
-- 1. TABLAS
-- =============================================================================

-- =============================================================================
-- billing.payment_providers
-- =============================================================================

CREATE TABLE billing.payment_providers (
    id smallint NOT NULL,
    code character varying(20) NOT NULL,
    name character varying(100) NOT NULL,
    provider_type character varying(30) DEFAULT 'gateway'::character varying,
    is_active boolean DEFAULT true,
    is_online boolean DEFAULT true,
    supports_refunds boolean DEFAULT true,
    min_amount numeric(10,2) DEFAULT 0.01,
    max_amount numeric(15,2),
    supported_currencies character varying(3)[] DEFAULT '{MXN,USD}'::character varying[],
    supported_countries global.country_code[] DEFAULT '{MX}'::global.country_code[],
    config jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE SEQUENCE billing.payment_providers_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE billing.payment_providers_id_seq OWNED BY billing.payment_providers.id;

ALTER TABLE ONLY billing.payment_providers ALTER COLUMN id SET DEFAULT nextval('billing.payment_providers_id_seq'::regclass);

-- =============================================================================
-- billing.orders
-- =============================================================================

CREATE TABLE billing.orders (
    id bigint NOT NULL,
    public_uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    customer_id bigint,
    customer_email global.email_address NOT NULL,
    customer_name character varying(255),
    customer_phone global.phone_number,
    subtotal numeric(15,2) NOT NULL,
    tax_amount numeric(15,2) DEFAULT 0 NOT NULL,
    service_fee_amount numeric(15,2) DEFAULT 0 NOT NULL,
    discount_amount numeric(15,2) DEFAULT 0 NOT NULL,
    total_amount numeric(15,2) NOT NULL,
    currency global.currency_code DEFAULT 'MXN'::character varying,
    status billing.payment_status DEFAULT 'pending'::character varying,
    order_type character varying(20) DEFAULT 'ticket'::character varying,
    is_reservation boolean DEFAULT false,
    reservation_expires_at timestamp with time zone,
    payment_method character varying(50),
    payment_provider_id smallint,
    invoice_required boolean DEFAULT false,
    invoice_generated boolean DEFAULT false,
    invoice_number character varying(100),
    promotion_code character varying(50),
    promotion_id bigint,
    metadata jsonb DEFAULT '{}'::jsonb,
    notes text,
    ip_address inet,
    user_agent text,
    expires_at timestamp with time zone,
    paid_at timestamp with time zone,
    cancelled_at timestamp with time zone,
    refunded_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    payment_status character varying(20) DEFAULT 'pending'::character varying,
    CONSTRAINT orders_check CHECK ((total_amount = (((subtotal + tax_amount) + service_fee_amount) - discount_amount))),
    CONSTRAINT orders_check1 CHECK ((discount_amount <= subtotal)),
    CONSTRAINT orders_discount_amount_check CHECK ((discount_amount >= (0)::numeric)),
    CONSTRAINT orders_service_fee_amount_check CHECK ((service_fee_amount >= (0)::numeric)),
    CONSTRAINT orders_subtotal_check CHECK ((subtotal >= (0)::numeric)),
    CONSTRAINT orders_tax_amount_check CHECK ((tax_amount >= (0)::numeric)),
    CONSTRAINT orders_total_amount_check CHECK ((total_amount >= (0)::numeric))
);

CREATE SEQUENCE billing.orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE billing.orders_id_seq OWNED BY billing.orders.id;

ALTER TABLE ONLY billing.orders ALTER COLUMN id SET DEFAULT nextval('billing.orders_id_seq'::regclass);

-- =============================================================================
-- billing.order_items
-- =============================================================================

CREATE TABLE billing.order_items (
    id bigint NOT NULL,
    order_id bigint NOT NULL,
    ticket_type_id bigint NOT NULL,
    quantity integer NOT NULL,
    unit_price numeric(12,2) NOT NULL,
    total_price numeric(12,2) NOT NULL,
    currency global.currency_code DEFAULT 'MXN'::character varying,
    base_price numeric(12,2) NOT NULL,
    tax_amount numeric(12,2) DEFAULT 0,
    service_fee_amount numeric(12,2) DEFAULT 0,
    discount_amount numeric(12,2) DEFAULT 0,
    ticket_ids jsonb DEFAULT '[]'::jsonb,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT order_items_quantity_check CHECK ((quantity > 0)),
    CONSTRAINT order_items_total_price_check CHECK ((total_price >= (0)::numeric)),
    CONSTRAINT order_items_unit_price_check CHECK ((unit_price >= (0)::numeric))
);

CREATE SEQUENCE billing.order_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE billing.order_items_id_seq OWNED BY billing.order_items.id;

ALTER TABLE ONLY billing.order_items ALTER COLUMN id SET DEFAULT nextval('billing.order_items_id_seq'::regclass);

-- =============================================================================
-- billing.payments
-- =============================================================================

CREATE TABLE billing.payments (
    id bigint NOT NULL,
    order_id bigint NOT NULL,
    provider_id smallint NOT NULL,
    provider_transaction_id character varying(255),
    provider_session_id character varying(255),
    amount numeric(15,2) NOT NULL,
    currency global.currency_code NOT NULL,
    exchange_rate numeric(15,6) DEFAULT 1.0,
    status character varying(50) NOT NULL,
    payment_method character varying(50),
    payment_method_details jsonb,
    attempts integer DEFAULT 0,
    max_attempts integer DEFAULT 3,
    next_retry_at timestamp with time zone,
    last_error text,
    error_code character varying(50),
    ip_address inet,
    user_agent text,
    processed_at timestamp with time zone,
    refunded_at timestamp with time zone,
    cancelled_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT payments_amount_check CHECK ((amount > (0)::numeric)),
    CONSTRAINT payments_attempts_check CHECK ((attempts >= 0)),
    CONSTRAINT payments_max_attempts_check CHECK ((max_attempts >= 1))
);

CREATE SEQUENCE billing.payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE billing.payments_id_seq OWNED BY billing.payments.id;

ALTER TABLE ONLY billing.payments ALTER COLUMN id SET DEFAULT nextval('billing.payments_id_seq'::regclass);

-- =============================================================================
-- billing.refunds
-- =============================================================================

CREATE TABLE billing.refunds (
    id bigint NOT NULL,
    payment_id bigint,
    order_id bigint,
    refund_reason character varying(100),
    refund_amount numeric(15,2) NOT NULL,
    currency global.currency_code NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying,
    provider_refund_id character varying(255),
    requested_by bigint,
    approved_by bigint,
    requested_at timestamp with time zone DEFAULT now(),
    processed_at timestamp with time zone,
    completed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT refunds_refund_amount_check CHECK ((refund_amount > (0)::numeric))
);

CREATE SEQUENCE billing.refunds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE billing.refunds_id_seq OWNED BY billing.refunds.id;

ALTER TABLE ONLY billing.refunds ALTER COLUMN id SET DEFAULT nextval('billing.refunds_id_seq'::regclass);

-- =============================================================================
-- 2. CONSTRAINTS
-- =============================================================================

-- =============================================================================
-- billing.payment_providers
-- =============================================================================

ALTER TABLE ONLY billing.payment_providers
    ADD CONSTRAINT payment_providers_pkey PRIMARY KEY (id);

ALTER TABLE ONLY billing.payment_providers
    ADD CONSTRAINT payment_providers_code_key UNIQUE (code);

-- =============================================================================
-- billing.orders
-- =============================================================================

ALTER TABLE ONLY billing.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);

ALTER TABLE ONLY billing.orders
    ADD CONSTRAINT orders_public_uuid_key UNIQUE (public_uuid);

ALTER TABLE ONLY billing.orders
    ADD CONSTRAINT orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES crm.customers(id);

ALTER TABLE ONLY billing.orders
    ADD CONSTRAINT orders_payment_provider_id_fkey FOREIGN KEY (payment_provider_id) REFERENCES billing.payment_providers(id);

-- =============================================================================
-- billing.order_items
-- =============================================================================

ALTER TABLE ONLY billing.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);

ALTER TABLE ONLY billing.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES billing.orders(id) ON DELETE CASCADE;

ALTER TABLE ONLY billing.order_items
    ADD CONSTRAINT order_items_ticket_type_id_fkey FOREIGN KEY (ticket_type_id) REFERENCES ticketing.ticket_types(id);

-- =============================================================================
-- billing.payments
-- =============================================================================

ALTER TABLE ONLY billing.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);

ALTER TABLE ONLY billing.payments
    ADD CONSTRAINT payments_order_id_fkey FOREIGN KEY (order_id) REFERENCES billing.orders(id);

ALTER TABLE ONLY billing.payments
    ADD CONSTRAINT payments_provider_id_fkey FOREIGN KEY (provider_id) REFERENCES billing.payment_providers(id);

-- =============================================================================
-- billing.refunds
-- =============================================================================

ALTER TABLE ONLY billing.refunds
    ADD CONSTRAINT refunds_pkey PRIMARY KEY (id);

ALTER TABLE ONLY billing.refunds
    ADD CONSTRAINT refunds_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES billing.payments(id);

ALTER TABLE ONLY billing.refunds
    ADD CONSTRAINT refunds_order_id_fkey FOREIGN KEY (order_id) REFERENCES billing.orders(id);

ALTER TABLE ONLY billing.refunds
    ADD CONSTRAINT refunds_requested_by_fkey FOREIGN KEY (requested_by) REFERENCES auth.users(id);

ALTER TABLE ONLY billing.refunds
    ADD CONSTRAINT refunds_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES auth.users(id);

-- =============================================================================
-- 3. INDEXES
-- =============================================================================

-- =============================================================================
-- billing.orders
-- =============================================================================

CREATE INDEX idx_orders_customer_id ON billing.orders USING btree (customer_id);
CREATE INDEX idx_orders_status ON billing.orders USING btree (status);
CREATE INDEX idx_orders_created_at ON billing.orders USING btree (created_at);
CREATE INDEX idx_orders_customer_email ON billing.orders USING btree (customer_email);
CREATE INDEX idx_orders_reservation_expires ON billing.orders USING btree (reservation_expires_at) WHERE (is_reservation = true);

-- =============================================================================
-- billing.order_items
-- =============================================================================

CREATE INDEX idx_order_items_order_id ON billing.order_items USING btree (order_id);
CREATE INDEX idx_order_items_ticket_type_id ON billing.order_items USING btree (ticket_type_id);

-- =============================================================================
-- billing.payments
-- =============================================================================

CREATE INDEX idx_payments_order_id ON billing.payments USING btree (order_id);
CREATE INDEX idx_payments_status ON billing.payments USING btree (status);
CREATE INDEX idx_payments_provider_transaction_id ON billing.payments USING btree (provider_transaction_id);

-- =============================================================================
-- 4. TRIGGERS
-- =============================================================================

-- =============================================================================
-- billing.payment_providers
-- =============================================================================

CREATE TRIGGER trg_update_payment_providers BEFORE UPDATE ON billing.payment_providers FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();

-- =============================================================================
-- billing.orders
-- =============================================================================

CREATE TRIGGER trg_update_orders BEFORE UPDATE ON billing.orders FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();

-- =============================================================================
-- billing.order_items
-- =============================================================================

CREATE TRIGGER trg_update_order_items BEFORE UPDATE ON billing.order_items FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();

-- =============================================================================
-- billing.payments
-- =============================================================================

CREATE TRIGGER trg_update_payments BEFORE UPDATE ON billing.payments FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();

-- =============================================================================
-- billing.refunds
-- =============================================================================

CREATE TRIGGER trg_update_refunds BEFORE UPDATE ON billing.refunds FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();

-- =============================================================================
-- FIN DE LA MIGRACIÓN 000005
-- =============================================================================