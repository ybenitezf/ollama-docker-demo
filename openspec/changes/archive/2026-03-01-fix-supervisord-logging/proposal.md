## Why

When running Ollama and nginx under supervisord in a Docker container on RunPod, the logs from both services are not visible in container stdout. This makes debugging difficult since `docker logs` and RunPod's log interface show no output from ollama or nginx. The root cause is that supervisord captures child process stdout to separate log files instead of forwarding them to the container's stdout stream.

## What Changes

- Add `stdout_logfile=/dev/stdout` to `[program:ollama]` section
- Add `stdout_logfile_maxbytes=0` to `[program:ollama]` section  
- Add `redirect_stderr=true` to `[program:ollama]` section
- Add `stdout_logfile=/dev/stdout` to `[program:nginx]` section
- Add `stdout_logfile_maxbytes=0` to `[program:nginx]` section
- Add `redirect_stderr=true` to `[program:nginx]` section

## Capabilities

### New Capabilities
None - this is a configuration fix for existing behavior.

### Modified Capabilities
None.

## Impact

- **Affected files**: `supervisord.conf`
- **Behavior change**: Ollama and nginx logs will now appear in container stdout (visible via `docker logs` and RunPod logs)
- **No breaking changes**: This is purely additive - improves observability without changing functionality
