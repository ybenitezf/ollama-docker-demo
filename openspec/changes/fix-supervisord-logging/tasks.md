## 1. Update supervisord.conf

- [x] 1.1 Add `stdout_logfile=/dev/stdout` to `[program:ollama]` section
- [x] 1.2 Add `stdout_logfile_maxbytes=0` to `[program:ollama]` section
- [x] 1.3 Add `redirect_stderr=true` to `[program:ollama]` section
- [x] 1.4 Add `stdout_logfile=/dev/stdout` to `[program:nginx]` section
- [x] 1.5 Add `stdout_logfile_maxbytes=0` to `[program:nginx]` section
- [x] 1.6 Add `redirect_stderr=true` to `[program:nginx]` section

## 2. Validate

- [x] 2.1 Run lint check: `hadolint Dockerfile && nginx -t -c nginx.conf`
- [ ] 2.2 Build Docker image locally (N/A - tested on RunPod)
- [ ] 2.3 Deploy to RunPod and verify logs appear in pod interface
