## Context

The Ollama + nginx deployment on RunPod uses the default nginx `client_max_body_size` of 1MB. This limits request bodies to ~750KB of raw data due to base64 encoding overhead. Vision model requests with base64-encoded images regularly exceed this limit.

## Goals / Non-Goals

**Goals:**
- Allow request bodies up to 100MB to support vision model requests

**Non-Goals:**
- No changes to upstream Ollama configuration
- No changes to authentication flow
- No performance optimization (this is a limit increase, not a tuning)

## Decisions

| Option | Value | Rationale |
|--------|-------|-----------|
| `client_max_body_size` | `100M` | Handles extreme cases with multiple high-resolution images. Round number for clarity. |

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Large uploads could exhaust disk space from temp files | nginx uses `/var/tmp` for large buffers; container has sufficient storage on RunPod |
| Increased memory pressure from large requests | nginx streams to disk; memory usage bounded by `proxy_buffer_size` |
