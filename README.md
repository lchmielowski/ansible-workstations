# ansible-workstations

Reusable Ansible playbooks and roles for provisioning developer workstations and related services.

## Overview

- Purpose: idempotent workstation provisioning for developer machines, supporting services, and internal tooling.
- Audience: platform engineers, system administrators, and teams that want reproducible dev environment automation.
- Contents: example playbooks including `main_workstation.yml`, `test_workstation.yml`, and `lingua_sytes_logging.yml`, plus reusable roles under `roles/*` and host-specific configuration in `group_vars/`.

## Quickstart

1. Install the required Ansible content:
   ```bash
   ansible-galaxy install -r requirements.yml
   ```
   `requirements.yml` declares the external collections used by the playbooks, such as `community.docker`.
2. Copy the example inventory and adjust it for your environment:
   ```bash
   cp inventory.ini.example inventory.ini
   ```
3. Copy and customize the example variables for the host you plan to provision:
   ```bash
   cp group_vars/main_workstation.example.yml group_vars/main_workstation.yml
   ```
   or copy the matching `test_workstation.example.yml` / `lingua_sytes_logging.example.yml` files for other hosts.
4. Preview changes with a dry run:
   ```bash
   ansible-playbook -i inventory.ini main_workstation.yml --check --diff
   ```
5. Apply the playbook when ready:
   ```bash
   ansible-playbook -i inventory.ini main_workstation.yml
   ```

The repository includes sanitized templates in `inventory.ini.example` and `group_vars/*.example.yml`. Do not commit real credentials, tokens, or private keys.

## Usage notes

- Prefer `--check` and `--diff` before making changes on a live system.
- Keep secrets out of defaults and role variables; use Ansible Vault, environment variables, or a dedicated secret manager.
- Keep `inventory.ini` local to each environment; it is ignored by the repository.

## Role documentation

See the role-level README files under `roles/*/README.md` for setup details and variables for individual components.

## Contributing and support

- Open an issue with the reproduction steps and playbook output if something breaks.
- Submit pull requests with small, focused changes and clear documentation updates.

