Role: 'ping'

Purpose
- Short description: Simple connectivity test role using ping or similar checks.

Variables (examples)
- target_host: host to test

Defaults & Files
- Check defaults/main.yml for default variables.
- Handlers: roles/ping/handlers
- Tasks: roles/ping/tasks

Usage
- Include the role in a playbook or call via: roles: - { role: ping }

Notes
- Intended for basic validation only.
