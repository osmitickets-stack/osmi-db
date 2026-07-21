-- =============================================================================
-- OSMI DATABASE
-- Migración 000009 — Audit Schema
-- =============================================================================
--
-- Esta migración crea el módulo de Auditoría:
--   ✅ audit.data_changes
--   ✅ audit.security_logs
--   ✅ audit.stripe_events
--   ✅ Constraints (PK, UNIQUE, FK, CHECK)
--   ✅ Indexes
--
-- Dependencias:
--   - 000001_initial_schema (dominios, función update_updated_at)
--   - 000002_auth (auth.users)
--
-- NOTA: Este schema NO tiene triggers de updated_at porque las tablas
--       son de auditoría y no deben modificar sus timestamps automáticamente.
--
-- =============================================================================

-- =============================================================================
-- 1. TABLAS
-- =============================================================================

-- =============================================================================
-- audit.data_changes
-- =============================================================================

CREATE TABLE audit.data_changes (
    id bigint NOT NULL,
    table_name character varying(100) NOT NULL,
    record_id bigint NOT NULL,
    operation character varying(10) NOT NULL,
    old_data jsonb,
    new_data jsonb,
    changed_fields text[],
    user_id bigint,
    ip_address inet,
    user_agent text,
    request_path character varying(500),
    changed_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT data_changes_operation_check CHECK (((operation)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);

CREATE SEQUENCE audit.data_changes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE audit.data_changes_id_seq OWNED BY audit.data_changes.id;

ALTER TABLE ONLY audit.data_changes ALTER COLUMN id SET DEFAULT nextval('audit.data_changes_id_seq'::regclass);

-- =============================================================================
-- audit.security_logs
-- =============================================================================

CREATE TABLE audit.security_logs (
    id bigint NOT NULL,
    event_type character varying(50) NOT NULL,
    severity character varying(20) NOT NULL,
    description text NOT NULL,
    user_id bigint,
    target_user_id bigint,
    ip_address inet,
    user_agent text,
    request_path character varying(500),
    details jsonb,
    occurred_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT security_logs_severity_check CHECK (((severity)::text = ANY ((ARRAY['low'::character varying, 'medium'::character varying, 'high'::character varying, 'critical'::character varying])::text[])))
);

CREATE SEQUENCE audit.security_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE audit.security_logs_id_seq OWNED BY audit.security_logs.id;

ALTER TABLE ONLY audit.security_logs ALTER COLUMN id SET DEFAULT nextval('audit.security_logs_id_seq'::regclass);

-- =============================================================================
-- audit.stripe_events
-- =============================================================================

CREATE TABLE audit.stripe_events (
    id bigint NOT NULL,
    event_id character varying(255) NOT NULL,
    event_type character varying(100) NOT NULL,
    payload jsonb NOT NULL,
    processed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE SEQUENCE audit.stripe_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE audit.stripe_events_id_seq OWNED BY audit.stripe_events.id;

ALTER TABLE ONLY audit.stripe_events ALTER COLUMN id SET DEFAULT nextval('audit.stripe_events_id_seq'::regclass);

-- =============================================================================
-- 2. CONSTRAINTS
-- =============================================================================

-- =============================================================================
-- audit.data_changes
-- =============================================================================

ALTER TABLE ONLY audit.data_changes
    ADD CONSTRAINT data_changes_pkey PRIMARY KEY (id);

ALTER TABLE ONLY audit.data_changes
    ADD CONSTRAINT data_changes_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);

-- =============================================================================
-- audit.security_logs
-- =============================================================================

ALTER TABLE ONLY audit.security_logs
    ADD CONSTRAINT security_logs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY audit.security_logs
    ADD CONSTRAINT security_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);

ALTER TABLE ONLY audit.security_logs
    ADD CONSTRAINT security_logs_target_user_id_fkey FOREIGN KEY (target_user_id) REFERENCES auth.users(id);

-- =============================================================================
-- audit.stripe_events
-- =============================================================================

ALTER TABLE ONLY audit.stripe_events
    ADD CONSTRAINT stripe_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY audit.stripe_events
    ADD CONSTRAINT stripe_events_event_id_key UNIQUE (event_id);

-- =============================================================================
-- 3. INDEXES
-- =============================================================================

-- =============================================================================
-- audit.data_changes
-- =============================================================================

CREATE INDEX idx_data_changes_table_record ON audit.data_changes USING btree (table_name, record_id);
CREATE INDEX idx_data_changes_changed_at ON audit.data_changes USING btree (changed_at);

-- =============================================================================
-- audit.security_logs
-- =============================================================================

CREATE INDEX idx_security_logs_severity ON audit.security_logs USING btree (severity, occurred_at);

-- =============================================================================
-- audit.stripe_events
-- =============================================================================

CREATE INDEX idx_stripe_events_event_id ON audit.stripe_events USING btree (event_id);
CREATE INDEX idx_stripe_events_type ON audit.stripe_events USING btree (event_type);
CREATE INDEX idx_stripe_events_created ON audit.stripe_events USING btree (created_at);

-- =============================================================================
-- FIN DE LA MIGRACIÓN 000009
-- =============================================================================