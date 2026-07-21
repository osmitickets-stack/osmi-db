-- =============================================================================
-- OSMI DATABASE
-- Migración 000010 — Integration Schema
-- =============================================================================
--
-- Esta migración crea el módulo de Integración:
--   ✅ integration.webhooks
--   ✅ integration.api_calls
--   ✅ Constraints (PK, UNIQUE, FK, CHECK)
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
-- integration.webhooks
-- =============================================================================

CREATE TABLE integration.webhooks (
    id bigint NOT NULL,
    public_uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    provider character varying(50) NOT NULL,
    event_type character varying(100) NOT NULL,
    target_url character varying(500) NOT NULL,
    secret_token text,
    signature_header character varying(100),
    is_active boolean DEFAULT true,
    last_triggered_at timestamp with time zone,
    config jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE SEQUENCE integration.webhooks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE integration.webhooks_id_seq OWNED BY integration.webhooks.id;

ALTER TABLE ONLY integration.webhooks ALTER COLUMN id SET DEFAULT nextval('integration.webhooks_id_seq'::regclass);

-- =============================================================================
-- integration.api_calls
-- =============================================================================

CREATE TABLE integration.api_calls (
    id bigint NOT NULL,
    provider character varying(50) NOT NULL,
    endpoint character varying(500) NOT NULL,
    method character varying(10) NOT NULL,
    request_body jsonb,
    request_headers jsonb,
    response_body jsonb,
    response_headers jsonb,
    response_status integer,
    response_time_ms integer,
    retry_count integer DEFAULT 0,
    success boolean DEFAULT true,
    error_message text,
    user_id bigint,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT api_calls_method_check CHECK (((method)::text = ANY ((ARRAY['GET'::character varying, 'POST'::character varying, 'PUT'::character varying, 'DELETE'::character varying, 'PATCH'::character varying])::text[])))
);

CREATE SEQUENCE integration.api_calls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE integration.api_calls_id_seq OWNED BY integration.api_calls.id;

ALTER TABLE ONLY integration.api_calls ALTER COLUMN id SET DEFAULT nextval('integration.api_calls_id_seq'::regclass);

-- =============================================================================
-- 2. CONSTRAINTS
-- =============================================================================

-- =============================================================================
-- integration.webhooks
-- =============================================================================

ALTER TABLE ONLY integration.webhooks
    ADD CONSTRAINT webhooks_pkey PRIMARY KEY (id);

ALTER TABLE ONLY integration.webhooks
    ADD CONSTRAINT webhooks_public_uuid_key UNIQUE (public_uuid);

-- =============================================================================
-- integration.api_calls
-- =============================================================================

ALTER TABLE ONLY integration.api_calls
    ADD CONSTRAINT api_calls_pkey PRIMARY KEY (id);

ALTER TABLE ONLY integration.api_calls
    ADD CONSTRAINT api_calls_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);

-- =============================================================================
-- 3. TRIGGERS
-- =============================================================================

-- =============================================================================
-- integration.webhooks
-- =============================================================================

CREATE TRIGGER trg_update_webhooks BEFORE UPDATE ON integration.webhooks FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();

-- =============================================================================
-- integration.api_calls
-- =============================================================================

-- Nota: api_calls NO tiene trigger de updated_at en el schema.sql original
-- porque es una tabla de auditoría/historial. No se incluye trigger.

-- =============================================================================
-- FIN DE LA MIGRACIÓN 000010
-- =============================================================================