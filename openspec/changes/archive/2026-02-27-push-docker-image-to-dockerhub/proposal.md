## Why

The current GitHub Actions workflow builds the Docker image but does not push it to a container registry. To make the image available for deployment (e.g., to RunPod), it needs to be pushed to Docker Hub after each successful build on the main branch.

## What Changes

- Add Docker Hub authentication step to the GitHub Actions workflow using existing secrets
- Configure image tagging with `:latest` and `:<sha>` for traceability
- Enable image push to `ybenitezf/ollama-docker-demo` on main branch pushes
- Skip push on pull request builds (only build for testing)

## Capabilities

### New Capabilities

- `dockerhub-push`: Push built Docker image to Docker Hub on main branch commits

### Modified Capabilities

- (none)

## Impact

- `.github/workflows/build.yml` - Added login and push steps
- No changes to Dockerfile or application code
