# AGENTS.md - Development Guidelines for This Repository

## Project Overview

This is a Docker-based project providing an Ollama + nginx setup for deployment on RunPod. The project consists primarily of Docker configuration files and shell scripts for deployment and management.

## Build Commands

This project uses GitHub Actions workflows for building and testing. Images are tested remotely on RunPod.

### GitHub Actions
```bash
# Trigger workflow via git push or manually via GitHub UI
git push origin main  # Triggers build workflow
```

### Local Validation (Optional)
```bash
# Validate Dockerfile syntax (no Docker required)
hadolint Dockerfile

# Validate docker-compose.yml
docker-compose config

# Validate nginx config
nginx -t -c nginx.conf
```

## Lint and Code Quality

- **Shell scripts**: Use shellcheck
  ```bash
  shellcheck your-script.sh
  ```

- **Dockerfiles**: Use hadolint
  ```bash
  hadolint Dockerfile
  ```

- **docker-compose**: Validate syntax
  ```bash
  docker-compose config
  ```

- **nginx configs**: Test with `nginx -t -c nginx.conf`

## Testing

There are currently no automated tests in this project. If tests are added, they would run in GitHub Actions. Remote testing on RunPod is performed manually after deployment.

## Code Style Guidelines

### General Principles

1. **Keep it simple** - Deployment-focused; prefer clarity over cleverness
2. **Minimal dependencies** - Avoid unnecessary tools
3. **Idempotent operations** - Scripts should be safe to run multiple times

### Shell Scripts

- Use `#!/bin/bash` with bash version 4+
- Always use `set -euo pipefail` for error handling
- Use UPPER_SNAKE_CASE for constants, lower_snake_case for locals
- Quote all variable expansions: `"$VAR"` not `$VAR`
- Use `[[ ]]` for conditionals, not `[ ]`

```bash
#!/bin/bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

main() {
    local service_name="${1:-default}"
    echo "Starting $service_name"
}

main "$@"
```

### Dockerfiles

- Use specific version tags, not `latest`
- Order instructions from least to most frequently changed
- Combine related RUN instructions to reduce layers
- Always include HEALTHCHECK for main services
- Use multi-stage builds when appropriate

```dockerfile
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY . .
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1
CMD ["python", "main.py"]
```

### nginx Configuration

- Use tabs for indentation (nginx default)
- Group related directives into logical blocks
- Include comments for non-obvious configurations
- Always test config with `nginx -t` before deploying

### Environment Variables

- Use `.env` files for local development (add to `.gitignore`)
- Provide `.env.example` as a template
- Use UPPER_SNAKE_CASE naming
- Document all required variables

### File Naming

- Shell scripts: `kebab-case.sh` or `snake_case.sh`
- Dockerfiles: `Dockerfile` (or `Dockerfile.<target>` for multi-stage)
- Config files: `<service>.<ext>` (e.g., `nginx.conf`)

### Error Handling

- Exit codes: 0 (success), 1 (general error), 126 (not executable), 127 (command not found)
- Log errors to stderr: `echo "Error: message" >&2`
- Provide helpful error messages that explain what went wrong

### Git Conventions

**Always use conventional commits when creating commits.** Format: `type(scope): description`

- Keep commits atomic and focused
- Use conventional commits: `type(scope): description`
- Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`

## Dependencies

- **Docker** - Required for building/running
- **docker-compose** - Optional, for local development
- **shellcheck** - Recommended for shell script linting
- **hadolint** - Recommended for Dockerfile linting

## Common Tasks

### Adding a New Service

1. Create service Dockerfile in `services/<service-name>/`
2. Update docker-compose.yml if using
3. Add environment variables to `.env.example`
4. Document configuration in README.md

### Debugging

Debugging is performed remotely on RunPod after deployment. Check GitHub Actions logs for build issues.
