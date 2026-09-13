Role: 'upgrade'

Purpose
- Short description: Upgrade system packages to the latest recommended versions.

Variables (examples)
- upgrade_strategy: 'full' or 'security'

Defaults & Files
- Check defaults/main.yml for default variables.
- Handlers: roles/upgrade/handlers
- Tasks: roles/upgrade/tasks

Usage
- Include the role in a playbook or call via: roles: - { role: upgrade }

Notes
- Use with caution on production-critical hosts; test in staging first.
