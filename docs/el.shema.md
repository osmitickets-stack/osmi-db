3. inventory/schema.sql

Este NO se mueve.

Debe quedarse exactamente ahí.

inventory/
    schema.sql

Porque ese archivo tiene una función completamente distinta.

No es una migración.

Es el snapshot oficial del esquema.

Es la fotografía de la base.

Cada vez que quieras auditar nuevamente:

backup
↓

schema.sql nuevo
↓

comparación
↓

migraciones

Ese archivo vive para siempre en:

inventory/
4. Entonces la estructura queda así
osmi-db/

archive/
└── legacy/
    ├── 001_complete_schema.sql
    ├── 000002_catalog.up.sql
    └── 000002_catalog.down.sql

inventory/
├── inventory.txt
└── schema.sql        ← FUENTE DE VERDAD

migrations/
    ← VACÍA

seeds/