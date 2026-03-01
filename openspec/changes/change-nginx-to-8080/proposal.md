## Why

The current nginx configuration uses port 80, which can conflict with other services on RunPod that also use port 80. Changing to port 8080 avoids these collisions and ensures the Ollama service is accessible without port conflicts.

## What Changes

- Change nginx listening port from 80 to 8080 in nginx.conf
- Update Dockerfile EXPOSE directive from 80 to 8080
- Update AGENTS.md documentation to reflect the port change

## Capabilities

### New Capabilities
- `nginx-port-change`: Change nginx default port from 80 to 8080

### Modified Capabilities
- None

## Impact

- nginx.conf: Update `listen` directive
- Dockerfile: Update EXPOSE instruction
- AGENTS.md: Update port documentation in build/run commands
