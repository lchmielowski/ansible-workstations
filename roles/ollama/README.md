Role: 'ollama'

Purpose
- Short description: Install and configure ollama-related tools if required by the workstation.

Variables (examples)
- ollama_version: version string

Defaults & Files
- Check defaults/main.yml for default variables.
- Handlers: roles/ollama/handlers
- Tasks: roles/ollama/tasks

Usage
- Include the role in a playbook or call via: roles: - { role: ollama }

Notes
- Verify upstream licensing and installation steps.
