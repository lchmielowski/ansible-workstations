Role: 'ssh_tunnel_service'

Purpose
- Short description: Create and manage systemd service for persistent SSH tunnels.

Variables (examples)
- tunnel_target: remote target
- tunnel_user: SSH user

Defaults & Files
- Check defaults/main.yml for default variables.
- Handlers: roles/ssh_tunnel_service/handlers
- Tasks: roles/ssh_tunnel_service/tasks

Usage
- Include the role in a playbook or call via: roles: - { role: ssh_tunnel_service }

## Obtaining known_hosts entries for SSH tunnels

The `ssh_tunnel_service` role intentionally requires a trusted host key in configuration and does not accept arbitrary hosts. Use the remote server's SSH public key and place it in `ssh_known_hosts_entry` or in each tunnel's `ssh_known_hosts_entry` entry.

To retrieve the host key from the target server:

```bash
ssh-keyscan -t ed25519,rsa,ecdsa example-host
```

This prints lines like:

```text
example-host ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI...
example-host ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC...
example-host ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBB...
```

Copy the exact host line(s) into the Ansible variable:

```yaml
ssh_known_hosts_entry: |
  example-host ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI...
  example-host ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC...
```

If you want a per-tunnel key, set the same value on the specific tunnel item instead of the shared default:

```yaml
ssh_tunnels:
  - name: example-apm
    remote_host: user@example-host
    forward_option: "-R 8200:127.0.0.1:8200"
    ssh_known_hosts_entry: |
      example-host ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI...
```

For internal/private hosts, you can also log in once and fetch the public key from the remote host directly:

```bash
ssh-keygen -R example-host
ssh example-host
cat ~/.ssh/known_hosts
```

Use the value from `known_hosts` exactly as recorded by the remote server; do not use `StrictHostKeyChecking=no` or a blank entry.

Notes
- Ensure correct SSH keys and permissions are configured.
