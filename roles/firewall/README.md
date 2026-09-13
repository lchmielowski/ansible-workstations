Role: 'firewall'

Purpose
- Short description: Configure host firewall rules to restrict incoming connections and allow required services.

Variables (examples)
- allowed_ports: list of ports to allow
- default_policy: 'drop' or 'accept'

Defaults & Files
- Check defaults/main.yml for default variables.
- Handlers: roles/firewall/handlers
- Tasks: roles/firewall/tasks

Usage
- Include the role in a playbook or call via: roles: - { role: firewall }

Notes
- Test firewall changes in a maintenance window; use --check to preview.
