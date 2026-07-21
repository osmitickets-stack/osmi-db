--
-- PostgreSQL database dump
--

\restrict SMMWPsEUJhAEi09pPfcgvb7da0SllljczanCkyo4sldzcDeKKZ9fhGKQmJ0ZTiO

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: analytics; Type: SCHEMA; Schema: -; Owner: osmi
--

CREATE SCHEMA analytics;


ALTER SCHEMA analytics OWNER TO osmi;

--
-- Name: audit; Type: SCHEMA; Schema: -; Owner: osmi
--

CREATE SCHEMA audit;


ALTER SCHEMA audit OWNER TO osmi;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: osmi
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO osmi;

--
-- Name: billing; Type: SCHEMA; Schema: -; Owner: osmi
--

CREATE SCHEMA billing;


ALTER SCHEMA billing OWNER TO osmi;

--
-- Name: crm; Type: SCHEMA; Schema: -; Owner: osmi
--

CREATE SCHEMA crm;


ALTER SCHEMA crm OWNER TO osmi;

--
-- Name: fiscal; Type: SCHEMA; Schema: -; Owner: osmi
--

CREATE SCHEMA fiscal;


ALTER SCHEMA fiscal OWNER TO osmi;

--
-- Name: global; Type: SCHEMA; Schema: -; Owner: osmi
--

CREATE SCHEMA global;


ALTER SCHEMA global OWNER TO osmi;

--
-- Name: integration; Type: SCHEMA; Schema: -; Owner: osmi
--

CREATE SCHEMA integration;


ALTER SCHEMA integration OWNER TO osmi;

--
-- Name: notifications; Type: SCHEMA; Schema: -; Owner: osmi
--

CREATE SCHEMA notifications;


ALTER SCHEMA notifications OWNER TO osmi;

--
-- Name: ticketing; Type: SCHEMA; Schema: -; Owner: osmi
--

CREATE SCHEMA ticketing;


ALTER SCHEMA ticketing OWNER TO osmi;

--
-- Name: btree_gin; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA public;


--
-- Name: EXTENSION btree_gin; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION btree_gin IS 'support for indexing common datatypes in GIN';


--
-- Name: btree_gist; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;


--
-- Name: EXTENSION btree_gist; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION btree_gist IS 'support for indexing common datatypes in GiST';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: payment_status; Type: DOMAIN; Schema: billing; Owner: osmi
--

CREATE DOMAIN billing.payment_status AS character varying(20)
	CONSTRAINT payment_status_check CHECK (((VALUE)::text = ANY ((ARRAY['pending'::character varying, 'processing'::character varying, 'completed'::character varying, 'failed'::character varying, 'refunded'::character varying, 'disputed'::character varying, 'chargeback'::character varying, 'expired'::character varying])::text[])));


ALTER DOMAIN billing.payment_status OWNER TO osmi;

--
-- Name: country_code; Type: DOMAIN; Schema: global; Owner: osmi
--

CREATE DOMAIN global.country_code AS character varying(2)
	CONSTRAINT country_code_check CHECK (((VALUE)::text ~ '^[A-Z]{2}$'::text));


ALTER DOMAIN global.country_code OWNER TO osmi;

--
-- Name: currency_code; Type: DOMAIN; Schema: global; Owner: osmi
--

CREATE DOMAIN global.currency_code AS character varying(3)
	CONSTRAINT currency_code_check CHECK (((VALUE)::text ~ '^[A-Z]{3}$'::text));


ALTER DOMAIN global.currency_code OWNER TO osmi;

--
-- Name: email_address; Type: DOMAIN; Schema: global; Owner: osmi
--

CREATE DOMAIN global.email_address AS character varying(320)
	CONSTRAINT email_address_check CHECK (((VALUE)::text ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::text));


ALTER DOMAIN global.email_address OWNER TO osmi;

--
-- Name: percentage; Type: DOMAIN; Schema: global; Owner: osmi
--

CREATE DOMAIN global.percentage AS numeric(5,4)
	CONSTRAINT percentage_check CHECK (((VALUE >= (0)::numeric) AND (VALUE <= (1)::numeric)));


ALTER DOMAIN global.percentage OWNER TO osmi;

--
-- Name: phone_number; Type: DOMAIN; Schema: global; Owner: osmi
--

CREATE DOMAIN global.phone_number AS character varying(20)
	CONSTRAINT phone_number_check CHECK ((((VALUE)::text ~ '^\+[1-9][0-9]{1,14}$'::text) OR ((VALUE)::text ~ '^[0-9]{8,15}$'::text)));


ALTER DOMAIN global.phone_number OWNER TO osmi;

--
-- Name: timezone_name; Type: DOMAIN; Schema: global; Owner: osmi
--

CREATE DOMAIN global.timezone_name AS character varying(50)
	CONSTRAINT timezone_name_check CHECK ((((VALUE)::text ~ '^[A-Za-z_]+/[A-Za-z_]+$'::text) OR ((VALUE)::text = 'UTC'::text)));


ALTER DOMAIN global.timezone_name OWNER TO osmi;

--
-- Name: event_status; Type: DOMAIN; Schema: ticketing; Owner: osmi
--

CREATE DOMAIN ticketing.event_status AS character varying(20)
	CONSTRAINT event_status_check CHECK (((VALUE)::text = ANY ((ARRAY['draft'::character varying, 'scheduled'::character varying, 'published'::character varying, 'live'::character varying, 'cancelled'::character varying, 'completed'::character varying, 'sold_out'::character varying, 'archived'::character varying])::text[])));


ALTER DOMAIN ticketing.event_status OWNER TO osmi;

--
-- Name: ticket_status; Type: DOMAIN; Schema: ticketing; Owner: osmi
--

CREATE DOMAIN ticketing.ticket_status AS character varying(20)
	CONSTRAINT ticket_status_check CHECK (((VALUE)::text = ANY ((ARRAY['available'::character varying, 'reserved'::character varying, 'sold'::character varying, 'checked_in'::character varying, 'cancelled'::character varying, 'refunded'::character varying, 'expired'::character varying])::text[])));


ALTER DOMAIN ticketing.ticket_status OWNER TO osmi;

--
-- Name: update_updated_at(); Type: FUNCTION; Schema: auth; Owner: osmi
--

CREATE FUNCTION auth.update_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION auth.update_updated_at() OWNER TO osmi;

--
-- Name: update_updated_at(); Type: FUNCTION; Schema: public; Owner: osmi
--

CREATE FUNCTION public.update_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at() OWNER TO osmi;

--
-- Name: check_ticket_availability(bigint, integer); Type: FUNCTION; Schema: ticketing; Owner: osmi
--

CREATE FUNCTION ticketing.check_ticket_availability(p_ticket_type_id bigint, p_quantity integer) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION ticketing.check_ticket_availability(p_ticket_type_id bigint, p_quantity integer) OWNER TO osmi;

--
-- Name: generate_ticket_code(); Type: FUNCTION; Schema: ticketing; Owner: osmi
--

CREATE FUNCTION ticketing.generate_ticket_code() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION ticketing.generate_ticket_code() OWNER TO osmi;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: daily_metrics; Type: TABLE; Schema: analytics; Owner: osmi
--

