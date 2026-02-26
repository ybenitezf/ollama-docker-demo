## Context

The project currently has no CI/CD pipeline. The Dockerfile must be manually tested before deployment. This design addresses adding automated build verification using GitHub Actions.

## Goals / Non-Goals

**Goals:**
- Verify Dockerfile builds successfully on every push and PR
- Use official Docker GitHub Actions for reliability
- Keep workflow simple with no external dependencies or secrets

**Non-Goals:**
- Push images to registry (build test only)
- Multi-platform builds
- Add hadolint linting (can be added later)
- Cache Docker layers (can be added if build time becomes an issue)

## Decisions

1. **Use docker/build-push-action with `load: true`**
   - Alternative: `docker build` CLI command
   - Rationale: build-push-action includes Docker Buildx setup, is well-maintained, and load:true produces a real image for testing

2. **No layer caching initially**
   - Alternative: Add cache-from/cache-to for faster rebuilds
   - Rationale: Simplicity first. Cache can be added if build times become problematic

3. **Pin action versions (v6, v3)**
   - Rationale: Prevents breaking changes from automatic updates
   - Note: v6 for build-push-action, v3 for setup-buildx-action (v4 does not exist)

4. **Use setup-buildx-action**
   - Rationale: Required for build-push-action, enables advanced build features

## Risks / Trade-offs

- **Build time**: No caching means slower builds → Acceptable for single Dockerfile
- **Network dependencies**: Workflow fetches from ollama.com and github.com → Standard for GitHub Actions, unlikely to fail
- **Runner disk space**: Large base image (pytorch) → ubuntu-latest has sufficient space

## Open Questions

- Should hadolint be added as a separate step? (Deferred to future change)
- Should workflow run on other branches besides main? (Currently main + PRs only)
