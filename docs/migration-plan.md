000001_initial_schema.up.sql
├── Extensiones (uuid-ossp, pgcrypto, pg_stat_statements, pg_trgm, btree_gin, btree_gist, postgis, fuzzystrmatch, unaccent)
├── Schemas (auth, crm, global, ticketing, billing, fiscal, notifications, analytics, audit, integration)
└── Dominios (email_address, phone_number, currency_code, percentage, country_code, timezone_name, event_status, ticket_status, payment_status)

000002_auth.up.sql
├── auth.roles
├── auth.users (con FK a roles)
└── auth.sessions (con FK a users)

000003_crm.up.sql
└── crm.customers (con FK a auth.users)

000004_ticketing.up.sql
├── ticketing.venues
├── ticketing.organizers (con FK a auth.users)
├── ticketing.categories (con FK a events.public_uuid)
├── ticketing.events (con FK a organizers, venues)
├── ticketing.ticket_types (con FK a events)
└── ticketing.tickets (con FK a ticket_types, events, customers, users)

000005_billing.up.sql
├── billing.payment_providers
├── billing.orders (con FK a customers, payment_providers)
├── billing.order_items (con FK a orders, ticket_types)
├── billing.payments (con FK a orders, payment_providers)
└── billing.refunds (con FK a payments, orders, users)

000006_fiscal.up.sql
├── fiscal.country_config
└── fiscal.invoices (con FK a orders, customers)

000007_notifications.up.sql
├── notifications.templates
└── notifications.messages (con FK a templates, users)

000008_analytics.up.sql
├── analytics.daily_metrics
└── analytics.event_metrics (con FK a events)

000009_audit.up.sql
├── audit.data_changes (con FK a users)
├── audit.security_logs (con FK a users)
└── audit.stripe_events

000010_integration.up.sql
├── integration.webhooks
└── integration.api_calls (con FK a users)

000011_functions_triggers.up.sql
├── Funciones (update_updated_at, generate_ticket_code, check_ticket_availability)
└── Triggers (26 triggers)

000012_indexes.up.sql
└── Índices (45 índices)