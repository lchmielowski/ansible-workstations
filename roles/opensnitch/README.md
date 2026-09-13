Role: 'opensnitch'

Purpose
- Short description: Install and configure OpenSnitch network monitoring tool.

Variables (examples)
- enable_service: true/false

Defaults & Files
- Check defaults/main.yml for default variables.
- Handlers: roles/opensnitch/handlers
- Tasks: roles/opensnitch/tasks

Usage
- Include the role in a playbook or call via: roles: - { role: opensnitch }

Notes
- May require kernel modules or additional permissions; document in role tasks.
