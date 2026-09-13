# lingua_sytes_main_container Role

This Ansible role builds and deploys the Lingua Sytes Flask application in a Docker container.

## Purpose

- Builds a Docker image from the Lingua Sytes source code
- Runs the application via Gunicorn on port 8080
- Manages the Docker container lifecycle

## Requirements

- Docker and Docker Python module installed on the target host
- The `community.docker` Ansible collection

## Environment Variables Required

The following environment variables must be set before running the role:

- `GOOGLE_CLIENT_ID`: Google OAuth2 client ID
- `GOOGLE_CLIENT_SECRET`: Google OAuth2 client secret
- `APP_SECRET_KEY`: Flask session secret key
- `AUTH_SQLALCHEMY_DATABASE_URI`: PostgreSQL connection string (e.g., `postgresql://user:password@host:5432/dbname`)

## Variables

All configuration is in `vars/main.yml`:

- `docker_container_name`: Container name (default: "lingua-app-main")
- `docker_build_path`: Build directory on the host
- `docker_image_name`: Docker image name (default: "lingua-app-main")
- `docker_image_tag`: Docker image tag (default: "latest")
- `docker_ports`: Port mappings (default: ["8080:8080"])
- `docker_volumes`: Volume mappings for data and logs
- `docker_env_vars`: Environment variables passed to the container

## Usage

Add this role to your playbook:

```yaml
- hosts: lingua_sytes_server
  roles:
    - lingua_sytes_main_container
```

## Handlers

- `rebuild docker image`: Rebuilds the Docker image when the Dockerfile changes

## Notes

- The application listens on port 8080 internally
- Nginx reverse proxy (via `lingua-sytes-nginx` role) handles HTTPS on port 443 and proxies to the app on port 8080
- The role uses Gunicorn with 4 workers and a 120-second timeout
- Source code is synced from `/home/home/PycharmProjects/lingua-sytes/` excluding `.git`, `.venv`, and Python cache files
