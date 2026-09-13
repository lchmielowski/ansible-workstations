Role: 'lingua_sytes_nginx'

Purpose
- Short description: Configure Nginx for Lingua Sytes with HTTP->HTTPS redirection and TLS settings.

Variables (examples)
- server_name: hostname
- tls_cert_path: path to cert

Defaults & Files
- Check defaults/main.yml for default variables.
- Handlers: roles/lingua_sytes_nginx/handlers
- Tasks: roles/lingua_sytes_nginx/tasks

Usage
- Include the role in a playbook or call via: roles: - { role: lingua_sytes_nginx }

Notes
- Store private keys outside repo and use Vault or secret manager for TLS automation.
