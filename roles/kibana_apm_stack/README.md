Ansible role to deploy the Kibana + APM + Elasticsearch stack using the provided docker-compose.yml.

Usage:
1. Install required collection:
   ansible-galaxy collection install -r requirements.yml
2. Run the playbook locally:
   ansible-playbook playbook.yml

Defaults:
- The compose file will be copied to /opt/kibana-apm.
- On Fedora/RedHat hosts the role uses Podman by default; on Debian/Ubuntu it uses Docker and Docker Compose v2.
- A systemd unit is created at /etc/systemd/system/kibana-apm-stack.service so the stack starts automatically after boot.

Notes:
- Requires Docker and Docker Compose v2 on Debian/Ubuntu, or Podman plus podman-compose on Fedora/RedHat.
- The role installs `podman-compose` automatically on Podman hosts because `podman compose` is not available in all Podman builds.
- Each container is configured with `restart: unless-stopped`, so the runtime will restart failed services automatically.
- Adjust kibana_apm_project_path in roles/kibana_apm_stack/defaults/main.yml if needed.
