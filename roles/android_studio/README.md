Role: 'android_studio'

Purpose
- Short description: Install and configure Android Studio IDE on workstations.

Variables (examples)
- android_studio_version: version string (default: see role defaults/main.yml)
- install_dir: path to install

Defaults & Files
- Check defaults/main.yml for default variables.
- Handlers: roles/android_studio/handlers
- Tasks: roles/android_studio/tasks

Usage
- Include the role in a playbook or call via: roles: - { role: android_studio }

Notes
- Keep secrets out of defaults; use host/group vars or Ansible Vault.
