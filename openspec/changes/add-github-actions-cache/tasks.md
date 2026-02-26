## 1. Update GitHub Actions Workflow

- [x] 1.1 Add Cache Docker layers step using actions/cache@v4
- [x] 1.2 Configure cache key using Dockerfile hash
- [x] 1.3 Add restore-keys for cross-branch fallback
- [x] 1.4 Update build-push-action with cache-from and cache-to
- [x] 1.5 Add cache rotation step to prevent unbounded growth

## 2. Verify (Manual - after push to GitHub)

- [x] 2.1 Run workflow on main branch and verify cache is created
- [x] 2.2 Run workflow again and verify cache is used (faster build)
- [x] 2.3 Modify Dockerfile and verify cache is invalidated
