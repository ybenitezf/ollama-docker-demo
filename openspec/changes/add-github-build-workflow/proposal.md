## Why

Currently there is no automated verification that the Dockerfile builds successfully. Manual testing is required before each deployment, which is error-prone and time-consuming. A GitHub Actions workflow will provide automated build verification on every push and pull request.

## What Changes

- Add `.github/workflows/build.yml` with Docker build test workflow
- Workflow triggers on push to main and pull requests
- Uses docker/build-push-action with `load: true` to build without pushing
- Runs on ubuntu-latest with Docker Buildx

## Capabilities

### New Capabilities
- `github-build-workflow`: GitHub Actions workflow that builds the Docker image without pushing to verify the Dockerfile is valid

### Modified Capabilities
- (none)

## Impact

- New file: `.github/workflows/build.yml`
- No changes to existing code or configuration
