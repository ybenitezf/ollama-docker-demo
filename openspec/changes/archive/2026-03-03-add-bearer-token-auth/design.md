## Context

Current deployment runs Ollama behind nginx proxy on RunPod. The nginx proxy listens on port 8080 and forwards requests to Ollama at 127.0.0.1:11434. There is no authentication - anyone who can reach the RunPod endpoint can use the Ollama API.

RunPod provides environment variables at pod creation time, which are available inside the container at runtime. We cannot mount arbitrary volumes.

## Goals / Non-Goals

**Goals:**
- Secure Ollama endpoint with bearer token authentication
- Existing clients using Bearer token format continue to work without modification
- Allow key rotation without rebuilding the Docker image
- Use nginx as the authentication layer (following Ollama's recommended approach)

**Non-Goals:**
- User management / multiple API keys (single key only)
- OAuth 2.0 or JWT - simple bearer token is sufficient
- Rate limiting or usage tracking
- Modifying Ollama itself

## Decisions

### 1. envsubst for template substitution

**Decision:** Use `envsubst` to substitute `${PRIVATE_KEY}` in nginx.conf at container startup.

**Rationale:**
- nginx does not read environment variables directly
- Official nginx Docker image has built-in support for templates in `/etc/nginx/templates/`, but we use Ubuntu-based image
- `envsubst` is available in `gettext-base` package on Ubuntu
- Alternative would be to bake secrets into image at build time, but that requires rebuilds to rotate keys

### 2. prepare.sh entrypoint script

**Decision:** Create a shell script that runs envsubst before starting supervisord.

**Rationale:**
- Separates template processing from service startup
- Allows for future extension (e.g., multiple templates, validation)
- Clear separation of concerns

### 3. Single bearer token via Authorization header

**Decision:** Validate `Authorization` header with `Bearer ${PRIVATE_KEY}` format.

**Rationale:**
- Matches existing client expectations from docker-compose setup
- Standard OAuth 2.0 bearer token format
- Simple string comparison in nginx (no cryptographic validation needed)

## Risks / Trade-offs

| Risk | Impact | Mitigation |
|------|--------|------------|
| PRIVATE_KEY not set in RunPod | Container starts but all requests return 401 | Document requirement clearly; add startup validation |
| Key visible in docker inspect | Security concern for multi-user RunPod instances | Accept - standard limitation of env vars in containers |
| envsubst fails silently | nginx starts with empty/malformed config | Add validation in prepare.sh before starting services |
| Need to restart container to rotate key | Brief downtime for key rotation | Accept - standard for most deployments |

## Migration Plan

1. Deploy new image with prepare.sh, nginx.conf.template, updated Dockerfile
2. Set `PRIVATE_KEY` environment variable in RunPod pod configuration
3. Verify authentication works with valid token
4. Verify 401 returned without token
5. Document the new `PRIVATE_KEY` requirement for future deployments

## Open Questions

- Should we add a health check endpoint that bypasses authentication for monitoring?
- Do we want to log authentication failures for security auditing?
