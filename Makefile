# =============================================================================
# OSMI DATABASE - Makefile
# =============================================================================
#
# Comandos:
#   make up              - Levantar contenedores
#   make down            - Detener contenedores
#   make down-v          - Detener contenedores y eliminar volúmenes
#   make migrate-up      - Ejecutar migraciones UP
#   make migrate-down    - Ejecutar migraciones DOWN (última)
#   make migrate-down-all - Revertir TODAS las migraciones
#   make reset           - Resetear base (down-v + up + migrate-up)
#   make status          - Estado de migraciones
#   make shell           - Conectar a PostgreSQL
#   make dump-schema     - Generar schema.sql de la base actual en build/
#   make validate        - Validar migraciones vs schema.sql original
#
# =============================================================================

.PHONY: up down down-v migrate-up migrate-down migrate-down-all reset status shell dump-schema validate

# Variables
DOCKER_COMPOSE = docker compose
POSTGRES_USER = osmi
POSTGRES_DB = osmidb
POSTGRES_HOST = postgres
POSTGRES_PORT = 5432
POSTGRES_PASSWORD ?= $$(grep POSTGRES_PASSWORD .env 2>/dev/null | cut -d '=' -f2)

# URL de conexión para migrate (escapada para shell)
DATABASE_URL = postgres://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@$(POSTGRES_HOST):$(POSTGRES_PORT)/$(POSTGRES_DB)?sslmode=disable

# Comando base para migrate
MIGRATE_CMD = $(DOCKER_COMPOSE) run --rm \
	-e DATABASE_URL='$(DATABASE_URL)' \
	migrate \
	-path /migrations \
	-database '$(DATABASE_URL)'

# =============================================================================
# Gestión de contenedores
# =============================================================================

up:
	$(DOCKER_COMPOSE) up -d

down:
	$(DOCKER_COMPOSE) down

down-v:
	$(DOCKER_COMPOSE) down -v

# =============================================================================
# Migraciones
# =============================================================================

migrate-up:
	@echo "⏳ Esperando a que PostgreSQL esté listo..."
	@until $(DOCKER_COMPOSE) exec postgres pg_isready -U $(POSTGRES_USER) -d $(POSTGRES_DB) > /dev/null 2>&1; do \
		echo "⏳ Esperando PostgreSQL..."; \
		sleep 2; \
	done
	@echo "✅ PostgreSQL listo. Ejecutando migraciones UP..."
	$(MIGRATE_CMD) up

migrate-down:
	@echo "⬇️  Revertiendo última migración..."
	$(MIGRATE_CMD) down 1

migrate-down-all:
	@echo "⬇️  Revertiendo TODAS las migraciones..."
	$(MIGRATE_CMD) down -all

# =============================================================================
# Reseteo completo
# =============================================================================

reset: down-v up migrate-up
	@echo "✅ Base de datos reseteada completamente"

# =============================================================================
# Utilidades
# =============================================================================

status:
	$(MIGRATE_CMD) version

shell:
	$(DOCKER_COMPOSE) exec postgres psql -U $(POSTGRES_USER) -d $(POSTGRES_DB)

dump-schema:
	mkdir -p ./build
	$(DOCKER_COMPOSE) exec postgres pg_dump -U $(POSTGRES_USER) -d $(POSTGRES_DB) --schema-only --no-owner --no-privileges > ./build/schema_rebuilt.sql
	@echo "✅ Schema generado en ./build/schema_rebuilt.sql"
	@echo "📊 Líneas: $$(wc -l < ./build/schema_rebuilt.sql)"

validate: dump-schema
	@echo ""
	@echo "============================================================"
	@echo "🔍 VALIDANDO MIGRACIONES"
	@echo "============================================================"
	@echo "📄 Comparando ./inventory/schema.sql con ./build/schema_rebuilt.sql"
	@echo ""
	@if diff -q --ignore-all-space --ignore-blank-lines ./inventory/schema.sql ./build/schema_rebuilt.sql > /dev/null 2>&1; then \
		echo "✅ ¡LAS MIGRACIONES SON VÁLIDAS!"; \
		echo "✅ La base reconstruida es IDÉNTICA al schema.sql original."; \
		echo "============================================================"; \
	else \
		echo "⚠️  Se encontraron diferencias:"; \
		echo ""; \
		diff -u --ignore-all-space --ignore-blank-lines ./inventory/schema.sql ./build/schema_rebuilt.sql || true; \
		echo ""; \
		echo "============================================================"; \
		echo "📁 Revisa ./build/schema_rebuilt.sql"; \
		echo "📁 Revisa las diferencias mostradas arriba"; \
		echo "============================================================"; \
	fi