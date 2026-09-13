Role: 'snort'

Purpose
- Short description: Install and configure Snort intrusion detection system.

Variables (examples)
- snort_ruleset: ruleset repository or path

Defaults & Files
- Check defaults/main.yml for default variables.
- Handlers: roles/snort/handlers
- Tasks: roles/snort/tasks

Usage
- Include the role in a playbook or call via: roles: - { role: snort }

Notes
- Keep performance and resource usage in mind for production deployments.
