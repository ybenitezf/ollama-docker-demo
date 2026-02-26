## Context

The GitHub Actions workflow currently builds the Docker image from scratch on every run. The base image (runpod/pytorch:1.0.2-cu1281-torch280-ubuntu2404) is several GBs and takes significant time to download. Currently the workflow only uses `docker/build-push-action` without any caching.

## Goals / Non-Goals

**Goals:**
- Add Docker layer caching to reduce build times on subsequent runs
- Cache persists across branches
- Cache invalidates when Dockerfile changes

**Non-Goals:**
- Push image to registry (out of scope for this change)
- Add image signing or security scanning
- Modify the Dockerfile itself

## Decisions

### Decision: Use local cache with actions/cache

**Alternative considered: GitHub Actions cache (`type=gha`)**

`type=gha` doesn't work reliably with `load: true` because the cache export/import goes through GitHub's cache API and has issues when loading back into the local Docker daemon.

**Decision: Use local cache with actions/cache**

The workflow will:
1. Use `actions/cache@v4` to cache `/tmp/.buildx-cache`
2. Use Dockerfile hash as the primary cache key
3. Use restore-keys for fallback cache across branches
4. Use `cache-from: type=local` and `cache-to: type=local` in build-push-action
5. Add a cache rotation step to prevent cache from growing unbounded

### Decision: Use Dockerfile hash as cache key

Using `hashFiles('Dockerfile')` ensures cache invalidation when the Dockerfile changes, while still sharing cache across branches when Dockerfile is unchanged.

## Risks / Trade-offs

- **[Risk]** First build after this change will be slower (no cache exists yet)
  - **Mitigation**: Acceptable one-time cost for long-term gains

- **[Risk]** Cache size could grow over time
  - **Mitigation**: The cache fix step (`rm -rf /tmp/.buildx-cache && mv ...`) ensures only latest cache is kept

- **[Risk]** Cache not working if runner.temp is cleared unexpectedly
  - **Mitigation**: Build will fall back to restore-keys or rebuild from scratch - no failure

## Migration Plan

1. Merge this change to main branch
2. First CI run will create initial cache
3. Subsequent runs will use cached layers
4. No rollback needed - can disable caching by reverting the workflow change

## Open Questions

None - the implementation is straightforward.
