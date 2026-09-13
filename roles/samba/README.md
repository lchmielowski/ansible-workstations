Role: 'samba'

Purpose
- Short description: Configure Samba mounts and credentials to access SMB shares.

Variables (examples)
- smb_username: SMB account username
- smb_password: SMB account password (use Vault)
- smb_domain: optional Active Directory/domain name
- smb_address: SMB server address
- smb_share: share name
- mount_point: local mount point

Defaults & Files
- Check defaults/main.yml for default variables.
- Handlers: roles/samba/handlers
- Tasks: roles/samba/tasks

Usage
- Include the role in a playbook or call via: roles: - { role: samba }

Notes
- Avoid storing credentials in plaintext in the repo.
