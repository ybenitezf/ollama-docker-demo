## Why

Ollama does not have built-in authentication, which exposes the API to unauthorized access when deployed on RunPod. We need to add bearer token authentication at the nginx proxy layer to secure the Ollama endpoint.

## What Changes

- Add `nginx.conf.template` with `${PRIVATE_KEY}` environment variable placeholder for bearer token validation
- Create `prepare.sh` script to run `envsubst` on the nginx template before starting services
- Update `Dockerfile` to install `gettext-base`, copy template files, and set entrypoint to `prepare.sh`
- Configure `supervisord.conf` to start via `prepare.sh` instead of directly

## Capabilities

### New Capabilities

- `bearer-token-auth`: Validates bearer token in Authorization header via nginx proxy before forwarding requests to Ollama

### Modified Capabilities

- (none)

## Impact

- New file: `nginx.conf.template` (nginx config with env placeholder)
- New file: `prepare.sh` (entrypoint script that runs envsubst)
- Modified: `Dockerfile` (add gettext, copy templates, set entrypoint)
- Modified: `supervisord.conf` (start via prepare.sh)
- Runtime: Requires `PRIVATE_KEY` environment variable to be set in RunPod pod configuration
