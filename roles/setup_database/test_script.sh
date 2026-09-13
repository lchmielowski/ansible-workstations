#!/usr/bin/env bash
set -euo pipefail

# ---- Configuration ----
# Set the database passwords here so the script never prompts interactively.
PRIMARY_HOST="${PRIMARY_HOST-primary-db.example.com}"
REPLICA_HOST="${REPLICA_HOST-replica-db.example.com}"
PRIMARY_PORT="${PRIMARY_PORT-5432}"
REPLICA_PORT="${REPLICA_PORT-5432}"
PRIMARY_USER="${PRIMARY_USER-postgres}"
REPLICA_USER="${REPLICA_USER-postgres}"
PRIMARY_DB="${PRIMARY_DB-postgres}"
REPLICA_DB="${REPLICA_DB-postgres}"
PRIMARY_PASSWORD="${PRIMARY_PASSWORD-}"
REPLICA_PASSWORD="${REPLICA_PASSWORD-}"

TABLE_NAME="public.replication_probe"

# ---- Install psql depending on OS ----
install_psql() {
  if command -v psql >/dev/null 2>&1; then
    echo "psql already installed"
    return 0
  fi

  if [ -f /etc/os-release ]; then
    . /etc/os-release
  else
    echo "Cannot detect OS"
    exit 1
  fi

  echo "Installing psql for OS: ${ID}"

  if [ "$ID" = "fedora" ] || [ "$ID_LIKE" = "fedora" ] || [ "$ID" = "rhel" ] || [ "$ID" = "centos" ] || [ "$ID" = "rocky" ]; then
    if command -v dnf >/dev/null 2>&1; then
      sudo dnf install -y postgresql
    elif command -v yum >/dev/null 2>&1; then
      sudo yum install -y postgresql
    else
      echo "Neither dnf nor yum found on Fedora/RHEL system"
      exit 1
    fi
  elif [ "$ID" = "ubuntu" ] || [ "$ID" = "debian" ] || [ "$ID_LIKE" = "ubuntu debian" ]; then
    sudo apt-get update
    sudo apt-get install -y postgresql-client
  else
    echo "Unsupported OS: ${ID}"
    exit 1
  fi

  command -v psql >/dev/null 2>&1 || { echo "psql still not available"; exit 1; }
}

# ---- Helpers ----
PRIMARY_DSN="host=${PRIMARY_HOST} port=${PRIMARY_PORT} user=${PRIMARY_USER} dbname=${PRIMARY_DB}"
REPLICA_DSN="host=${REPLICA_HOST} port=${REPLICA_PORT} user=${REPLICA_USER} dbname=${REPLICA_DB}"

validate_passwords() {
  if [ -z "${PRIMARY_PASSWORD:-}" ]; then
    echo "PRIMARY_PASSWORD is not set. Set it in the Configuration section before running the script." >&2
    exit 1
  fi

  if [ -z "${REPLICA_PASSWORD:-}" ]; then
    echo "REPLICA_PASSWORD is not set. Set it in the Configuration section before running the script." >&2
    exit 1
  fi
}

psql_primary() {
  PGPASSWORD="${PRIMARY_PASSWORD}" psql "$PRIMARY_DSN" "$@"
}

psql_replica() {
  PGPASSWORD="${REPLICA_PASSWORD}" psql "$REPLICA_DSN" "$@"
}

wait_for_replica_table() {
  local expected="$1"
  for i in $(seq 1 60); do
    local exists
    exists=$(PGPASSWORD="${REPLICA_PASSWORD}" psql "$REPLICA_DSN" -Atqc \
      "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='replication_probe');")
    if [ "$exists" = "$expected" ]; then
      return 0
    fi
    sleep 2
  done
  return 1
}

wait_for_row_count() {
  local expected="$1"
  for i in $(seq 1 60); do
    local count
    count=$(PGPASSWORD="${REPLICA_PASSWORD}" psql "$REPLICA_DSN" -Atqc "SELECT COUNT(*) FROM ${TABLE_NAME};")
    if [ "$count" = "$expected" ]; then
      return 0
    fi
    sleep 2
  done
  return 1
}

# ---- Main ----
install_psql
validate_passwords

echo "=== 1) Check replica is in recovery mode ==="
psql_replica -c "SELECT pg_is_in_recovery(), pg_last_wal_receive_lsn(), pg_last_xact_replay_timestamp();"
echo

echo "=== 2) Check replication status on primary ==="
psql_primary -c "
SELECT pid, usename, application_name, state, sync_state, write_lag, flush_lag, replay_lag
FROM pg_stat_replication;
"
# ---- Additional debugging info to help diagnose replication issues ----
echo
echo "=== 2.5) Debugging information from primary and replica ==="
# Connectivity tests
echo "-- pg_isready (primary) --"
PGPASSWORD="${PRIMARY_PASSWORD}" pg_isready -h "${PRIMARY_HOST}" -p "${PRIMARY_PORT}" -U "${PRIMARY_USER}" || true
echo "-- pg_isready (replica) --"
PGPASSWORD="${REPLICA_PASSWORD}" pg_isready -h "${REPLICA_HOST}" -p "${REPLICA_PORT}" -U "${REPLICA_USER}" || true

# Primary configuration and replication-related settings
echo "-- Primary: important settings --"
psql_primary -Atc "SELECT name, setting FROM pg_settings WHERE name IN ('wal_level','max_wal_senders','listen_addresses','port','hba_file','config_file','data_directory','logging_collector','log_directory','log_filename');" || true

