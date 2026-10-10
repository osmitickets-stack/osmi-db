# OSMI DB

`osmi-db` es la **única fuente oficial del esquema PostgreSQL de OSMI**.

Su responsabilidad es definir, versionar y evolucionar la estructura de la base de datos mediante migraciones SQL versionadas.

Este repositorio:

- no contiene lógica de negocio;
- no expone APIs;
- no ejecuta servicios HTTP;
- no sustituye al backend de aplicación;
- no administra manualmente una base de datos viva.

Su propósito es mantener el ciclo de vida del esquema de PostgreSQL de forma **reproducible, auditable y versionada**.

---

## Responsabilidad del módulo

`osmi-db` define oficialmente:

- estructura de tablas;
- columnas;
- restricciones;
- relaciones;
- índices;
- cambios estructurales;
- migraciones de evolución;
- reversión de cambios mediante migraciones `DOWN`;
- datos de referencia gestionados mediante `seeds/`.

La ejecución de migraciones pertenece al proceso de despliegue.

---

## Principio fundamental

> **La estructura oficial de PostgreSQL vive exclusivamente en `osmi-db`.**

Cualquier modificación estructural realizada fuera de este repositorio queda fuera del flujo oficial del proyecto.

A partir de la adopción de migraciones versionadas:

- no se agregan columnas manualmente en producción;
- no se crean tablas directamente en una base viva;
- no se corrigen estructuras mediante SQL ad hoc;
- no se modifica el esquema desde `osmi-server`;
- cada evolución estructural se expresa mediante una nueva migración.

---

## Filosofía de evolución

```text
Desarrollo local
      │
      ▼
Migración versionada
      │
      ▼
Git
      │
      ▼
GitHub
      │
      ▼
CI/CD
      │
      ▼
Docker Build
      │
      ▼
GHCR
      │
      ▼
Deploy Database
      │
      ├── pull migrate
      ├── pull seed
      │
      ▼
Migraciones pendientes
      │
      ▼
Seeds correspondientes
      │
      ▼
PostgreSQL actualizado
```

La base de datos no se mantiene mediante cambios manuales repetidos entre entornos.

El objetivo es que el mismo historial versionado pueda reconstruir de manera consistente el esquema esperado.

---

## Estrategia de migraciones

Cada migración representa un cambio **pequeño, atómico y versionado**.

### Reglas

1. Nunca modificar una migración que ya fue ejecutada.
2. Nunca renombrar una migración existente una vez incorporada al historial.
3. Nunca reutilizar un número de migración.
4. No mezclar cambios estructurales independientes sin necesidad.
5. Cada nuevo cambio estructural crea un nuevo par:
   - `.up.sql`
   - `.down.sql`
6. El archivo `UP` aplica el cambio.
7. El archivo `DOWN` revierte ese mismo cambio.

Ejemplo:

```text
000010_add_indexes.up.sql
000010_add_indexes.down.sql
```

---

## Migración inicial

La migración:

```text
000001_initial_schema
```

representa la fotografía inicial versionada del esquema histórico de OSMI.

No fue diseñada como una base nueva desde cero. Fue obtenida a partir del esquema existente para convertir la base histórica en un sistema administrado mediante migraciones.

A partir de ese punto, toda evolución posterior debe realizarse exclusivamente mediante nuevas migraciones.

```text
000001_initial_schema
        │
        ├── estado base versionado
        │
        ▼
000002_...
        │
        ▼
000003_...
        │
        ▼
...
```

---

## Migraciones `UP` y `DOWN`

Cada migración debe contener dos archivos.

Ejemplo:

```text
000010_add_indexes.up.sql
000010_add_indexes.down.sql
```

### `UP`

Aplica el cambio:

```text
estado N
   │
   ▼
estado N + 1
```

### `DOWN`

Revierte específicamente ese cambio:

```text
estado N + 1
   │
   ▼
estado N
```

