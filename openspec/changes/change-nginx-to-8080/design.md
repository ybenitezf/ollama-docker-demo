## Context

The Ollama Docker container runs nginx as a reverse proxy in front of the Ollama service. Currently, nginx is configured to listen on port 80, which is a common port that may already be in use by other services on RunPod.

## Goals / Non-Goals

**Goals:**
- Change nginx to listen on port 8080 to avoid port collisions
- Update all references to port 80 to reflect the new port

**Non-Goals:**
- Not changing the internal Ollama port (11434)
- Not adding SSL/TLS termination

## Decisions

- Use port 8080 for nginx: This is a commonly available port that avoids conflicts with system services that typically use ports 80 and 443.

## Risks / Trade-offs

- Existing users will need to update their deployment scripts to use port 8080 instead of 80.
