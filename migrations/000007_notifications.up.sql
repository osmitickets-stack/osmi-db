-- =============================================================================
-- OSMI DATABASE
-- Migración 000007 — Notifications Schema
-- =============================================================================
--
-- Esta migración crea el módulo de Notificaciones:
--   ✅ notifications.templates
--   ✅ notifications.messages
--   ✅ Constraints (PK, UNIQUE, FK, CHECK)
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
-- notifications.templates
-- =============================================================================

CREATE TABLE notifications.templates (
    id bigint NOT NULL,
    code character varying(100) NOT NULL,
    name character varying(255) NOT NULL,
    subject_translations jsonb DEFAULT '{"en": "", "es": ""}'::jsonb NOT NULL,
    body_translations jsonb DEFAULT '{"en": "", "es": ""}'::jsonb NOT NULL,
    available_variables text[] DEFAULT '{}'::text[],
    channel character varying(20) NOT NULL,
    is_active boolean DEFAULT true,
    priority integer DEFAULT 1,
    category character varying(50) DEFAULT 'general'::character varying,
    tags text[] DEFAULT '{}'::text[],
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE SEQUENCE notifications.templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE notifications.templates_id_seq OWNED BY notifications.templates.id;

ALTER TABLE ONLY notifications.templates ALTER COLUMN id SET DEFAULT nextval('notifications.templates_id_seq'::regclass);

-- =============================================================================
-- notifications.messages
-- =============================================================================

CREATE TABLE notifications.messages (
    id bigint NOT NULL,
    template_id bigint,
    recipient_email global.email_address,
    recipient_phone global.phone_number,
    recipient_name character varying(255),
    recipient_user_id bigint,
    recipient_language character varying(10) DEFAULT 'es'::character varying,
    subject character varying(500) NOT NULL,
    body text NOT NULL,
    channel character varying(20) NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying,
    attempts integer DEFAULT 0,
    max_attempts integer DEFAULT 5,
    next_retry_at timestamp with time zone,
    retry_delay integer DEFAULT 300,
    backoff_factor numeric(3,2) DEFAULT 1.5,
    last_error text,
    error_code character varying(50),
    error_history jsonb DEFAULT '[]'::jsonb,
    provider_message_id character varying(255),
    provider_response jsonb,
    context_data jsonb DEFAULT '{}'::jsonb,
    scheduled_for timestamp with time zone DEFAULT now(),
    sent_at timestamp with time zone,
    delivered_at timestamp with time zone,
    open_count integer DEFAULT 0,
    click_count integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT messages_attempts_check CHECK ((attempts >= 0)),
    CONSTRAINT messages_max_attempts_check CHECK ((max_attempts >= 1))
);

CREATE SEQUENCE notifications.messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE notifications.messages_id_seq OWNED BY notifications.messages.id;

ALTER TABLE ONLY notifications.messages ALTER COLUMN id SET DEFAULT nextval('notifications.messages_id_seq'::regclass);

-- =============================================================================
-- 2. CONSTRAINTS
-- =============================================================================

-- =============================================================================
-- notifications.templates
-- =============================================================================

ALTER TABLE ONLY notifications.templates
    ADD CONSTRAINT templates_pkey PRIMARY KEY (id);

ALTER TABLE ONLY notifications.templates
    ADD CONSTRAINT templates_code_key UNIQUE (code);

-- =============================================================================
-- notifications.messages
-- =============================================================================

ALTER TABLE ONLY notifications.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);

ALTER TABLE ONLY notifications.messages
    ADD CONSTRAINT messages_template_id_fkey FOREIGN KEY (template_id) REFERENCES notifications.templates(id);

ALTER TABLE ONLY notifications.messages
    ADD CONSTRAINT messages_recipient_user_id_fkey FOREIGN KEY (recipient_user_id) REFERENCES auth.users(id);

-- =============================================================================
-- 3. INDEXES
-- =============================================================================

-- =============================================================================
-- notifications.messages
-- =============================================================================

CREATE INDEX idx_messages_status ON notifications.messages USING btree (status);
CREATE INDEX idx_messages_recipient_email ON notifications.messages USING btree (recipient_email);
CREATE INDEX idx_messages_scheduled_for ON notifications.messages USING btree (scheduled_for);
CREATE INDEX idx_messages_next_retry_at ON notifications.messages USING btree (next_retry_at) WHERE ((status)::text = ANY ((ARRAY['failed'::character varying, 'retrying'::character varying])::text[]));

-- =============================================================================
-- 4. TRIGGERS
-- =============================================================================

-- =============================================================================
-- notifications.templates
-- =============================================================================

CREATE TRIGGER trg_update_templates BEFORE UPDATE ON notifications.templates FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();

-- =============================================================================
-- notifications.messages
-- =============================================================================

CREATE TRIGGER trg_update_messages BEFORE UPDATE ON notifications.messages FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();

-- =============================================================================
-- FIN DE LA MIGRACIÓN 000007
-- =============================================================================