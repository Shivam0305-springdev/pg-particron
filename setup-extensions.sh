#!/bin/bash
set -e

# 1. Capture DB name and User name, falling back to 'postgres' if blank
DB_NAME="${POSTGRES_DB:-postgres}"
USER_NAME="${POSTGRES_USER:-postgres}"

echo ">>> Dynamically adjusting configuration for database: ${DB_NAME}..."

# 2. Append the required configuration parameter dynamically
echo "cron.database_name='${DB_NAME}'" >> "$PGDATA/postgresql.conf"

# 3. Restart the engine to apply config changes (OS level, no user needed)
pg_ctl -D "$PGDATA" -m fast restart

# 4. Wait for server using the explicit user and database
until psql -U "$USER_NAME" -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1; do
  echo "Waiting for Postgres to reload with the new config..."
  sleep 1
done

echo ">>> Applying extensions to ${DB_NAME} as user ${USER_NAME}..."

# 5. Execute extension creation using explicit variables
psql -v ON_ERROR_STOP=1 --username "$USER_NAME" --dbname "$DB_NAME" <<-EOSQL
    CREATE EXTENSION IF NOT EXISTS pg_cron;
    CREATE SCHEMA IF NOT EXISTS partman;
    CREATE EXTENSION IF NOT EXISTS pg_partman SCHEMA partman;
EOSQL

echo ">>> Extensions successfully configured!"