CREATE TABLE analytics.daily_metrics (
    id bigint NOT NULL,
    metric_date date NOT NULL,
    metric_type character varying(50) NOT NULL,
    total_revenue numeric(15,2) DEFAULT 0,
    total_orders integer DEFAULT 0,
    total_tickets_sold integer DEFAULT 0,
    avg_order_value numeric(10,2) DEFAULT 0,
    new_customers integer DEFAULT 0,
    returning_customers integer DEFAULT 0,
    active_users integer DEFAULT 0,
    conversion_rate numeric(5,4) DEFAULT 0,
    cart_abandonment_rate numeric(5,4) DEFAULT 0,
    country_breakdown jsonb DEFAULT '{}'::jsonb,
    category_breakdown jsonb DEFAULT '{}'::jsonb,
    event_breakdown jsonb DEFAULT '{}'::jsonb,
    page_views integer DEFAULT 0,
    unique_visitors integer DEFAULT 0,
    bounce_rate numeric(5,4) DEFAULT 0,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE analytics.daily_metrics OWNER TO osmi;

--
-- Name: daily_metrics_id_seq; Type: SEQUENCE; Schema: analytics; Owner: osmi
--

CREATE SEQUENCE analytics.daily_metrics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE analytics.daily_metrics_id_seq OWNER TO osmi;

--
-- Name: daily_metrics_id_seq; Type: SEQUENCE OWNED BY; Schema: analytics; Owner: osmi
--

ALTER SEQUENCE analytics.daily_metrics_id_seq OWNED BY analytics.daily_metrics.id;


--
-- Name: event_metrics; Type: TABLE; Schema: analytics; Owner: osmi
--

CREATE TABLE analytics.event_metrics (
    id bigint NOT NULL,
    event_id bigint NOT NULL,
    tickets_sold integer DEFAULT 0,
    tickets_reserved integer DEFAULT 0,
    total_revenue numeric(15,2) DEFAULT 0,
    checked_in_count integer DEFAULT 0,
    checkin_rate numeric(5,4) DEFAULT 0,
    customer_demographics jsonb DEFAULT '{}'::jsonb,
    top_cities jsonb DEFAULT '[]'::jsonb,
    sales_velocity numeric(10,2) DEFAULT 0,
    peak_sales_hour time without time zone,
    views_count integer DEFAULT 0,
    favorites_count integer DEFAULT 0,
    shares_count integer DEFAULT 0,
    calculated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE analytics.event_metrics OWNER TO osmi;

--
-- Name: event_metrics_id_seq; Type: SEQUENCE; Schema: analytics; Owner: osmi
--

CREATE SEQUENCE analytics.event_metrics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE analytics.event_metrics_id_seq OWNER TO osmi;

--
-- Name: event_metrics_id_seq; Type: SEQUENCE OWNED BY; Schema: analytics; Owner: osmi
--

ALTER SEQUENCE analytics.event_metrics_id_seq OWNED BY analytics.event_metrics.id;


--
-- Name: order_items; Type: TABLE; Schema: billing; Owner: osmi
--

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


ALTER TABLE billing.order_items OWNER TO osmi;

--
-- Name: orders; Type: TABLE; Schema: billing; Owner: osmi
--

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


ALTER TABLE billing.orders OWNER TO osmi;

--
-- Name: sales_report; Type: VIEW; Schema: analytics; Owner: osmi
--

CREATE VIEW analytics.sales_report AS
 SELECT date(o.created_at) AS sale_date,
    o.currency,
    count(DISTINCT o.id) AS total_orders,
    count(DISTINCT o.customer_id) AS unique_customers,
    sum(o.total_amount) AS total_revenue,
    sum(oi.quantity) AS total_tickets,
    avg(o.total_amount) AS avg_order_value
   FROM (billing.orders o
     JOIN billing.order_items oi ON ((oi.order_id = o.id)))
  WHERE ((o.status)::text = 'completed'::text)
  GROUP BY (date(o.created_at)), o.currency;


ALTER VIEW analytics.sales_report OWNER TO osmi;

--
-- Name: data_changes; Type: TABLE; Schema: audit; Owner: osmi
--

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


ALTER TABLE audit.data_changes OWNER TO osmi;

--
-- Name: data_changes_id_seq; Type: SEQUENCE; Schema: audit; Owner: osmi
--

CREATE SEQUENCE audit.data_changes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE audit.data_changes_id_seq OWNER TO osmi;

--
-- Name: data_changes_id_seq; Type: SEQUENCE OWNED BY; Schema: audit; Owner: osmi
--

ALTER SEQUENCE audit.data_changes_id_seq OWNED BY audit.data_changes.id;


--
-- Name: security_logs; Type: TABLE; Schema: audit; Owner: osmi
--

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


ALTER TABLE audit.security_logs OWNER TO osmi;

--
-- Name: security_logs_id_seq; Type: SEQUENCE; Schema: audit; Owner: osmi
--

CREATE SEQUENCE audit.security_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE audit.security_logs_id_seq OWNER TO osmi;

--
-- Name: security_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: audit; Owner: osmi
--

ALTER SEQUENCE audit.security_logs_id_seq OWNED BY audit.security_logs.id;


--
-- Name: stripe_events; Type: TABLE; Schema: audit; Owner: osmi
--

CREATE TABLE audit.stripe_events (
    id bigint NOT NULL,
    event_id character varying(255) NOT NULL,
    event_type character varying(100) NOT NULL,
    payload jsonb NOT NULL,
    processed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE audit.stripe_events OWNER TO osmi;

--
-- Name: stripe_events_id_seq; Type: SEQUENCE; Schema: audit; Owner: osmi
--

CREATE SEQUENCE audit.stripe_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE audit.stripe_events_id_seq OWNER TO osmi;

--
-- Name: stripe_events_id_seq; Type: SEQUENCE OWNED BY; Schema: audit; Owner: osmi
--

ALTER SEQUENCE audit.stripe_events_id_seq OWNED BY audit.stripe_events.id;


--
-- Name: roles; Type: TABLE; Schema: auth; Owner: osmi
--

CREATE TABLE auth.roles (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE auth.roles OWNER TO osmi;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: auth; Owner: osmi
--

CREATE SEQUENCE auth.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.roles_id_seq OWNER TO osmi;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: osmi
--

ALTER SEQUENCE auth.roles_id_seq OWNED BY auth.roles.id;


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: osmi
--

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


ALTER TABLE auth.sessions OWNER TO osmi;

--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: auth; Owner: osmi
--

CREATE SEQUENCE auth.sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.sessions_id_seq OWNER TO osmi;

--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: osmi
--

ALTER SEQUENCE auth.sessions_id_seq OWNED BY auth.sessions.id;


--
-- Name: users; Type: TABLE; Schema: auth; Owner: osmi
--

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


ALTER TABLE auth.users OWNER TO osmi;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: auth; Owner: osmi
--

CREATE SEQUENCE auth.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.users_id_seq OWNER TO osmi;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: osmi
--

ALTER SEQUENCE auth.users_id_seq OWNED BY auth.users.id;


--
-- Name: order_items_id_seq; Type: SEQUENCE; Schema: billing; Owner: osmi
--

CREATE SEQUENCE billing.order_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE billing.order_items_id_seq OWNER TO osmi;

--
-- Name: order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: billing; Owner: osmi
--

ALTER SEQUENCE billing.order_items_id_seq OWNED BY billing.order_items.id;


--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: billing; Owner: osmi
--

CREATE SEQUENCE billing.orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE billing.orders_id_seq OWNER TO osmi;

--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: billing; Owner: osmi
--

ALTER SEQUENCE billing.orders_id_seq OWNED BY billing.orders.id;


--
-- Name: payment_providers; Type: TABLE; Schema: billing; Owner: osmi
--

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


ALTER TABLE billing.payment_providers OWNER TO osmi;

--
-- Name: payment_providers_id_seq; Type: SEQUENCE; Schema: billing; Owner: osmi
--

CREATE SEQUENCE billing.payment_providers_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE billing.payment_providers_id_seq OWNER TO osmi;

--
-- Name: payment_providers_id_seq; Type: SEQUENCE OWNED BY; Schema: billing; Owner: osmi
--

ALTER SEQUENCE billing.payment_providers_id_seq OWNED BY billing.payment_providers.id;


--
-- Name: payments; Type: TABLE; Schema: billing; Owner: osmi
--

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


ALTER TABLE billing.payments OWNER TO osmi;

--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: billing; Owner: osmi
--

CREATE SEQUENCE billing.payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE billing.payments_id_seq OWNER TO osmi;

--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: billing; Owner: osmi
--

ALTER SEQUENCE billing.payments_id_seq OWNED BY billing.payments.id;


--
-- Name: refunds; Type: TABLE; Schema: billing; Owner: osmi
--

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


ALTER TABLE billing.refunds OWNER TO osmi;

--
-- Name: refunds_id_seq; Type: SEQUENCE; Schema: billing; Owner: osmi
--

CREATE SEQUENCE billing.refunds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE billing.refunds_id_seq OWNER TO osmi;

--
-- Name: refunds_id_seq; Type: SEQUENCE OWNED BY; Schema: billing; Owner: osmi
--

ALTER SEQUENCE billing.refunds_id_seq OWNED BY billing.refunds.id;


--
-- Name: customers; Type: TABLE; Schema: crm; Owner: osmi
--

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


ALTER TABLE crm.customers OWNER TO osmi;

--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: crm; Owner: osmi
--

CREATE SEQUENCE crm.customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE crm.customers_id_seq OWNER TO osmi;

--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: crm; Owner: osmi
--

ALTER SEQUENCE crm.customers_id_seq OWNED BY crm.customers.id;


--
-- Name: country_config; Type: TABLE; Schema: fiscal; Owner: osmi
--

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


ALTER TABLE fiscal.country_config OWNER TO osmi;

--
-- Name: country_config_id_seq; Type: SEQUENCE; Schema: fiscal; Owner: osmi
--

CREATE SEQUENCE fiscal.country_config_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE fiscal.country_config_id_seq OWNER TO osmi;

--
-- Name: country_config_id_seq; Type: SEQUENCE OWNED BY; Schema: fiscal; Owner: osmi
--

ALTER SEQUENCE fiscal.country_config_id_seq OWNED BY fiscal.country_config.id;


--
-- Name: invoices; Type: TABLE; Schema: fiscal; Owner: osmi
--

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


ALTER TABLE fiscal.invoices OWNER TO osmi;

--
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: fiscal; Owner: osmi
--

CREATE SEQUENCE fiscal.invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE fiscal.invoices_id_seq OWNER TO osmi;

--
-- Name: invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: fiscal; Owner: osmi
--

ALTER SEQUENCE fiscal.invoices_id_seq OWNED BY fiscal.invoices.id;


--
-- Name: supported_currencies; Type: TABLE; Schema: global; Owner: osmi
--

CREATE TABLE global.supported_currencies (
    code character varying(3) NOT NULL,
    name character varying(100) NOT NULL,
    symbol character varying(10) NOT NULL,
    decimal_places integer DEFAULT 2,
    exchange_rate numeric(15,6) DEFAULT 1.0,
    is_active boolean DEFAULT true,
    is_default boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE global.supported_currencies OWNER TO osmi;

--
-- Name: supported_languages; Type: TABLE; Schema: global; Owner: osmi
--

CREATE TABLE global.supported_languages (
    code character varying(10) NOT NULL,
    name character varying(100) NOT NULL,
    native_name character varying(100) NOT NULL,
    is_active boolean DEFAULT true,
    is_default boolean DEFAULT false,
    sort_order integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE global.supported_languages OWNER TO osmi;

--
-- Name: system_config; Type: TABLE; Schema: global; Owner: osmi
--

CREATE TABLE global.system_config (
    id integer NOT NULL,
    config_key character varying(100) NOT NULL,
    config_value jsonb NOT NULL,
    data_type character varying(50) DEFAULT 'string'::character varying,
    description text,
    category character varying(50) DEFAULT 'general'::character varying,
    is_public boolean DEFAULT false,
    is_encrypted boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE global.system_config OWNER TO osmi;

--
-- Name: system_config_id_seq; Type: SEQUENCE; Schema: global; Owner: osmi
--

CREATE SEQUENCE global.system_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE global.system_config_id_seq OWNER TO osmi;

--
-- Name: system_config_id_seq; Type: SEQUENCE OWNED BY; Schema: global; Owner: osmi
--

ALTER SEQUENCE global.system_config_id_seq OWNED BY global.system_config.id;


--
-- Name: api_calls; Type: TABLE; Schema: integration; Owner: osmi
--

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


ALTER TABLE integration.api_calls OWNER TO osmi;

--
-- Name: api_calls_id_seq; Type: SEQUENCE; Schema: integration; Owner: osmi
--

CREATE SEQUENCE integration.api_calls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE integration.api_calls_id_seq OWNER TO osmi;

--
-- Name: api_calls_id_seq; Type: SEQUENCE OWNED BY; Schema: integration; Owner: osmi
--

ALTER SEQUENCE integration.api_calls_id_seq OWNED BY integration.api_calls.id;


--
-- Name: webhooks; Type: TABLE; Schema: integration; Owner: osmi
--

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


ALTER TABLE integration.webhooks OWNER TO osmi;

--
-- Name: webhooks_id_seq; Type: SEQUENCE; Schema: integration; Owner: osmi
--

CREATE SEQUENCE integration.webhooks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE integration.webhooks_id_seq OWNER TO osmi;

--
-- Name: webhooks_id_seq; Type: SEQUENCE OWNED BY; Schema: integration; Owner: osmi
--

ALTER SEQUENCE integration.webhooks_id_seq OWNED BY integration.webhooks.id;


--
-- Name: messages; Type: TABLE; Schema: notifications; Owner: osmi
--

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


ALTER TABLE notifications.messages OWNER TO osmi;

--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: notifications; Owner: osmi
--

CREATE SEQUENCE notifications.messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE notifications.messages_id_seq OWNER TO osmi;

--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: notifications; Owner: osmi
--

ALTER SEQUENCE notifications.messages_id_seq OWNED BY notifications.messages.id;


--
-- Name: templates; Type: TABLE; Schema: notifications; Owner: osmi
--

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


ALTER TABLE notifications.templates OWNER TO osmi;

--
-- Name: templates_id_seq; Type: SEQUENCE; Schema: notifications; Owner: osmi
--

CREATE SEQUENCE notifications.templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE notifications.templates_id_seq OWNER TO osmi;

--
-- Name: templates_id_seq; Type: SEQUENCE OWNED BY; Schema: notifications; Owner: osmi
--

ALTER SEQUENCE notifications.templates_id_seq OWNED BY notifications.templates.id;


--
-- Name: categories; Type: TABLE; Schema: ticketing; Owner: osmi
--

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


ALTER TABLE ticketing.categories OWNER TO osmi;

--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: ticketing; Owner: osmi
--

CREATE SEQUENCE ticketing.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ticketing.categories_id_seq OWNER TO osmi;

--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: ticketing; Owner: osmi
--

ALTER SEQUENCE ticketing.categories_id_seq OWNED BY ticketing.categories.id;


--
-- Name: events; Type: TABLE; Schema: ticketing; Owner: osmi
--

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


ALTER TABLE ticketing.events OWNER TO osmi;

--
-- Name: events_id_seq; Type: SEQUENCE; Schema: ticketing; Owner: osmi
--

CREATE SEQUENCE ticketing.events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ticketing.events_id_seq OWNER TO osmi;

--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: ticketing; Owner: osmi
--

ALTER SEQUENCE ticketing.events_id_seq OWNED BY ticketing.events.id;


--
-- Name: organizers; Type: TABLE; Schema: ticketing; Owner: osmi
--

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


ALTER TABLE ticketing.organizers OWNER TO osmi;

--
-- Name: organizers_id_seq; Type: SEQUENCE; Schema: ticketing; Owner: osmi
--

CREATE SEQUENCE ticketing.organizers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ticketing.organizers_id_seq OWNER TO osmi;

--
-- Name: organizers_id_seq; Type: SEQUENCE OWNED BY; Schema: ticketing; Owner: osmi
--

ALTER SEQUENCE ticketing.organizers_id_seq OWNED BY ticketing.organizers.id;


--
-- Name: ticket_types; Type: TABLE; Schema: ticketing; Owner: osmi
--

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


ALTER TABLE ticketing.ticket_types OWNER TO osmi;

--
-- Name: ticket_types_id_seq; Type: SEQUENCE; Schema: ticketing; Owner: osmi
--

CREATE SEQUENCE ticketing.ticket_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ticketing.ticket_types_id_seq OWNER TO osmi;

--
-- Name: ticket_types_id_seq; Type: SEQUENCE OWNED BY; Schema: ticketing; Owner: osmi
--

ALTER SEQUENCE ticketing.ticket_types_id_seq OWNED BY ticketing.ticket_types.id;


--
-- Name: tickets; Type: TABLE; Schema: ticketing; Owner: osmi
--

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


ALTER TABLE ticketing.tickets OWNER TO osmi;

--
-- Name: tickets_id_seq; Type: SEQUENCE; Schema: ticketing; Owner: osmi
--

CREATE SEQUENCE ticketing.tickets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ticketing.tickets_id_seq OWNER TO osmi;

--
-- Name: tickets_id_seq; Type: SEQUENCE OWNED BY; Schema: ticketing; Owner: osmi
--

ALTER SEQUENCE ticketing.tickets_id_seq OWNED BY ticketing.tickets.id;


--
-- Name: venues; Type: TABLE; Schema: ticketing; Owner: osmi
--

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


ALTER TABLE ticketing.venues OWNER TO osmi;

--
-- Name: venues_id_seq; Type: SEQUENCE; Schema: ticketing; Owner: osmi
--

CREATE SEQUENCE ticketing.venues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ticketing.venues_id_seq OWNER TO osmi;

--
-- Name: venues_id_seq; Type: SEQUENCE OWNED BY; Schema: ticketing; Owner: osmi
--

ALTER SEQUENCE ticketing.venues_id_seq OWNED BY ticketing.venues.id;


--
-- Name: daily_metrics id; Type: DEFAULT; Schema: analytics; Owner: osmi
--

ALTER TABLE ONLY analytics.daily_metrics ALTER COLUMN id SET DEFAULT nextval('analytics.daily_metrics_id_seq'::regclass);


--
-- Name: event_metrics id; Type: DEFAULT; Schema: analytics; Owner: osmi
--

ALTER TABLE ONLY analytics.event_metrics ALTER COLUMN id SET DEFAULT nextval('analytics.event_metrics_id_seq'::regclass);


--
-- Name: data_changes id; Type: DEFAULT; Schema: audit; Owner: osmi
--

ALTER TABLE ONLY audit.data_changes ALTER COLUMN id SET DEFAULT nextval('audit.data_changes_id_seq'::regclass);


--
-- Name: security_logs id; Type: DEFAULT; Schema: audit; Owner: osmi
--

ALTER TABLE ONLY audit.security_logs ALTER COLUMN id SET DEFAULT nextval('audit.security_logs_id_seq'::regclass);


--
-- Name: stripe_events id; Type: DEFAULT; Schema: audit; Owner: osmi
--

ALTER TABLE ONLY audit.stripe_events ALTER COLUMN id SET DEFAULT nextval('audit.stripe_events_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: auth; Owner: osmi
--

ALTER TABLE ONLY auth.roles ALTER COLUMN id SET DEFAULT nextval('auth.roles_id_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: auth; Owner: osmi
--

ALTER TABLE ONLY auth.sessions ALTER COLUMN id SET DEFAULT nextval('auth.sessions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: auth; Owner: osmi
--

ALTER TABLE ONLY auth.users ALTER COLUMN id SET DEFAULT nextval('auth.users_id_seq'::regclass);


--
-- Name: order_items id; Type: DEFAULT; Schema: billing; Owner: osmi
--

ALTER TABLE ONLY billing.order_items ALTER COLUMN id SET DEFAULT nextval('billing.order_items_id_seq'::regclass);


--
-- Name: orders id; Type: DEFAULT; Schema: billing; Owner: osmi
--

ALTER TABLE ONLY billing.orders ALTER COLUMN id SET DEFAULT nextval('billing.orders_id_seq'::regclass);


--
-- Name: payment_providers id; Type: DEFAULT; Schema: billing; Owner: osmi
--

ALTER TABLE ONLY billing.payment_providers ALTER COLUMN id SET DEFAULT nextval('billing.payment_providers_id_seq'::regclass);


--
-- Name: payments id; Type: DEFAULT; Schema: billing; Owner: osmi
--

ALTER TABLE ONLY billing.payments ALTER COLUMN id SET DEFAULT nextval('billing.payments_id_seq'::regclass);


--
-- Name: refunds id; Type: DEFAULT; Schema: billing; Owner: osmi
--

ALTER TABLE ONLY billing.refunds ALTER COLUMN id SET DEFAULT nextval('billing.refunds_id_seq'::regclass);


--
-- Name: customers id; Type: DEFAULT; Schema: crm; Owner: osmi
--

ALTER TABLE ONLY crm.customers ALTER COLUMN id SET DEFAULT nextval('crm.customers_id_seq'::regclass);


--
-- Name: country_config id; Type: DEFAULT; Schema: fiscal; Owner: osmi
--

ALTER TABLE ONLY fiscal.country_config ALTER COLUMN id SET DEFAULT nextval('fiscal.country_config_id_seq'::regclass);


--
-- Name: invoices id; Type: DEFAULT; Schema: fiscal; Owner: osmi
--

ALTER TABLE ONLY fiscal.invoices ALTER COLUMN id SET DEFAULT nextval('fiscal.invoices_id_seq'::regclass);


--
-- Name: system_config id; Type: DEFAULT; Schema: global; Owner: osmi
--

ALTER TABLE ONLY global.system_config ALTER COLUMN id SET DEFAULT nextval('global.system_config_id_seq'::regclass);


--
-- Name: api_calls id; Type: DEFAULT; Schema: integration; Owner: osmi
--

ALTER TABLE ONLY integration.api_calls ALTER COLUMN id SET DEFAULT nextval('integration.api_calls_id_seq'::regclass);


--
-- Name: webhooks id; Type: DEFAULT; Schema: integration; Owner: osmi
--

ALTER TABLE ONLY integration.webhooks ALTER COLUMN id SET DEFAULT nextval('integration.webhooks_id_seq'::regclass);


--
-- Name: messages id; Type: DEFAULT; Schema: notifications; Owner: osmi
--

ALTER TABLE ONLY notifications.messages ALTER COLUMN id SET DEFAULT nextval('notifications.messages_id_seq'::regclass);


--
-- Name: templates id; Type: DEFAULT; Schema: notifications; Owner: osmi
--

ALTER TABLE ONLY notifications.templates ALTER COLUMN id SET DEFAULT nextval('notifications.templates_id_seq'::regclass);


--
-- Name: categories id; Type: DEFAULT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.categories ALTER COLUMN id SET DEFAULT nextval('ticketing.categories_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.events ALTER COLUMN id SET DEFAULT nextval('ticketing.events_id_seq'::regclass);


--
-- Name: organizers id; Type: DEFAULT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.organizers ALTER COLUMN id SET DEFAULT nextval('ticketing.organizers_id_seq'::regclass);


--
-- Name: ticket_types id; Type: DEFAULT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.ticket_types ALTER COLUMN id SET DEFAULT nextval('ticketing.ticket_types_id_seq'::regclass);


--
-- Name: tickets id; Type: DEFAULT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.tickets ALTER COLUMN id SET DEFAULT nextval('ticketing.tickets_id_seq'::regclass);


--
-- Name: venues id; Type: DEFAULT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.venues ALTER COLUMN id SET DEFAULT nextval('ticketing.venues_id_seq'::regclass);


--
-- Name: daily_metrics daily_metrics_metric_date_metric_type_key; Type: CONSTRAINT; Schema: analytics; Owner: osmi
--

ALTER TABLE ONLY analytics.daily_metrics
    ADD CONSTRAINT daily_metrics_metric_date_metric_type_key UNIQUE (metric_date, metric_type);


--
-- Name: daily_metrics daily_metrics_pkey; Type: CONSTRAINT; Schema: analytics; Owner: osmi
--

ALTER TABLE ONLY analytics.daily_metrics
    ADD CONSTRAINT daily_metrics_pkey PRIMARY KEY (id);


--
-- Name: event_metrics event_metrics_event_id_key; Type: CONSTRAINT; Schema: analytics; Owner: osmi
--

ALTER TABLE ONLY analytics.event_metrics
    ADD CONSTRAINT event_metrics_event_id_key UNIQUE (event_id);


--
-- Name: event_metrics event_metrics_pkey; Type: CONSTRAINT; Schema: analytics; Owner: osmi
--

ALTER TABLE ONLY analytics.event_metrics
    ADD CONSTRAINT event_metrics_pkey PRIMARY KEY (id);


--
-- Name: data_changes data_changes_pkey; Type: CONSTRAINT; Schema: audit; Owner: osmi
--

ALTER TABLE ONLY audit.data_changes
    ADD CONSTRAINT data_changes_pkey PRIMARY KEY (id);


--
-- Name: security_logs security_logs_pkey; Type: CONSTRAINT; Schema: audit; Owner: osmi
--

ALTER TABLE ONLY audit.security_logs
    ADD CONSTRAINT security_logs_pkey PRIMARY KEY (id);


--
-- Name: stripe_events stripe_events_event_id_key; Type: CONSTRAINT; Schema: audit; Owner: osmi
--

ALTER TABLE ONLY audit.stripe_events
    ADD CONSTRAINT stripe_events_event_id_key UNIQUE (event_id);


--
-- Name: stripe_events stripe_events_pkey; Type: CONSTRAINT; Schema: audit; Owner: osmi
--

ALTER TABLE ONLY audit.stripe_events
    ADD CONSTRAINT stripe_events_pkey PRIMARY KEY (id);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: auth; Owner: osmi
--

ALTER TABLE ONLY auth.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: auth; Owner: osmi
--

ALTER TABLE ONLY auth.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: osmi
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_session_uuid_key; Type: CONSTRAINT; Schema: auth; Owner: osmi
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_session_uuid_key UNIQUE (session_uuid);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: auth; Owner: osmi
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: osmi
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_public_uuid_key; Type: CONSTRAINT; Schema: auth; Owner: osmi
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_public_uuid_key UNIQUE (public_uuid);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: auth; Owner: osmi
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: billing; Owner: osmi
--

ALTER TABLE ONLY billing.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: billing; Owner: osmi
--

ALTER TABLE ONLY billing.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: orders orders_public_uuid_key; Type: CONSTRAINT; Schema: billing; Owner: osmi
--

ALTER TABLE ONLY billing.orders
    ADD CONSTRAINT orders_public_uuid_key UNIQUE (public_uuid);


--
-- Name: payment_providers payment_providers_code_key; Type: CONSTRAINT; Schema: billing; Owner: osmi
--

ALTER TABLE ONLY billing.payment_providers
    ADD CONSTRAINT payment_providers_code_key UNIQUE (code);


--
-- Name: payment_providers payment_providers_pkey; Type: CONSTRAINT; Schema: billing; Owner: osmi
--

ALTER TABLE ONLY billing.payment_providers
    ADD CONSTRAINT payment_providers_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: billing; Owner: osmi
--

ALTER TABLE ONLY billing.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: refunds refunds_pkey; Type: CONSTRAINT; Schema: billing; Owner: osmi
--

ALTER TABLE ONLY billing.refunds
    ADD CONSTRAINT refunds_pkey PRIMARY KEY (id);


--
-- Name: customers customers_email_key; Type: CONSTRAINT; Schema: crm; Owner: osmi
--

ALTER TABLE ONLY crm.customers
    ADD CONSTRAINT customers_email_key UNIQUE (email);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: crm; Owner: osmi
--

ALTER TABLE ONLY crm.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: customers customers_public_uuid_key; Type: CONSTRAINT; Schema: crm; Owner: osmi
--

ALTER TABLE ONLY crm.customers
    ADD CONSTRAINT customers_public_uuid_key UNIQUE (public_uuid);


--
-- Name: customers customers_user_id_key; Type: CONSTRAINT; Schema: crm; Owner: osmi
--

ALTER TABLE ONLY crm.customers
    ADD CONSTRAINT customers_user_id_key UNIQUE (user_id);


--
-- Name: country_config country_config_country_code_key; Type: CONSTRAINT; Schema: fiscal; Owner: osmi
--

ALTER TABLE ONLY fiscal.country_config
    ADD CONSTRAINT country_config_country_code_key UNIQUE (country_code);


--
-- Name: country_config country_config_pkey; Type: CONSTRAINT; Schema: fiscal; Owner: osmi
--

ALTER TABLE ONLY fiscal.country_config
    ADD CONSTRAINT country_config_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_invoice_uuid_key; Type: CONSTRAINT; Schema: fiscal; Owner: osmi
--

ALTER TABLE ONLY fiscal.invoices
    ADD CONSTRAINT invoices_invoice_uuid_key UNIQUE (invoice_uuid);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: fiscal; Owner: osmi
--

ALTER TABLE ONLY fiscal.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: supported_currencies supported_currencies_pkey; Type: CONSTRAINT; Schema: global; Owner: osmi
--

ALTER TABLE ONLY global.supported_currencies
    ADD CONSTRAINT supported_currencies_pkey PRIMARY KEY (code);


--
-- Name: supported_languages supported_languages_pkey; Type: CONSTRAINT; Schema: global; Owner: osmi
--

ALTER TABLE ONLY global.supported_languages
    ADD CONSTRAINT supported_languages_pkey PRIMARY KEY (code);


--
-- Name: system_config system_config_config_key_key; Type: CONSTRAINT; Schema: global; Owner: osmi
--

ALTER TABLE ONLY global.system_config
    ADD CONSTRAINT system_config_config_key_key UNIQUE (config_key);


--
-- Name: system_config system_config_pkey; Type: CONSTRAINT; Schema: global; Owner: osmi
--

ALTER TABLE ONLY global.system_config
    ADD CONSTRAINT system_config_pkey PRIMARY KEY (id);


--
-- Name: api_calls api_calls_pkey; Type: CONSTRAINT; Schema: integration; Owner: osmi
--

ALTER TABLE ONLY integration.api_calls
    ADD CONSTRAINT api_calls_pkey PRIMARY KEY (id);


--
-- Name: webhooks webhooks_pkey; Type: CONSTRAINT; Schema: integration; Owner: osmi
--

ALTER TABLE ONLY integration.webhooks
    ADD CONSTRAINT webhooks_pkey PRIMARY KEY (id);


--
-- Name: webhooks webhooks_public_uuid_key; Type: CONSTRAINT; Schema: integration; Owner: osmi
--

ALTER TABLE ONLY integration.webhooks
    ADD CONSTRAINT webhooks_public_uuid_key UNIQUE (public_uuid);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: notifications; Owner: osmi
--

ALTER TABLE ONLY notifications.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: templates templates_code_key; Type: CONSTRAINT; Schema: notifications; Owner: osmi
--

ALTER TABLE ONLY notifications.templates
    ADD CONSTRAINT templates_code_key UNIQUE (code);


--
-- Name: templates templates_pkey; Type: CONSTRAINT; Schema: notifications; Owner: osmi
--

ALTER TABLE ONLY notifications.templates
    ADD CONSTRAINT templates_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: categories categories_public_uuid_key; Type: CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.categories
    ADD CONSTRAINT categories_public_uuid_key UNIQUE (public_uuid);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: events events_public_uuid_key; Type: CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.events
    ADD CONSTRAINT events_public_uuid_key UNIQUE (public_uuid);


--
-- Name: events events_slug_key; Type: CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.events
    ADD CONSTRAINT events_slug_key UNIQUE (slug);


--
-- Name: organizers organizers_pkey; Type: CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.organizers
    ADD CONSTRAINT organizers_pkey PRIMARY KEY (id);


--
-- Name: organizers organizers_public_uuid_key; Type: CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.organizers
    ADD CONSTRAINT organizers_public_uuid_key UNIQUE (public_uuid);


--
-- Name: organizers organizers_slug_key; Type: CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.organizers
    ADD CONSTRAINT organizers_slug_key UNIQUE (slug);


--
-- Name: ticket_types ticket_types_pkey; Type: CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.ticket_types
    ADD CONSTRAINT ticket_types_pkey PRIMARY KEY (id);


--
-- Name: ticket_types ticket_types_public_uuid_key; Type: CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.ticket_types
    ADD CONSTRAINT ticket_types_public_uuid_key UNIQUE (public_uuid);


--
-- Name: tickets tickets_code_key; Type: CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.tickets
    ADD CONSTRAINT tickets_code_key UNIQUE (code);


--
-- Name: tickets tickets_code_unique; Type: CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.tickets
    ADD CONSTRAINT tickets_code_unique UNIQUE (code);


--
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id);


--
-- Name: tickets tickets_public_uuid_key; Type: CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.tickets
    ADD CONSTRAINT tickets_public_uuid_key UNIQUE (public_uuid);


--
-- Name: categories unique_event_category_name; Type: CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.categories
    ADD CONSTRAINT unique_event_category_name UNIQUE (event_id, name);


--
-- Name: categories unique_event_category_slug; Type: CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.categories
    ADD CONSTRAINT unique_event_category_slug UNIQUE (event_id, slug);


--
-- Name: venues venues_pkey; Type: CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.venues
    ADD CONSTRAINT venues_pkey PRIMARY KEY (id);


--
-- Name: venues venues_public_uuid_key; Type: CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.venues
    ADD CONSTRAINT venues_public_uuid_key UNIQUE (public_uuid);


--
-- Name: venues venues_slug_key; Type: CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.venues
    ADD CONSTRAINT venues_slug_key UNIQUE (slug);


--
-- Name: idx_daily_metrics_date; Type: INDEX; Schema: analytics; Owner: osmi
--

CREATE INDEX idx_daily_metrics_date ON analytics.daily_metrics USING btree (metric_date);


--
-- Name: idx_event_metrics_event_id; Type: INDEX; Schema: analytics; Owner: osmi
--

CREATE INDEX idx_event_metrics_event_id ON analytics.event_metrics USING btree (event_id);


--
-- Name: idx_data_changes_changed_at; Type: INDEX; Schema: audit; Owner: osmi
--

CREATE INDEX idx_data_changes_changed_at ON audit.data_changes USING btree (changed_at);


--
-- Name: idx_data_changes_table_record; Type: INDEX; Schema: audit; Owner: osmi
--

CREATE INDEX idx_data_changes_table_record ON audit.data_changes USING btree (table_name, record_id);


--
-- Name: idx_security_logs_severity; Type: INDEX; Schema: audit; Owner: osmi
--

CREATE INDEX idx_security_logs_severity ON audit.security_logs USING btree (severity, occurred_at);


--
-- Name: idx_stripe_events_created; Type: INDEX; Schema: audit; Owner: osmi
--

CREATE INDEX idx_stripe_events_created ON audit.stripe_events USING btree (created_at);


--
-- Name: idx_stripe_events_event_id; Type: INDEX; Schema: audit; Owner: osmi
--

CREATE INDEX idx_stripe_events_event_id ON audit.stripe_events USING btree (event_id);


--
-- Name: idx_stripe_events_type; Type: INDEX; Schema: audit; Owner: osmi
--

CREATE INDEX idx_stripe_events_type ON audit.stripe_events USING btree (event_type);


--
-- Name: idx_sessions_expires; Type: INDEX; Schema: auth; Owner: osmi
--

CREATE INDEX idx_sessions_expires ON auth.sessions USING btree (expires_at);


--
-- Name: idx_sessions_user; Type: INDEX; Schema: auth; Owner: osmi
--

CREATE INDEX idx_sessions_user ON auth.sessions USING btree (user_id);


--
-- Name: idx_users_email; Type: INDEX; Schema: auth; Owner: osmi
--

CREATE INDEX idx_users_email ON auth.users USING btree (email);


--
-- Name: idx_users_is_active; Type: INDEX; Schema: auth; Owner: osmi
--

CREATE INDEX idx_users_is_active ON auth.users USING btree (is_active);


--
-- Name: idx_order_items_order_id; Type: INDEX; Schema: billing; Owner: osmi
--

CREATE INDEX idx_order_items_order_id ON billing.order_items USING btree (order_id);


--
-- Name: idx_order_items_ticket_type_id; Type: INDEX; Schema: billing; Owner: osmi
--

CREATE INDEX idx_order_items_ticket_type_id ON billing.order_items USING btree (ticket_type_id);


--
-- Name: idx_orders_created_at; Type: INDEX; Schema: billing; Owner: osmi
--

CREATE INDEX idx_orders_created_at ON billing.orders USING btree (created_at);


--
-- Name: idx_orders_customer_email; Type: INDEX; Schema: billing; Owner: osmi
--

CREATE INDEX idx_orders_customer_email ON billing.orders USING btree (customer_email);


--
-- Name: idx_orders_customer_id; Type: INDEX; Schema: billing; Owner: osmi
--

CREATE INDEX idx_orders_customer_id ON billing.orders USING btree (customer_id);


--
-- Name: idx_orders_reservation_expires; Type: INDEX; Schema: billing; Owner: osmi
--

CREATE INDEX idx_orders_reservation_expires ON billing.orders USING btree (reservation_expires_at) WHERE (is_reservation = true);


--
-- Name: idx_orders_status; Type: INDEX; Schema: billing; Owner: osmi
--

CREATE INDEX idx_orders_status ON billing.orders USING btree (status);


--
-- Name: idx_payments_order_id; Type: INDEX; Schema: billing; Owner: osmi
--

CREATE INDEX idx_payments_order_id ON billing.payments USING btree (order_id);


--
-- Name: idx_payments_provider_transaction_id; Type: INDEX; Schema: billing; Owner: osmi
--

CREATE INDEX idx_payments_provider_transaction_id ON billing.payments USING btree (provider_transaction_id);


--
-- Name: idx_payments_status; Type: INDEX; Schema: billing; Owner: osmi
--

CREATE INDEX idx_payments_status ON billing.payments USING btree (status);


--
-- Name: idx_customers_country; Type: INDEX; Schema: crm; Owner: osmi
--

CREATE INDEX idx_customers_country ON crm.customers USING btree (country);


--
-- Name: idx_customers_created_at; Type: INDEX; Schema: crm; Owner: osmi
--

CREATE INDEX idx_customers_created_at ON crm.customers USING btree (created_at);


--
-- Name: idx_customers_email; Type: INDEX; Schema: crm; Owner: osmi
--

CREATE INDEX idx_customers_email ON crm.customers USING btree (email);


--
-- Name: idx_customers_is_active; Type: INDEX; Schema: crm; Owner: osmi
--

CREATE INDEX idx_customers_is_active ON crm.customers USING btree (is_active);


--
-- Name: idx_customers_user_id; Type: INDEX; Schema: crm; Owner: osmi
--

CREATE INDEX idx_customers_user_id ON crm.customers USING btree (user_id);


--
-- Name: idx_messages_next_retry_at; Type: INDEX; Schema: notifications; Owner: osmi
--

CREATE INDEX idx_messages_next_retry_at ON notifications.messages USING btree (next_retry_at) WHERE ((status)::text = ANY ((ARRAY['failed'::character varying, 'retrying'::character varying])::text[]));


--
-- Name: idx_messages_recipient_email; Type: INDEX; Schema: notifications; Owner: osmi
--

CREATE INDEX idx_messages_recipient_email ON notifications.messages USING btree (recipient_email);


--
-- Name: idx_messages_scheduled_for; Type: INDEX; Schema: notifications; Owner: osmi
--

CREATE INDEX idx_messages_scheduled_for ON notifications.messages USING btree (scheduled_for);


--
-- Name: idx_messages_status; Type: INDEX; Schema: notifications; Owner: osmi
--

CREATE INDEX idx_messages_status ON notifications.messages USING btree (status);


--
-- Name: idx_categories_event_id; Type: INDEX; Schema: ticketing; Owner: osmi
--

CREATE INDEX idx_categories_event_id ON ticketing.categories USING btree (event_id);


--
-- Name: idx_categories_is_active; Type: INDEX; Schema: ticketing; Owner: osmi
--

CREATE INDEX idx_categories_is_active ON ticketing.categories USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_categories_public_uuid; Type: INDEX; Schema: ticketing; Owner: osmi
--

CREATE INDEX idx_categories_public_uuid ON ticketing.categories USING btree (public_uuid);


--
-- Name: idx_events_country_city; Type: INDEX; Schema: ticketing; Owner: osmi
--

CREATE INDEX idx_events_country_city ON ticketing.events USING btree (country, city);


--
-- Name: idx_events_is_featured; Type: INDEX; Schema: ticketing; Owner: osmi
--

CREATE INDEX idx_events_is_featured ON ticketing.events USING btree (is_featured);


--
-- Name: idx_events_organizer_id; Type: INDEX; Schema: ticketing; Owner: osmi
--

CREATE INDEX idx_events_organizer_id ON ticketing.events USING btree (organizer_id);


--
-- Name: idx_events_slug; Type: INDEX; Schema: ticketing; Owner: osmi
--

CREATE INDEX idx_events_slug ON ticketing.events USING btree (slug);


--
-- Name: idx_events_starts_at; Type: INDEX; Schema: ticketing; Owner: osmi
--

CREATE INDEX idx_events_starts_at ON ticketing.events USING btree (starts_at);


--
-- Name: idx_events_status; Type: INDEX; Schema: ticketing; Owner: osmi
--

CREATE INDEX idx_events_status ON ticketing.events USING btree (status);


--
-- Name: idx_organizers_is_active; Type: INDEX; Schema: ticketing; Owner: osmi
--

CREATE INDEX idx_organizers_is_active ON ticketing.organizers USING btree (is_active);


--
-- Name: idx_organizers_slug; Type: INDEX; Schema: ticketing; Owner: osmi
--

CREATE INDEX idx_organizers_slug ON ticketing.organizers USING btree (slug);


--
-- Name: idx_ticket_types_event_id; Type: INDEX; Schema: ticketing; Owner: osmi
--

CREATE INDEX idx_ticket_types_event_id ON ticketing.ticket_types USING btree (event_id);


--
-- Name: idx_ticket_types_is_active; Type: INDEX; Schema: ticketing; Owner: osmi
--

CREATE INDEX idx_ticket_types_is_active ON ticketing.ticket_types USING btree (is_active);


--
-- Name: idx_ticket_types_is_sold_out; Type: INDEX; Schema: ticketing; Owner: osmi
--

CREATE INDEX idx_ticket_types_is_sold_out ON ticketing.ticket_types USING btree (is_sold_out);


--
-- Name: idx_ticket_types_sale_dates; Type: INDEX; Schema: ticketing; Owner: osmi
--

CREATE INDEX idx_ticket_types_sale_dates ON ticketing.ticket_types USING btree (sale_starts_at, sale_ends_at);


--
-- Name: idx_tickets_checked_in_at; Type: INDEX; Schema: ticketing; Owner: osmi
--

CREATE INDEX idx_tickets_checked_in_at ON ticketing.tickets USING btree (checked_in_at) WHERE (checked_in_at IS NOT NULL);


--
-- Name: idx_tickets_code; Type: INDEX; Schema: ticketing; Owner: osmi
--

CREATE INDEX idx_tickets_code ON ticketing.tickets USING btree (code);


--
-- Name: idx_tickets_customer_id; Type: INDEX; Schema: ticketing; Owner: osmi
--

CREATE INDEX idx_tickets_customer_id ON ticketing.tickets USING btree (customer_id);


--
-- Name: idx_tickets_event_id_status; Type: INDEX; Schema: ticketing; Owner: osmi
--

CREATE INDEX idx_tickets_event_id_status ON ticketing.tickets USING btree (event_id, status);


--
-- Name: idx_tickets_order_id; Type: INDEX; Schema: ticketing; Owner: osmi
--

CREATE INDEX idx_tickets_order_id ON ticketing.tickets USING btree (order_id);


--
-- Name: idx_tickets_reservation_expires; Type: INDEX; Schema: ticketing; Owner: osmi
--

CREATE INDEX idx_tickets_reservation_expires ON ticketing.tickets USING btree (reservation_expires_at) WHERE ((status)::text = 'reserved'::text);


--
-- Name: idx_venues_country_city; Type: INDEX; Schema: ticketing; Owner: osmi
--

CREATE INDEX idx_venues_country_city ON ticketing.venues USING btree (country, city);


--
-- Name: idx_venues_geolocation; Type: INDEX; Schema: ticketing; Owner: osmi
--

CREATE INDEX idx_venues_geolocation ON ticketing.venues USING gist (geolocation);


--
-- Name: idx_venues_slug; Type: INDEX; Schema: ticketing; Owner: osmi
--

CREATE INDEX idx_venues_slug ON ticketing.venues USING btree (slug);


--
-- Name: daily_metrics trg_update_daily_metrics; Type: TRIGGER; Schema: analytics; Owner: osmi
--

CREATE TRIGGER trg_update_daily_metrics BEFORE UPDATE ON analytics.daily_metrics FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();


--
-- Name: event_metrics trg_update_event_metrics; Type: TRIGGER; Schema: analytics; Owner: osmi
--

CREATE TRIGGER trg_update_event_metrics BEFORE UPDATE ON analytics.event_metrics FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();


--
-- Name: sessions trg_update_sessions; Type: TRIGGER; Schema: auth; Owner: osmi
--

CREATE TRIGGER trg_update_sessions BEFORE UPDATE ON auth.sessions FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();


--
-- Name: users trg_update_users; Type: TRIGGER; Schema: auth; Owner: osmi
--

CREATE TRIGGER trg_update_users BEFORE UPDATE ON auth.users FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();


--
-- Name: order_items trg_update_order_items; Type: TRIGGER; Schema: billing; Owner: osmi
--

CREATE TRIGGER trg_update_order_items BEFORE UPDATE ON billing.order_items FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();


--
-- Name: orders trg_update_orders; Type: TRIGGER; Schema: billing; Owner: osmi
--

CREATE TRIGGER trg_update_orders BEFORE UPDATE ON billing.orders FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();


--
-- Name: payment_providers trg_update_payment_providers; Type: TRIGGER; Schema: billing; Owner: osmi
--

CREATE TRIGGER trg_update_payment_providers BEFORE UPDATE ON billing.payment_providers FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();


--
-- Name: payments trg_update_payments; Type: TRIGGER; Schema: billing; Owner: osmi
--

CREATE TRIGGER trg_update_payments BEFORE UPDATE ON billing.payments FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();


--
-- Name: refunds trg_update_refunds; Type: TRIGGER; Schema: billing; Owner: osmi
--

CREATE TRIGGER trg_update_refunds BEFORE UPDATE ON billing.refunds FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();


--
-- Name: customers trg_customers_update; Type: TRIGGER; Schema: crm; Owner: osmi
--

CREATE TRIGGER trg_customers_update BEFORE UPDATE ON crm.customers FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: customers trg_update_customers; Type: TRIGGER; Schema: crm; Owner: osmi
--

CREATE TRIGGER trg_update_customers BEFORE UPDATE ON crm.customers FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();


--
-- Name: country_config trg_update_country_config; Type: TRIGGER; Schema: fiscal; Owner: osmi
--

CREATE TRIGGER trg_update_country_config BEFORE UPDATE ON fiscal.country_config FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();


--
-- Name: invoices trg_update_invoices; Type: TRIGGER; Schema: fiscal; Owner: osmi
--

CREATE TRIGGER trg_update_invoices BEFORE UPDATE ON fiscal.invoices FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();


--
-- Name: supported_currencies trg_update_supported_currencies; Type: TRIGGER; Schema: global; Owner: osmi
--

CREATE TRIGGER trg_update_supported_currencies BEFORE UPDATE ON global.supported_currencies FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();


--
-- Name: supported_languages trg_update_supported_languages; Type: TRIGGER; Schema: global; Owner: osmi
--

CREATE TRIGGER trg_update_supported_languages BEFORE UPDATE ON global.supported_languages FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();


--
-- Name: system_config trg_update_system_config; Type: TRIGGER; Schema: global; Owner: osmi
--

CREATE TRIGGER trg_update_system_config BEFORE UPDATE ON global.system_config FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();


--
-- Name: api_calls trg_update_api_calls; Type: TRIGGER; Schema: integration; Owner: osmi
--

CREATE TRIGGER trg_update_api_calls BEFORE UPDATE ON integration.api_calls FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();


--
-- Name: webhooks trg_update_webhooks; Type: TRIGGER; Schema: integration; Owner: osmi
--

CREATE TRIGGER trg_update_webhooks BEFORE UPDATE ON integration.webhooks FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();


--
-- Name: messages trg_update_messages; Type: TRIGGER; Schema: notifications; Owner: osmi
--

CREATE TRIGGER trg_update_messages BEFORE UPDATE ON notifications.messages FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();


--
-- Name: templates trg_update_templates; Type: TRIGGER; Schema: notifications; Owner: osmi
--

CREATE TRIGGER trg_update_templates BEFORE UPDATE ON notifications.templates FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();


--
-- Name: tickets trg_generate_ticket_code; Type: TRIGGER; Schema: ticketing; Owner: osmi
--

CREATE TRIGGER trg_generate_ticket_code BEFORE INSERT ON ticketing.tickets FOR EACH ROW EXECUTE FUNCTION ticketing.generate_ticket_code();


--
-- Name: events trg_update_events; Type: TRIGGER; Schema: ticketing; Owner: osmi
--

CREATE TRIGGER trg_update_events BEFORE UPDATE ON ticketing.events FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();


--
-- Name: organizers trg_update_organizers; Type: TRIGGER; Schema: ticketing; Owner: osmi
--

CREATE TRIGGER trg_update_organizers BEFORE UPDATE ON ticketing.organizers FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();


--
-- Name: ticket_types trg_update_ticket_types; Type: TRIGGER; Schema: ticketing; Owner: osmi
--

CREATE TRIGGER trg_update_ticket_types BEFORE UPDATE ON ticketing.ticket_types FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();


--
-- Name: tickets trg_update_tickets; Type: TRIGGER; Schema: ticketing; Owner: osmi
--

CREATE TRIGGER trg_update_tickets BEFORE UPDATE ON ticketing.tickets FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();


--
-- Name: venues trg_update_venues; Type: TRIGGER; Schema: ticketing; Owner: osmi
--

CREATE TRIGGER trg_update_venues BEFORE UPDATE ON ticketing.venues FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();


--
-- Name: categories update_categories_updated_at; Type: TRIGGER; Schema: ticketing; Owner: osmi
--

CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON ticketing.categories FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();


--
-- Name: event_metrics event_metrics_event_id_fkey; Type: FK CONSTRAINT; Schema: analytics; Owner: osmi
--

ALTER TABLE ONLY analytics.event_metrics
    ADD CONSTRAINT event_metrics_event_id_fkey FOREIGN KEY (event_id) REFERENCES ticketing.events(id);


--
-- Name: data_changes data_changes_user_id_fkey; Type: FK CONSTRAINT; Schema: audit; Owner: osmi
--

ALTER TABLE ONLY audit.data_changes
    ADD CONSTRAINT data_changes_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);


--
-- Name: security_logs security_logs_target_user_id_fkey; Type: FK CONSTRAINT; Schema: audit; Owner: osmi
--

ALTER TABLE ONLY audit.security_logs
    ADD CONSTRAINT security_logs_target_user_id_fkey FOREIGN KEY (target_user_id) REFERENCES auth.users(id);


--
-- Name: security_logs security_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: audit; Owner: osmi
--

ALTER TABLE ONLY audit.security_logs
    ADD CONSTRAINT security_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: osmi
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: osmi
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES auth.roles(id);


--
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: osmi
--

ALTER TABLE ONLY billing.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES billing.orders(id) ON DELETE CASCADE;


--
-- Name: order_items order_items_ticket_type_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: osmi
--

ALTER TABLE ONLY billing.order_items
    ADD CONSTRAINT order_items_ticket_type_id_fkey FOREIGN KEY (ticket_type_id) REFERENCES ticketing.ticket_types(id);


--
-- Name: orders orders_customer_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: osmi
--

ALTER TABLE ONLY billing.orders
    ADD CONSTRAINT orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES crm.customers(id);


--
-- Name: orders orders_payment_provider_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: osmi
--

ALTER TABLE ONLY billing.orders
    ADD CONSTRAINT orders_payment_provider_id_fkey FOREIGN KEY (payment_provider_id) REFERENCES billing.payment_providers(id);


--
-- Name: payments payments_order_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: osmi
--

ALTER TABLE ONLY billing.payments
    ADD CONSTRAINT payments_order_id_fkey FOREIGN KEY (order_id) REFERENCES billing.orders(id);


--
-- Name: payments payments_provider_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: osmi
--

ALTER TABLE ONLY billing.payments
    ADD CONSTRAINT payments_provider_id_fkey FOREIGN KEY (provider_id) REFERENCES billing.payment_providers(id);


--
-- Name: refunds refunds_approved_by_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: osmi
--

ALTER TABLE ONLY billing.refunds
    ADD CONSTRAINT refunds_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES auth.users(id);


--
-- Name: refunds refunds_order_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: osmi
--

ALTER TABLE ONLY billing.refunds
    ADD CONSTRAINT refunds_order_id_fkey FOREIGN KEY (order_id) REFERENCES billing.orders(id);


--
-- Name: refunds refunds_payment_id_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: osmi
--

ALTER TABLE ONLY billing.refunds
    ADD CONSTRAINT refunds_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES billing.payments(id);


--
-- Name: refunds refunds_requested_by_fkey; Type: FK CONSTRAINT; Schema: billing; Owner: osmi
--

ALTER TABLE ONLY billing.refunds
    ADD CONSTRAINT refunds_requested_by_fkey FOREIGN KEY (requested_by) REFERENCES auth.users(id);


--
-- Name: customers customers_user_id_fkey; Type: FK CONSTRAINT; Schema: crm; Owner: osmi
--

ALTER TABLE ONLY crm.customers
    ADD CONSTRAINT customers_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);


--
-- Name: invoices invoices_customer_id_fkey; Type: FK CONSTRAINT; Schema: fiscal; Owner: osmi
--

ALTER TABLE ONLY fiscal.invoices
    ADD CONSTRAINT invoices_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES crm.customers(id);


--
-- Name: invoices invoices_order_id_fkey; Type: FK CONSTRAINT; Schema: fiscal; Owner: osmi
--

ALTER TABLE ONLY fiscal.invoices
    ADD CONSTRAINT invoices_order_id_fkey FOREIGN KEY (order_id) REFERENCES billing.orders(id);


--
-- Name: api_calls api_calls_user_id_fkey; Type: FK CONSTRAINT; Schema: integration; Owner: osmi
--

ALTER TABLE ONLY integration.api_calls
    ADD CONSTRAINT api_calls_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);


--
-- Name: messages messages_recipient_user_id_fkey; Type: FK CONSTRAINT; Schema: notifications; Owner: osmi
--

ALTER TABLE ONLY notifications.messages
    ADD CONSTRAINT messages_recipient_user_id_fkey FOREIGN KEY (recipient_user_id) REFERENCES auth.users(id);


--
-- Name: messages messages_template_id_fkey; Type: FK CONSTRAINT; Schema: notifications; Owner: osmi
--

ALTER TABLE ONLY notifications.messages
    ADD CONSTRAINT messages_template_id_fkey FOREIGN KEY (template_id) REFERENCES notifications.templates(id);


--
-- Name: events events_organizer_id_fkey; Type: FK CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.events
    ADD CONSTRAINT events_organizer_id_fkey FOREIGN KEY (organizer_id) REFERENCES ticketing.organizers(id);


--
-- Name: events events_venue_id_fkey; Type: FK CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.events
    ADD CONSTRAINT events_venue_id_fkey FOREIGN KEY (venue_id) REFERENCES ticketing.venues(id);


--
-- Name: categories fk_categories_event; Type: FK CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.categories
    ADD CONSTRAINT fk_categories_event FOREIGN KEY (event_id) REFERENCES ticketing.events(public_uuid) ON DELETE CASCADE;


--
-- Name: organizers organizers_user_id_fkey; Type: FK CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.organizers
    ADD CONSTRAINT organizers_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);


--
-- Name: ticket_types ticket_types_event_id_fkey; Type: FK CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.ticket_types
    ADD CONSTRAINT ticket_types_event_id_fkey FOREIGN KEY (event_id) REFERENCES ticketing.events(id) ON DELETE CASCADE;


--
-- Name: tickets tickets_checked_in_by_fkey; Type: FK CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.tickets
    ADD CONSTRAINT tickets_checked_in_by_fkey FOREIGN KEY (checked_in_by) REFERENCES auth.users(id);


--
-- Name: tickets tickets_customer_id_fkey; Type: FK CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.tickets
    ADD CONSTRAINT tickets_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES crm.customers(id);


--
-- Name: tickets tickets_event_id_fkey; Type: FK CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.tickets
    ADD CONSTRAINT tickets_event_id_fkey FOREIGN KEY (event_id) REFERENCES ticketing.events(id);


--
-- Name: tickets tickets_reserved_by_fkey; Type: FK CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.tickets
    ADD CONSTRAINT tickets_reserved_by_fkey FOREIGN KEY (reserved_by) REFERENCES auth.users(id);


--
-- Name: tickets tickets_ticket_type_id_fkey; Type: FK CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.tickets
    ADD CONSTRAINT tickets_ticket_type_id_fkey FOREIGN KEY (ticket_type_id) REFERENCES ticketing.ticket_types(id);


--
-- Name: tickets tickets_transferred_from_fkey; Type: FK CONSTRAINT; Schema: ticketing; Owner: osmi
--

ALTER TABLE ONLY ticketing.tickets
    ADD CONSTRAINT tickets_transferred_from_fkey FOREIGN KEY (transferred_from) REFERENCES crm.customers(id);


--
-- PostgreSQL database dump complete
--

\unrestrict SMMWPsEUJhAEi09pPfcgvb7da0SllljczanCkyo4sldzcDeKKZ9fhGKQmJ0ZTiO

