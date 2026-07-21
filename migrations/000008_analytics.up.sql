-- =============================================================================
-- OSMI DATABASE
-- Migración 000008 — Analytics Schema
-- =============================================================================
--
-- Esta migración crea el módulo de Analytics:
--   ✅ analytics.daily_metrics
--   ✅ analytics.event_metrics
--   ✅ analytics.sales_report (VIEW)
--   ✅ Constraints (PK, UNIQUE, FK, CHECK)
--   ✅ Indexes
--   ✅ Triggers
--
-- Dependencias:
--   - 000001_initial_schema (dominios, función update_updated_at)
--   - 000004_ticketing (ticketing.events)
--   - 000005_billing (billing.orders, billing.order_items)
--
-- =============================================================================

-- =============================================================================
-- 1. TABLAS
-- =============================================================================

-- =============================================================================
-- analytics.daily_metrics
-- =============================================================================

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

CREATE SEQUENCE analytics.daily_metrics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE analytics.daily_metrics_id_seq OWNED BY analytics.daily_metrics.id;

ALTER TABLE ONLY analytics.daily_metrics ALTER COLUMN id SET DEFAULT nextval('analytics.daily_metrics_id_seq'::regclass);

-- =============================================================================
-- analytics.event_metrics
-- =============================================================================

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

CREATE SEQUENCE analytics.event_metrics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE analytics.event_metrics_id_seq OWNED BY analytics.event_metrics.id;

ALTER TABLE ONLY analytics.event_metrics ALTER COLUMN id SET DEFAULT nextval('analytics.event_metrics_id_seq'::regclass);

-- =============================================================================
-- 2. VIEWS
-- =============================================================================

-- =============================================================================
-- analytics.sales_report
-- =============================================================================

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

-- =============================================================================
-- 3. CONSTRAINTS
-- =============================================================================

-- =============================================================================
-- analytics.daily_metrics
-- =============================================================================

ALTER TABLE ONLY analytics.daily_metrics
    ADD CONSTRAINT daily_metrics_pkey PRIMARY KEY (id);

ALTER TABLE ONLY analytics.daily_metrics
    ADD CONSTRAINT daily_metrics_metric_date_metric_type_key UNIQUE (metric_date, metric_type);

-- =============================================================================
-- analytics.event_metrics
-- =============================================================================

ALTER TABLE ONLY analytics.event_metrics
    ADD CONSTRAINT event_metrics_pkey PRIMARY KEY (id);

ALTER TABLE ONLY analytics.event_metrics
    ADD CONSTRAINT event_metrics_event_id_key UNIQUE (event_id);

ALTER TABLE ONLY analytics.event_metrics
    ADD CONSTRAINT event_metrics_event_id_fkey FOREIGN KEY (event_id) REFERENCES ticketing.events(id);

-- =============================================================================
-- 4. INDEXES
-- =============================================================================

-- =============================================================================
-- analytics.daily_metrics
-- =============================================================================

CREATE INDEX idx_daily_metrics_date ON analytics.daily_metrics USING btree (metric_date);

-- =============================================================================
-- analytics.event_metrics
-- =============================================================================

CREATE INDEX idx_event_metrics_event_id ON analytics.event_metrics USING btree (event_id);

-- =============================================================================
-- 5. TRIGGERS
-- =============================================================================

-- =============================================================================
-- analytics.daily_metrics
-- =============================================================================

CREATE TRIGGER trg_update_daily_metrics BEFORE UPDATE ON analytics.daily_metrics FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();

-- =============================================================================
-- analytics.event_metrics
-- =============================================================================

CREATE TRIGGER trg_update_event_metrics BEFORE UPDATE ON analytics.event_metrics FOR EACH ROW EXECUTE FUNCTION auth.update_updated_at();

-- =============================================================================
-- FIN DE LA MIGRACIÓN 000008
-- =============================================================================