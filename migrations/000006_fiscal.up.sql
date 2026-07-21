-- =============================================================================
-- OSMI DATABASE
-- Migración 000006 — Fiscal Schema
-- =============================================================================
--
-- Esta migración crea el módulo Fiscal (Facturación electrónica):
--   ✅ fiscal.country_config
--   ✅ fiscal.invoices
--   ✅ Constraints (PK, UNIQUE, FK, CHECK)
--   ✅ Triggers
--
-- Dependencias:
--   - 000001_initial_schema (dominios, función update_updated_at)
--   - 000003_crm (crm.customers)
--   - 000005_billing (billing.orders)
--
-- =============================================================================

-- =============================================================================
-- 1. TABLAS
-- =============================================================================

-- =============================================================================
-- fiscal.country_config
-- =============================================================================

CREATE TABLE fiscal.country_config (
    id smallint NOT NULL,
    country_code global.country_code NOT NULL,
    country_name character varying(100) NOT NULL,
    tax_system character varying(50),
    default_tax_rate global.percentage,
    tax_inclusive_default boolean DEFAULT true,
    country_specific_settings jsonb DEFAULT '{}'::jsonb NOT NULL,
    mx_rfc_validation_regex text,
    mx_cfdi_required boolean DEFAULT false,
    mx_cfdi_formas_pago jsonb DEFAULT '["01", "04", "28"]'::jsonb,
    us_ein_validation_regex text,
    us_requires_1099 boolean DEFAULT false,
    eu_vat_validation_regex text,
    eu_vat_reverse_charge boolean DEFAULT false,
    invoice_required boolean DEFAULT false,
    invoice_sequence_format character varying(100),
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE SEQUENCE fiscal.country_config_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE fiscal.country_config_id_seq OWNED BY fiscal.country_config.id;

ALTER TABLE ONLY fiscal.country_config ALTER COLUMN id SET DEFAULT nextval('fiscal.country_config_id_seq'::regclass);

-- =============================================================================
-- fiscal.invoices
-- =============================================================================

CREATE TABLE fiscal.invoices (
    id bigint NOT NULL,
    invoice_uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    order_id bigint,
    customer_id bigint,
    invoice_number character varying(100) NOT NULL,
    invoice_series character varying(20),
    invoice_date date NOT NULL,
    invoice_currency global.currency_code NOT NULL,
    subtotal numeric(15,2) NOT NULL,
    tax_amount numeric(15,2) DEFAULT 0 NOT NULL,
    total_amount numeric(15,2) NOT NULL,
    status character varying(20) DEFAULT 'draft'::character varying,
    payment_status character varying(20) DEFAULT 'pending'::character varying,
    country_specific_data jsonb DEFAULT '{}'::jsonb,
    mx_cfdi_uuid uuid,
    mx_cfdi_xml text,
    mx_cfdi_sello text,
    mx_cfdi_certificado text,
    mx_cfdi_cadena_original text,
    mx_cfdi_qr_code text,
    tax_breakdown jsonb DEFAULT '[]'::jsonb,
    payment_breakdown jsonb DEFAULT '[]'::jsonb,
    issued_at timestamp with time zone,
    cancelled_at timestamp with time zone,
    paid_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE SEQUENCE fiscal.invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE fiscal.invoices_id_seq OWNED BY fiscal.invoices.id;

ALTER TABLE ONLY fiscal.invoices ALTER COLUMN id SET DEFAULT nextval('fiscal.invoices_id_seq'::regclass);

-- =============================================================================
-- 2. CONSTRAINTS
-- =============================================================================

-- =============================================================================
-- fiscal.country_config
-- =============================================================================

ALTER TABLE ONLY fiscal.country_config
    ADD CONSTRAINT country_config_pkey PRIMARY KEY (id);

ALTER TABLE ONLY fiscal.country_config
    ADD CONSTRAINT country_config_country_code_key UNIQUE (country_code);

-- =============================================================================
-- fiscal.invoices
-- =============================================================================

ALTER TABLE ONLY fiscal.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);

ALTER TABLE ONLY fiscal.invoices
    ADD CONSTRAINT invoices_invoice_uuid_key UNIQUE (invoice_uuid);

ALTER TABLE ONLY fiscal.invoices
    ADD CONSTRAINT invoices_order_id_fkey FOREIGN KEY (order_id) REFERENCES billing.orders(id);

ALTER TABLE ONLY fiscal.invoices
    ADD CONSTRAINT invoices_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES crm.customers(id);

-- =============================================================================
-- 3. TRIGGERS
-- =============================================================================

-- =============================================================================
-- fiscal.country_config
-- =============================================================================

CREATE TRIGGER trg_update_country_config BEFORE UPDATE ON fiscal.country_config FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();

-- =============================================================================
-- fiscal.invoices
-- =============================================================================

CREATE TRIGGER trg_update_invoices BEFORE UPDATE ON fiscal.invoices FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();

-- =============================================================================
-- FIN DE LA MIGRACIÓN 000006
-- =============================================================================