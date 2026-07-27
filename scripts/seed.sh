#!/bin/sh

set -e

export PGPASSWORD="$POSTGRES_PASSWORD"

echo "========================================"
echo "Running database seeds..."
echo "========================================"

for file in /seeds/*.sql
do
    echo ""
    echo "Executing $(basename "$file")..."
    psql \
        -h postgres \
        -U osmi \
        -d osmidb \
        -f "$file"
done

echo ""
echo "========================================"
echo "All seeds completed successfully."
echo "========================================"