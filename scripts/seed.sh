#!/bin/sh

set -e

export PGPASSWORD="$POSTGRES_PASSWORD"

echo "Running system seeds..."
psql \
    -h postgres \
    -U osmi \
    -d osmidb \
    -f /seeds/001_system.sql

echo "Running catalog seeds..."
psql \
    -h postgres \
    -U osmi \
    -d osmidb \
    -f /seeds/002_catalog.sql

if [ -f /seeds/003_demo.sql ]; then
    echo "Running demo seeds..."
    psql \
        -h postgres \
        -U osmi \
        -d osmidb \
        -f /seeds/003_demo.sql
fi

echo "Seeds completed."