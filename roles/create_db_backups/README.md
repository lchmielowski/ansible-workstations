Role: 'create_db_backups'

Purpose
- Short description: Create scheduled encrypted database backups and manage rotation.

Variables (examples)
- backup_dest: destination path or remote storage
- backup_schedule: cron expression

Defaults & Files
- Check defaults/main.yml for default variables.
- Handlers: roles/create_db_backups/handlers
- Tasks: roles/create_db_backups/tasks

Usage
- Include the role in a playbook or call via: roles: - { role: create_db_backups }

Notes
- Do not store unencrypted backups in the repo; configure destination and credentials in group/host vars or a vault.