Esta estrategia permite mantener:

- historial de cambios;
- capacidad de rollback;
- auditoría;
- despliegues reproducibles;
- reconstrucción de entornos.

Un `DOWN` debe representar la reversión correspondiente a su `UP`; no debe utilizarse como un mecanismo genérico para modificar otras partes del esquema.

---

## Seeds

Los archivos dentro de:

```text
seeds/
```

no forman parte del historial estructural de migraciones.

Su responsabilidad es insertar datos de referencia necesarios para determinados entornos o procesos del proyecto.

### Regla de separación

```text
migrations/
    ↓
estructura

seeds/
    ↓
datos de referencia
```

Las seeds:

- no crean tablas;
- no sustituyen migraciones;
- no modifican la definición estructural del esquema;
- no son una segunda fuente de verdad del modelo de datos.

---

## Separación con `osmi-server`

La frontera entre ambos módulos es explícita:

```text
osmi-db
   │
   ├── migrations/
   ├── seeds/
   └── definición oficial del esquema
           │
           ▼
      PostgreSQL
           ▲
           │
osmi-server
   │
   ├── repositories
   ├── transactions
   └── lógica de aplicación
```

`osmi-server` consume el esquema.

`osmi-db` lo define y versiona.

El backend no debe crear una segunda estrategia de migraciones ni mantener copias divergentes del esquema.

---

## Despliegue

Las migraciones se ejecutan como parte del despliegue.

Flujo esperado:

```text
docker compose up
        │
        ▼
PostgreSQL
        │
        ▼
Health Check
        │
        ▼
Migration Container
        │
        ▼
golang-migrate
        │
        ▼
Migraciones pendientes
        │
        ▼
Migration Container termina
        │
        ▼
Servicios de aplicación
```

El contenedor de migraciones es una tarea de despliegue.

No debe convertirse en un servicio permanente.

---

## Imágenes de despliegue

El flujo de producción utiliza imágenes construidas y publicadas en GHCR.

Conceptualmente:

```text
Local
  │
  ▼
Git
  │
  ▼
GitHub
  │
  ▼
CI/CD
  │
  ▼
Docker Image
  │
  ▼
GHCR
  │
  ▼
EC2
```

La instancia de producción no es el lugar donde se desarrollan o editan migraciones.

Las nuevas migraciones se crean, revisan, versionan y publican antes de llegar al entorno de producción.

---

## Producción

La base de datos productiva debe evolucionar mediante el historial oficial de migraciones.

No se considera parte del procedimiento normal:

```text
❌ ALTER TABLE manual en producción
❌ CREATE TABLE manual
❌ modificar archivos de migraciones ya aplicadas
❌ inventar numeraciones nuevas sobre migraciones existentes
❌ editar el esquema directamente desde EC2
❌ usar osmi-server como administrador del esquema
```

Cuando se requiere una evolución:

```text
nuevo requisito
      │
      ▼
nueva migración
      │
      ▼
review
      │
      ▼
Git
      │
      ▼
CI/CD
      │
      ▼
deploy
```

---

## Evolución del esquema

Ejemplo: agregar soporte para cupones.

```text
000024_add_coupons.up.sql
000024_add_coupons.down.sql
```

Ejemplo: agregar un marketplace.

```text
000037_marketplace.up.sql
000037_marketplace.down.sql
```

No se modifica una migración histórica para incorporar una funcionalidad nueva.

Cada cambio conserva su propia identidad dentro del historial.

---

## Reproducibilidad

Uno de los objetivos principales de `osmi-db` es que una base nueva pueda llegar al estado esperado utilizando el historial oficial de migraciones.

Conceptualmente:

```text
PostgreSQL vacío
      │
      ▼
000001
      │
      ▼
000002
      │
      ▼
000003
      │
      ▼
...
      │
      ▼
última migración
      │
      ▼
esquema actual
```

