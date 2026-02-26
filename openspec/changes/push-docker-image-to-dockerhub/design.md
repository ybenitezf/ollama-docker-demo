## Context

The project uses GitHub Actions to build a Docker image. The current workflow builds the image but does not publish it anywhere. The deployment target is RunPod, which needs access to a container registry. Docker Hub is the desired registry, with credentials already configured as repository secrets (`DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`).

## Goals / Non-Goals

**Goals:**
- Push Docker image to `ybenitezf/ollama-docker-demo` on Docker Hub
- Tag images with `:latest` and `:<sha>` for traceability
- Only push on main branch commits, not on pull requests

**Non-Goals:**
- Multi-platform builds (ARM64/AMD64) - stick to current architecture
- Multiple registry targets (e.g., GHCR) - only Docker Hub
- Semantic versioning tags - using SHA for now

## Decisions

### 1. Use docker/login-action for Docker Hub authentication

**Alternative considered:** Manual `docker login` command

The `docker/login-action@v3` handles secret masking, logout on failure, and is the recommended approach for GitHub Actions. It also supports other registries if needed later.

### 2. Tag strategy: `:latest` + `:{{ github.sha }}`

**Alternative considered:** Only `:latest`

Using both tags ensures:
- `:latest` always points to the newest build
- `:<sha>` provides exact traceability for debugging and rollbacks

### 3. Conditional push based on branch

**Alternative considered:** Always push

Pull request builds should only validate the image builds correctly, not pollute the registry. Push only on `push` events to `main`.

### 4. Use BuildKit cache for faster builds

The existing workflow already uses BuildKit cache. We keep this and also enable cache export to reduce build times on subsequent runs.

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Secrets not configured correctly | Workflow will fail gracefully with auth error |
| Rate limiting from Docker Hub | Use authenticated requests; cache layers to minimize pushes |
| Image push fails after successful build | Build step already uses `load: true` so image can be inspected locally |

## Migration Plan

1. Merge this change to main
2. First push will create the Docker Hub repository automatically if it doesn't exist
3. Verify image appears in Docker Hub with both tags
4. No rollback needed - previous state had no push at all
