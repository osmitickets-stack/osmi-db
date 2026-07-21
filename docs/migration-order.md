# Migration Order

## 000001_initial_schema
- ✅ Extensions
- ✅ Schemas
- ✅ Domains
- ✅ Shared Functions

## 000002_auth
- ✅ auth.roles
- ✅ auth.users
- ✅ auth.sessions
- ✅ Constraints
- ✅ Indexes
- ✅ Triggers

## 000003_crm
- ✅ crm.customers
- ✅ Indexes
- ✅ Triggers

## 000004_ticketing
- ✅ ticketing.venues
- ✅ ticketing.organizers
- ✅ ticketing.categories
- ✅ ticketing.events
- ✅ ticketing.ticket_types
- ✅ ticketing.tickets
- ✅ Constraints
- ✅ Indexes
- ✅ Triggers

## 000005_billing
- ✅ billing.payment_providers
- ✅ billing.orders
- ✅ billing.order_items
- ✅ billing.payments
- ✅ billing.refunds
- ✅ Indexes
- ✅ Triggers

## 000006_fiscal
- ✅ fiscal.country_config
- ✅ fiscal.invoices
- ✅ Triggers

## 000007_notifications
- ✅ notifications.templates
- ✅ notifications.messages
- ✅ Indexes
- ✅ Triggers

## 000008_analytics
- ✅ analytics.daily_metrics
- ✅ analytics.event_metrics
- ✅ Indexes
- ✅ Triggers

## 000009_audit
- ✅ audit.data_changes
- ✅ audit.security_logs
- ✅ audit.stripe_events
- ✅ Indexes

## 000010_integration
- ✅ integration.webhooks
- ✅ integration.api_calls
- ✅ Triggers