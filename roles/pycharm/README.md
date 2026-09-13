Role: 'pycharm'

Purpose
- Short description: Install and configure PyCharm IDE for developers.

Variables (examples)
- pycharm_edition: 'community' or 'professional'
- install_path: where to install

Defaults & Files
- Check defaults/main.yml for default variables.
- Handlers: roles/pycharm/handlers
- Tasks: roles/pycharm/tasks

Usage
- Include the role in a playbook or call via: roles: - { role: pycharm }

Notes
- Consider licensing for Professional edition outside the repo.
