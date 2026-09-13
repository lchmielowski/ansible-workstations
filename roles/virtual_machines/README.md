Role: 'virtual_machines'

Purpose
- Short description: Prepare environment for working with virtual machines (libvirt, qemu, drivers).

Variables (examples)
- vm_tool: 'libvirt' or 'virtualbox'

Defaults & Files
- Check defaults/main.yml for default variables.
- Handlers: roles/virtual_machines/handlers
- Tasks: roles/virtual_machines/tasks

Usage
- Include the role in a playbook or call via: roles: - { role: virtual_machines }

Notes
- Virtualization may require kernel modules and user group membership; document in role.
