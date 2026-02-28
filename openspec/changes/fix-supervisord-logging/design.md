## Context

This project runs Ollama and nginx under supervisord inside a Docker container deployed on RunPod. The current supervisord configuration captures child process output to separate log files, which are not visible through Docker's logging mechanism. This prevents operators from troubleshooting issues via `docker logs` or RunPod's log interface.

## Goals / Non-Goals

**Goals:**
- Make ollama stdout/stderr visible in container logs
- Make nginx stdout/stderr visible in container logs
- Maintain supervisord as the process manager

**Non-Goals:**
- Change logging levels or add structured logging
- Modify nginx or ollama configurations
- Add new monitoring or alerting

## Decisions

### Decision: Redirect stdout to /dev/stdout

Using `stdout_logfile=/dev/stdout` directs each program's output to the container's stdout file descriptor, which Docker captures.

**Alternative considered: syslog**
- Could configure supervisord to use `stdout_syslog=true`
- Rejected because it adds complexity and requires syslog daemon

### Decision: Disable log rotation

Using `stdout_logfile_maxbytes=0` prevents rotation since stdout is a stream, not a file.

**Alternative: Let rotation happen**
- Would require additional volume for log files
- Unnecessary for streaming stdout

### Decision: Redirect stderr separately

Using `redirect_stderr=true` merges stderr into stdout, ensuring all log output goes to the container's stdout stream.

**Alternative: Separate stderr redirect**
- Could use `stderr_logfile=/dev/stderr` 
- Merging is simpler and ensures all output is captured together

## Risks / Trade-offs

- **Risk:** High volume of logs could impact Docker log driver performance  
  **Mitigation:** RunPod and Docker handle this; can add logging limits at the Docker daemon level if needed

- **Trade-off:** No file-based logs for later analysis  
  **Mitigation:** Docker log driver already persists logs; can configure Docker to ship to external logging service if needed

## Migration Plan

1. Deploy updated `supervisord.conf` with new program options
2. Container restart triggers supervisord reload
3. Verify logs appear in `docker logs <container>` or RunPod interface
4. Rollback: Revert to previous `supervisord.conf` if logs not appearing

No data migration or multi-step deployment required.
