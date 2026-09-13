# setup_projects

## Purpose

Clone project repositories, create the target directories, and configure SSH credentials and known hosts for developer workspaces.

## Variables

- `setup_projects_project_dirs`: list of project directories to create and populate.
- `setup_projects_ssh_key_path`: path to the SSH private key used for repository access.
- `setup_projects_github_username`: GitHub username or org name used when building repository SSH URLs.

## Files

- Defaults: `roles/setup_projects/defaults/main.yml`
- Tasks: `roles/setup_projects/tasks/main.yml`
- Handlers: `roles/setup_projects/handlers/main.yml`

## Usage

```yaml
- hosts: all
  roles:
    - role: setup_projects
```

## Notes

- Keep SSH keys and host credentials outside the repository.
- Prefer a local secret store or Ansible Vault for any private material.
