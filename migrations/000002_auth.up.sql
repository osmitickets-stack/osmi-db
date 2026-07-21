-- =============================================================================
-- OSMI DATABASE
-- Migración 000002 — Auth Schema
-- =============================================================================
--
-- Esta migración crea el módulo de autenticación:
--   ✅ auth.roles
--   ✅ auth.users
--   ✅ auth.sessions
--   ✅ Constraints (PK, UNIQUE, FK)
--   ✅ Indexes
--   ✅ Triggers
--
-- Dependencias:
--   - 000001_initial_schema (dominios, función update_updated_at)
--
-- =============================================================================

-- =============================================================================
-- 1. TABLAS
-- =============================================================================

-- =============================================================================
-- auth.roles
-- =============================================================================

CREATE TABLE auth.roles (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);

CREATE SEQUENCE auth.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE auth.roles_id_seq OWNED BY auth.roles.id;

ALTER TABLE ONLY auth.roles ALTER COLUMN id SET DEFAULT nextval('auth.roles_id_seq'::regclass);

-- =============================================================================
-- auth.users
-- =============================================================================

CREATE TABLE auth.users (
    id bigint NOT NULL,
    public_uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    email global.email_address NOT NULL,
    phone global.phone_number,
    username character varying(50),
    password_hash text NOT NULL,
    email_verified boolean DEFAULT false,
    phone_verified boolean DEFAULT false,
    verified_at timestamp with time zone,
    first_name character varying(100),
    last_name character varying(100),
    full_name character varying(255),
    avatar_url text,
    date_of_birth date,
    preferred_language character varying(10) DEFAULT 'es'::character varying,
    preferred_currency global.currency_code DEFAULT 'MXN'::character varying,
    timezone global.timezone_name DEFAULT 'UTC'::character varying,
    mfa_enabled boolean DEFAULT false,
    mfa_secret text,
    last_login_at timestamp with time zone,
    last_login_ip inet,
    failed_login_attempts integer DEFAULT 0,
    locked_until timestamp with time zone,
    is_active boolean DEFAULT true,
    is_staff boolean DEFAULT false,
    is_superuser boolean DEFAULT false,
    last_active_at timestamp with time zone DEFAULT now(),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    role_id integer
);

CREATE SEQUENCE auth.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE auth.users_id_seq OWNED BY auth.users.id;

ALTER TABLE ONLY auth.users ALTER COLUMN id SET DEFAULT nextval('auth.users_id_seq'::regclass);

-- =============================================================================
-- auth.sessions
-- =============================================================================

CREATE TABLE auth.sessions (
    id bigint NOT NULL,
    session_uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id bigint NOT NULL,
    refresh_token_hash text NOT NULL,
    user_agent text,
    ip_address inet,
    device_info jsonb DEFAULT '{}'::jsonb,
    is_valid boolean DEFAULT true,
    invalidated_at timestamp with time zone,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE SEQUENCE auth.sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE auth.sessions_id_seq OWNED BY auth.sessions.id;

ALTER TABLE ONLY auth.sessions ALTER COLUMN id SET DEFAULT nextval('auth.sessions_id_seq'::regclass);

-- =============================================================================
-- 2. CONSTRAINTS
-- =============================================================================

-- =============================================================================
-- auth.roles
-- =============================================================================

ALTER TABLE ONLY auth.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);

ALTER TABLE ONLY auth.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);

-- =============================================================================
-- auth.users
-- =============================================================================

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_email_key UNIQUE (email);

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_public_uuid_key UNIQUE (public_uuid);

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_username_key UNIQUE (username);

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES auth.roles(id);

-- =============================================================================
-- auth.sessions
-- =============================================================================

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_session_uuid_key UNIQUE (session_uuid);

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- =============================================================================
-- 3. INDEXES
-- =============================================================================

-- =============================================================================
-- auth.users
-- =============================================================================

CREATE INDEX idx_users_email ON auth.users USING btree (email);
CREATE INDEX idx_users_is_active ON auth.users USING btree (is_active);

-- =============================================================================
-- auth.sessions
-- =============================================================================

CREATE INDEX idx_sessions_user ON auth.sessions USING btree (user_id);
CREATE INDEX idx_sessions_expires ON auth.sessions USING btree (expires_at);

-- =============================================================================
-- 4. TRIGGERS
-- =============================================================================

-- =============================================================================
-- auth.users
-- =============================================================================

CREATE TRIGGER trg_update_users BEFORE UPDATE ON auth.users FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();

-- =============================================================================
-- auth.sessions
-- =============================================================================

CREATE TRIGGER trg_update_sessions BEFORE UPDATE ON auth.sessions FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();

-- =============================================================================
-- FIN DE LA MIGRACIÓN 000002
-- =============================================================================