## 1. Update supervisord.conf

- [x] 1.1 Add `stdout_logfile=/dev/stdout` to `[program:ollama]` section
- [x] 1.2 Add `stdout_logfile_maxbytes=0` to `[program:ollama]` section
- [x] 1.3 Add `redirect_stderr=true` to `[program:ollama]` section
- [x] 1.4 Add `stdout_logfile=/dev/stdout` to `[program:nginx]` section
- [x] 1.5 Add `stdout_logfile_maxbytes=0` to `[program:nginx]` section
- [x] 1.6 Add `redirect_stderr=true` to `[program:nginx]` section

## 2. Update nginx.conf

- [x] 2.1 Add `access_log /dev/stdout` to server block
- [x] 2.2 Add `error_log /dev/stderr` to server block

## 3. Validate

- [x] 3.1 Run lint check: `hadolint Dockerfile && nginx -t -c nginx.conf`
- [x] 3.2 Build Docker image locally (verified on RunPod instead)
- [x] 3.3 Deploy to RunPod and verify logs appear in pod interface (verified on RunPod)
