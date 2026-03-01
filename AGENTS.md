# AGENTS.md - Development Guidelines for This Repository

## Project Overview

Docker-based project providing an Ollama + nginx setup for deployment on RunPod. Primary files: Dockerfile, nginx.conf, supervisord.conf, and shell scripts.

## Build Commands

### GitHub Actions (Primary)
```bash
git push origin main  # Triggers build workflow
```

Builds and pushes to Docker Hub:
- `ybenitezf/ollama-docker-demo:latest`
- `ybenitezf/ollama-docker-demo:<commit-sha>`

### Local Build
```bash
docker build -t ybenitezf/ollama-docker-demo:local .
docker run -d --gpus all -p 8080:8080 ybenitezf/ollama-docker-demo:local
```

### Local Validation
```bash
hadolint Dockerfile && docker build --check && nginx -t -c nginx.conf
```

## Lint Commands
```bash
shellcheck *.sh && hadolint Dockerfile && nginx -t -c nginx.conf
```

## Testing

No automated tests exist. Manual testing on RunPod after deployment.

## Code Style Guidelines

### General Principles

1. **Keep it simple** - Deployment-focused; prefer clarity over cleverness
2. **Minimal dependencies** - Avoid unnecessary tools
3. **Idempotent operations** - Scripts should be safe to run multiple times
4. **Use specific versions** - Never use `latest` tags for base images

### Shell Scripts

- Use `#!/bin/bash` or `#!/usr/bin/env bash`
- Always use `set -euo pipefail`
- Use UPPER_SNAKE_CASE for constants, `lower_snake_case` for locals
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

```dockerfile
FROM runpod/pytorch:1.0.2-cu1281-torch280-ubuntu2404
ARG S6_OVERLAY_VERSION=3.2.2.0

RUN apt-get update && apt-get install -y nginx curl xz-utils
RUN curl -fsSL https://ollama.com/install.sh | sh

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz && tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ENTRYPOINT ["/init"]
```

- Use specific version tags, not `latest`
- Order instructions least to most frequently changed
- Combine related RUN instructions to reduce layers
- Use `--no-cache-dir` for package installs

### nginx Configuration

```nginx
upstream ollama { server 127.0.0.1:11434; }

server {
    listen 8080 default_server;

    location / {
        proxy_set_header Host "localhost";
        proxy_set_header X-Real-IP "127.0.0.1";
        proxy_set_header X-Forwarded-For "127.0.0.1";
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_pass http://ollama;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_cache_bypass $http_upgrade;
    }
}
```

- Test config with `nginx -t` before deploying

### supervisord Configuration

```ini
[supervisord]
nodaemon=true
user=root
logfile=/dev/stdout
logfile_maxbytes=0

[program:ollama]
command=ollama serve
autostart=true
autorestart=true

[program:nginx]
command=nginx -g "daemon off;"
autostart=true
autorestart=true
```

- Use ini format with clear section headers
- Set `nodaemon=true` for container use
- Configure autostart and autorestart for services

### Environment Variables

- Use `.env` files for local development (add to `.gitignore`)
- Provide `.env.example` as a template
- Use UPPER_SNAKE_CASE naming
- Never commit secrets

## Git Conventions

Use conventional commits: `type(scope): description`
Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`

## Dependencies

- **Docker** - Required for building/running
- **shellcheck** - Recommended for shell script linting
- **hadolint** - Recommended for Dockerfile linting

## Troubleshooting

1. Check GitHub Actions logs for build failures
2. Validate all config files: `hadolint Dockerfile && nginx -t -c nginx.conf`
3. Ensure Docker Hub credentials are configured

## OpenSpec Workflow

- `/new-change` - Start a new feature/fix change
- `/continue-change` - Continue working on an existing change
- `/apply-change` - Implement tasks from a change
- `/verify-change` - Verify implementation matches change artifacts
- `/archive-change` - Archive a completed change