Esto evita depender de conocimiento manual sobre cómo fue modificada una instancia específica.

---

## Seguridad operacional

Para proteger el historial y los datos:

- no se modifican migraciones ya aplicadas;
- no se reutilizan números;
- no se realizan cambios estructurales manuales en producción;
- las migraciones se prueban antes del despliegue;
- los cambios estructurales pertenecen a este repositorio;
- los secretos de conexión no deben almacenarse en Git;
- un rollback debe corresponder al cambio que pretende revertir.

Las operaciones destructivas sobre producción no forman parte del flujo rutinario de desarrollo.

---

## Relación con el resto de OSMI

```text
osmi-db
   → esquema y migraciones PostgreSQL

osmi-server
   → lógica de negocio y persistencia

osmi-protobuf
   → contratos gRPC/HTTP

osmi-gateway
   → entrada HTTP y puente REST/gRPC

osmi-front
   → aplicación web
```

Cada módulo mantiene su propia documentación, responsabilidad y ciclo de cambios.

---

## Convenciones

### Nombre de migraciones

```text
NNNNNN_descripcion.up.sql
NNNNNN_descripcion.down.sql
```

Ejemplo:

```text
000024_add_coupons.up.sql
000024_add_coupons.down.sql
```

El nombre debe describir el cambio de forma breve y específica.

### Un cambio, una evolución identificable

Una migración debe ser suficientemente pequeña para:

- comprender qué modifica;
- revisar su impacto;
- revertirla de forma razonable;
- auditar cuándo entró al sistema.

---

## Qué pertenece a este repositorio

```text
✅ migraciones SQL
✅ reversión de migraciones
✅ seeds de referencia
✅ documentación del esquema
✅ evolución versionada de PostgreSQL
```

## Qué no pertenece a este repositorio

```text
❌ lógica de negocio
❌ handlers
❌ servicios HTTP
❌ lógica Stripe
❌ lógica de checkout
❌ envío de email
❌ lógica del frontend
❌ contratos gRPC
```

---

## Estado arquitectónico

`osmi-db` establece la frontera definitiva para el esquema:

```text
              osmi-db
                 │
                 ▼
       Migraciones versionadas
                 │
                 ▼
            PostgreSQL
                 ▲
                 │
       ┌─────────┴─────────┐
       │                   │
 osmi-server          otros consumidores
```

El esquema se administra desde un solo lugar.

Eso evita:

- drift entre ambientes;
- modificaciones imposibles de auditar;
- dependencias de cambios manuales;
- múltiples fuentes de verdad;
- reconstrucciones incompletas de la base.

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
├── migrations/                           #    Archivos versionados de migración (.up.sql / .down.sql)
│   ├── 000001_initial_schema.up.sql
│   ├── 000001_initial_schema.down.sql
│   ├── 000002_auth.up.sql
│   └── 000002_auth.down.sql
│   ├── 000003_crm.down.sql
│   └── 000003_crm.up.sql
│   ├── 000004_ticketing.down.sql
│   └── 000004_ticketing.up.sql
│   ├── 000005_billing.down.sql
│   └── 000005_billing.up.sql
│   ├── 000006_fiscal.down.sql
│   └── 000006_fiscal.up.sql
│   ├── 000007_notifications.down.sql
│   └── 000007_notifications.up.sql
│   ├── 000008_analytics.down.sql
│   └── 000008_analytics.up.sql
│   ├── 000009_audit.down.sql
│   └── 000009_audit.up.sql
│   ├── 000010_integration.down.sql
│   └── 000010_integration.up.sql
│   ├── 000011_event_types.down.sql
│   └── 000011_event_types.up.sql
│   ├── 000012_add_global_tables.down.sql
│   └── 000012_add_global_tables.up.sql
│   ├── 
│   └── 
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

## Autor

**Francisco David Zamora Urrutia** | Fullstack Developer · Systems Engineer