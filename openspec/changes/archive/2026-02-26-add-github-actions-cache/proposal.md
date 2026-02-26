## Why

Every GitHub Actions build currently starts from scratch, rebuilding all Docker layers including downloading the large base image (runpod/pytorch:1.0.2-cu1281-torch280-ubuntu2404). This wastes CI time and compute resources on redundant operations.

## What Changes

- Add Docker layer caching to the GitHub Actions workflow using local cache with actions/cache
- Use Dockerfile hash as cache key for proper invalidation
- Configure cache restore-keys for fallback to any previous cache
- Cache persists across branches via shared restore-keys

## Capabilities

### New Capabilities
- `github-actions-cache`: Add persistent Docker layer caching to GitHub Actions workflow for faster builds

### Modified Capabilities
- `github-build-workflow`: Add caching capability to existing build workflow (no requirement changes, just implementation enhancement)

## Impact

- `.github/workflows/build.yml` - Modified to add caching steps
- No new dependencies required
- No breaking changes
