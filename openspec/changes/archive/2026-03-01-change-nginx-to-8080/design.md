## Context

The Ollama Docker container runs nginx as a reverse proxy in front of the Ollama service. Currently, nginx is configured to listen on port 80, which is a common port that may already be in use by other services on RunPod.

Additionally, initial testing revealed that nginx was not loading the configuration from `/etc/nginx/sites-available/default`. The Ubuntu-based image does not include this path by default in its nginx.conf.

## Goals / Non-Goals

**Goals:**
- Change nginx to listen on port 8080 to avoid port collisions
- Use a standalone nginx.conf that includes all required blocks (events, http, upstream, server)

**Non-Goals:**
- Not changing the internal Ollama port (11434)
- Not adding SSL/TLS termination

## Decisions

- Use port 8080 for nginx: This is a commonly available port that avoids conflicts with system services that typically use ports 80 and 443.
- Use standalone nginx.conf: Instead of relying on Ubuntu's default nginx.conf with sites-available includes, use a complete self-contained configuration that includes all necessary blocks.

## Implementation

The nginx.conf now contains:
- `events` block for worker connections
- `http` block with basic settings (mime.types, keepalive, logging to stdout/stderr)
- `upstream` block defining the Ollama backend
- `server` block listening on port 8080

The Dockerfile copies this to `/etc/nginx/nginx.conf` (replacing the default).

## Risks / Trade-offs

- Existing users will need to update their deployment scripts to use port 8080 instead of 80.
