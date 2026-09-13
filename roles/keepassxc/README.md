Role: 'keepassxc'

Purpose
- Short description: Install and configure KeePassXC and browser integration where applicable.

Variables (examples)
- keepassxc_version: version string
- enable_browser_integration: true/false

Defaults & Files
- Check defaults/main.yml for default variables.
- Handlers: roles/keepassxc/handlers
- Tasks: roles/keepassxc/tasks

Usage
- Include the role in a playbook or call via: roles: - { role: keepassxc }

Notes
- Store database paths and passwords outside repo; use Vault.
