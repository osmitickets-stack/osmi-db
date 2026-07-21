# osmi-db

osmi-db es la única fuente oficial del esquema de PostgreSQL. Su responsabilidad es definir, versionar y evolucionar la estructura de la base de datos mediante migraciones SQL versionadas.

Este repositorio no contiene lógica de negocio, no expone APIs, no ejecuta servicios HTTP y no forma parte del backend de aplicación. Su único propósito es administrar el ciclo de vida del esquema de PostgreSQL.
Toda la ejecución de migraciones es responsabilidad del despliegue.

Base real
        │
        ▼
inventory
        │
        ▼
schema.sql
        │
        ▼
analizar absolutamente todo
        │
        ▼
documentar
        │
        ▼
crear migraciones

# Fase 6 — Evolución

A partir de aquí nunca volvemos a tocar la base manualmente.

Cuando quieras agregar:

```
Coupons
```

Creas:

```
000024_add_coupons.up.sql
```

Cuando quieras:

```
Marketplace
```

Creas:

000037_marketplace.up.sql
---

## Estructura

```bash
osmi-db/
├── docs/
│   └── migration-plan.md
│   └── migration-order.md
├── inventory/
│   ├── README.md                  ← Explica qué es esta carpeta
│   ├── inventory.txt              ← Inventario bruto generado desde PostgreSQL
│   ├── schema.sql                 ← DDL completo generado con pg_restore -s / original del backup
│   ├── 3.1_extensions.md
│   ├── 3.2_schemas.md
│   ├── 3.3_schema_responsibilities.md
│   ├── 3.4_tables.md
│   ├── 3.5_relationships.md
│   ├── 3.6_indexes.md
│   ├── 3.7_constraints.md
│   ├── 3.8_triggers.md
│   ├── 3.9_functions.md
│   └── 3.10_architecture.md
│   └── 3.11_domains.md
│
├── migrations/                           #    Archivos versionados de migración (.up.sql / .down.sql)
│   ├── 000001_initial_schema.up.sql
│   ├── 000001_initial_schema.down.sql
│   ├── 000002_*.up.sql
│   └── 000002_*.down.sql

├── seeds/                                #    Datos iniciales opcionales
│   ├── development.sql
│   └── testing.sql

├── build//                    # 
│   └── schema_rebuilt.sql         # Generado con make dump-schema
├── docker-compose.yml             # 
├── .gitignore
├── CHANGELOG.md
├── Dockerfile
├── LICENSE
├── Makefile
└── LICENSE.md
└── README.md
```
## Objetivos

Versionar toda la estructura de PostgreSQL.
Permitir despliegues reproducibles.
Mantener un historial completo de cambios.
Permitir rollback seguro.
Garantizar que cualquier entorno pueda reconstruirse desde cero.
---

## Filosofía

La base de datos nunca vuelve a modificarse manualmente.
Todo cambio estructural sigue siempre el mismo flujo:
```
Developer
↓
osmi-db
↓
Git
↓
GitHub
↓
CI/CD
↓
Docker Image
↓
EC2
↓
golang-migrate
↓
PostgreSQL
```

PostgreSQL nunca es el origen del esquema. El origen siempre será este repositorio.

---

## Estrategia de migraciones

Cada migración representa un cambio pequeño, atómico y versionado.

Reglas:

Nunca modificar una migración ya ejecutada.
Nunca renombrar migraciones existentes.
Nunca reutilizar números.
Nunca combinar varios cambios distintos en una sola migración.
Cada cambio estructural crea un nuevo par .up.sql y .down.sql.

Ejemplo:

000021_add_coupon_table.up.sql

000021_add_coupon_table.down.sql

## Migración inicial

000001_initial_schema

representa una fotografía exacta del esquema original de Osmi.

No fue diseñada desde cero.

Fue obtenida a partir del esquema existente para convertir la base de datos histórica en un esquema completamente versionado.

A partir de esa migración, toda evolución futura se realiza únicamente mediante nuevas migraciones.

## Migraciones UP y DOWN

Cada migración debe tener dos archivos.

000010_add_indexes.up.sql

000010_add_indexes.down.sql

El archivo UP aplica el cambio.

El archivo DOWN revierte exactamente ese mismo cambio.

Esto permite:

rollback seguro
recuperación de despliegues
auditoría completa
reproducibilidad

## Seeds

Los archivos dentro de seeds/ no forman parte del historial de migraciones.

Su propósito es insertar datos de referencia para desarrollo o pruebas.

Ejemplos:

países
monedas
categorías
roles
datos de demostración

Las seeds nunca crean tablas.

Las seeds nunca modifican el esquema.

## Despliegue

Este repositorio nunca se ejecuta manualmente sobre producción.

Durante un despliegue el flujo es:

docker compose up

↓

PostgreSQL

↓

Health Check

↓

Contenedor migration

↓

golang-migrate

↓

Aplicación de migraciones pendientes

↓

Fin del contenedor

↓

Gateway

↓

Server

↓

Nginx

El contenedor de migraciones existe únicamente durante el despliegue.

Después termina.

## Infraestructura

La EC2 de producción no contiene una copia editable de este repositorio.

Únicamente recibe una imagen construida durante el proceso de CI/CD.

El flujo es:

Local

↓

Git

↓

GitHub

↓

CI/CD

↓

Docker Image

↓

GHCR

↓

EC2

Nunca se desarrollan migraciones directamente en producción.

## Buenas prácticas
No ejecutar SQL manual en producción.
No editar migraciones históricas.
Crear una migración por cambio.
Mantener migraciones pequeñas.
Utilizar nombres descriptivos.
Versionar todo mediante Git.
Mantener compatibilidad hacia atrás cuando sea posible.

## Evolución del esquema

Cuando un nuevo módulo sea agregado al ecosistema (Marketplace, Loyalty, IA, Facturación, etc.) no se modifican migraciones anteriores.

Simplemente se agrega una nueva migración.

Ejemplo:

000042_loyalty.up.sql

000043_marketplace.up.sql

000044_predictions.up.sql

Esto permite que el historial permanezca inmutable.

## Principio fundamental

La estructura oficial de PostgreSQL vive exclusivamente en osmi-db.

Cualquier modificación estructural que no pase por este repositorio se considera fuera del flujo oficial del proyecto.

## Autor
- Francisco David Zamora Urrutia — Fullstack Developer & Systems Engineer