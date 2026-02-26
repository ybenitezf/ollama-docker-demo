## ADDED Requirements

### Requirement: GitHub Actions workflow uses Docker layer caching
The GitHub Actions workflow SHALL use Docker layer caching to speed up subsequent builds by reusing cached layers from previous runs.

#### Scenario: Cache is available on subsequent run
- **WHEN** GitHub Actions workflow runs and cache exists from a previous build
- **THEN** Docker build reuses cached layers and completes faster than initial build

#### Scenario: Cache is not available
- **WHEN** GitHub Actions workflow runs and no cache exists (first run or cache evicted)
- **THEN** Docker builds from scratch and creates new cache for future runs

#### Scenario: Dockerfile changes invalidates cache
- **WHEN** Dockerfile is modified before a workflow run
- **THEN** Cache key changes and build starts fresh (cache miss)

#### Scenario: Cache persists across branches
- **WHEN** Workflow runs on a different branch with no branch-specific cache
- **THEN** Restore-keys fallback provides cache from other branches if available