echo "-- Primary: pg_stat_replication (full) --"
psql_primary -c "SELECT * FROM pg_stat_replication;" || true

echo "-- Primary: replication slots --"
psql_primary -c "SELECT * FROM pg_replication_slots;" || true

echo "-- Primary: pg_hba location and preview (requires superuser) --"
psql_primary -Atc "SELECT setting FROM pg_settings WHERE name='hba_file';" | while read -r hba; do
  echo "hba_file: $hba"
  psql_primary -c "SELECT pg_read_file('$hba', 0, 20000);" || echo "Could not read pg_hba.conf via pg_read_file (insufficient permissions)"
done || true

# Replica-side diagnostic info
echo "-- Replica: recovery status, wal receiver, and settings --"
psql_replica -c "SELECT pg_is_in_recovery(), pg_last_wal_receive_lsn(), pg_last_xact_replay_timestamp();" || true
psql_replica -c "SELECT * FROM pg_stat_wal_receiver;" || true
psql_replica -c "SELECT * FROM pg_replication_slots;" || true
psql_replica -Atc "SELECT name, setting FROM pg_settings WHERE name IN ('primary_conninfo','port','hba_file','config_file','data_directory','log_directory','log_filename');" || true

echo "-- Replica: attempt to read replica config files (requires superuser) --"
psql_replica -Atc "SELECT setting FROM pg_settings WHERE name='config_file';" | while read -r cfg; do
  echo "config_file: $cfg"
  psql_replica -c "SELECT pg_read_file('$cfg', 0, 20000);" || echo "Could not read config file via pg_read_file (insufficient permissions)"
done || true

echo "-- Replica: pg_stat_activity (to see connections/attempts) --"
psql_primary -c "SELECT pid, usename, client_addr, application_name, state, backend_start FROM pg_stat_activity WHERE usename = current_user OR application_name IS NOT NULL ORDER BY backend_start DESC LIMIT 20;" || true

echo "-- General: DNS resolution and host reachability --"
getent hosts "${PRIMARY_HOST}" || true
getent hosts "${REPLICA_HOST}" || true
# Try a TCP connect using /dev/tcp if available
if bash -c 'cat < /dev/null > /dev/tcp/${PRIMARY_HOST}/${PRIMARY_PORT}' >/dev/null 2>&1; then
  echo "TCP to ${PRIMARY_HOST}:${PRIMARY_PORT} seems open from this host"
else
  echo "TCP to ${PRIMARY_HOST}:${PRIMARY_PORT} failed from this host"
fi
if bash -c 'cat < /dev/null > /dev/tcp/${REPLICA_HOST}/${REPLICA_PORT}' >/dev/null 2>&1; then
  echo "TCP to ${REPLICA_HOST}:${REPLICA_PORT} seems open from this host"
else
  echo "TCP to ${REPLICA_HOST}:${REPLICA_PORT} failed from this host"
fi

echo "=== End debug info ==="

echo

# Create table on primary
echo "=== 3) Create table on primary ==="
psql_primary -v table_name="$TABLE_NAME" <<SQL
DROP TABLE IF EXISTS public.replication_probe;
CREATE TABLE public.replication_probe (
    id SERIAL PRIMARY KEY,
    payload TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);
INSERT INTO public.replication_probe (payload) VALUES ('initial-row');
SQL

echo "Waiting for table to appear on replica..."
wait_for_replica_table "t" || { echo "ERROR: Replica did not receive the table"; exit 1; }

echo "=== 4) Verify table and data on replica ==="
psql_replica -c "SELECT * FROM ${TABLE_NAME} ORDER BY id;"
echo

echo "=== 5) Insert row on primary ==="
psql_primary -c "INSERT INTO ${TABLE_NAME}(payload) VALUES ('second-row');"
wait_for_row_count 2 || { echo "ERROR: Replica did not receive new row"; exit 1; }

echo "Replica data after insert:"
psql_replica -c "SELECT * FROM ${TABLE_NAME} ORDER BY id;"
echo

echo "=== 6) Update row on primary ==="
psql_primary -c "UPDATE ${TABLE_NAME} SET payload = 'updated-row' WHERE payload = 'second-row';"
for i in $(seq 1 60); do
  if [ "$(PGPASSWORD="${REPLICA_PASSWORD}" psql "$REPLICA_DSN" -Atqc "SELECT COUNT(*) FROM ${TABLE_NAME} WHERE payload = 'updated-row';")" = "1" ]; then
    break
  fi
  sleep 2
done

echo "Replica data after update:"
psql_replica -c "SELECT * FROM ${TABLE_NAME} ORDER BY id;"
echo

echo "=== 7) Delete row on primary ==="
psql_primary -c "DELETE FROM ${TABLE_NAME} WHERE payload = 'initial-row';"
wait_for_row_count 1 || { echo "ERROR: Replica did not apply delete"; exit 1; }

echo "Replica data after delete:"
psql_replica -c "SELECT * FROM ${TABLE_NAME} ORDER BY id;"
echo

echo "=== 8) Drop table on primary ==="
psql_primary -c "DROP TABLE IF EXISTS ${TABLE_NAME};"

for i in $(seq 1 60); do
  exists=$(PGPASSWORD="${REPLICA_PASSWORD}" psql "$REPLICA_DSN" -Atqc "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='replication_probe');")
  if [ "$exists" = "f" ]; then
    break
  fi
  sleep 2
done

echo "Replica check after drop:"
psql_replica -Atqc "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='replication_probe');"
echo

echo "Replication check completed successfully."
