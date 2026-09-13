Role: 'standard_packages'

Purpose
- Short description: Install common packages and utilities needed on developer workstations.

Variables (examples)
- packages_list: list of packages to install

Defaults & Files
- Check defaults/main.yml for default variables.
- Handlers: roles/standard_packages/handlers
- Tasks: roles/standard_packages/tasks

Usage
- Include the role in a playbook or call via: roles: - { role: standard_packages }

Notes
- Keep the package list minimal and configurable.
