Role: 'setup_database'

Purpose
- Short description: Create and configure a local development database for projects like Lingua Sytes.

Variables (examples)
- db_name: database name
- db_user: database user
- db_password: db password (use Vault)

Defaults & Files
- Check defaults/main.yml for default variables.
- Handlers: roles/setup_database/handlers
- Tasks: roles/setup_database/tasks

Usage
- Include the role in a playbook or call via: roles: - { role: setup_database }
- Set db_mode: master to create a Bitnami PostgreSQL master container and optionally restore a backup.
- Set db_mode: replica to create a Bitnami PostgreSQL replica container that connects to the primary and is intended for read-only queries.

Notes
- Use secure credentials handling practices. Provide passwords and sensitive values via group_vars or Ansible Vault.
- Ensure replication_password and primary_password are provided when creating replicas.
- For replicas, also provide postgres_password (or allow it to fall back to primary_password) because the Bitnami image requires a local superuser password before starting replication.
- Bitnami PostgreSQL replicas require the `POSTGRESQL_MASTER_*` variables to be present; the image validates `POSTGRESQL_MASTER_HOST` specifically before starting replication. Setting the `POSTGRESQL_PRIMARY_*` aliases as well keeps the role compatible with both variable naming conventions.
- If the primary is exposed on the host (for example localhost:5432), the replica must connect via the container runtime gateway (`host.docker.internal` for Docker or `host.containers.internal` for Podman) instead of 127.0.0.1, otherwise replication never starts.
- The primary container must not bind only to `127.0.0.1`; when a replica connects through `host.docker.internal`, Docker needs the host port exposed on `0.0.0.0` (for example `0.0.0.0:5432:5432`), otherwise the gateway address gets no response.
- If running multiple replicas, set unique replica_host_port and replica_name per instance.
- This role requires the Bitnami PostgreSQL image and its replication env vars. The official `docker.io/postgres` image does not use the same env names and will trigger the "Database is uninitialized and superuser password is not specified" startup error.
