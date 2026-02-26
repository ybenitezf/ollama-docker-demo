## 1. Update GitHub Actions Workflow

- [x] 1.1 Add Docker Hub login step using `docker/login-action@v3` with `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets
- [x] 1.2 Configure build-push-action with `push: true` and proper tags (`ybenitezf/ollama-docker-demo:latest`, `ybenitezf/ollama-docker-demo:${{ github.sha }}`)
- [x] 1.3 Add conditional to only push on main branch push events (not pull requests)

## 2. Verify

- [ ] 2.1 Run workflow on a test branch and verify build still works
- [ ] 2.2 Merge to main and verify image appears in Docker Hub with both tags
