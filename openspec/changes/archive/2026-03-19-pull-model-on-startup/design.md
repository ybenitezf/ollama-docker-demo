## Context

The container currently starts Ollama and nginx via supervisord, but no models are available until a request triggers a download. This causes the first inference request to be slow or timeout.

```
CONTAINER START (current)
prepare.sh → supervisord → ollama serve → nginx
                              ↑
                         no models loaded
```

## Goals / Non-Goals

**Goals:**
- Pull a configured Ollama model at container startup
- Ensure the model is available before nginx forwards traffic
- Handle the race condition where `ollama pull` must wait for `ollama serve`
- Provide clear logging for observability

**Non-Goals:**
- Model caching or persistence across container restarts
- Multi-model support (single MODEL env var only)
- Automatic model selection or discovery

## Decisions

### 1. Run pull via supervisord, not prepare.sh

**Decision:** Run `ollama pull` as a supervisord program alongside `ollama serve`.

**Rationale:** Ollama must be running for `ollama pull` to work. Starting it from `prepare.sh` would require starting a temporary Ollama instance, waiting, then handing off to supervisord — fragile and complex.

**Alternative considered:** Run pull in `prepare.sh` with a spawned Ollama process. Rejected because it requires managing a process lifecycle outside supervisord's control.

### 2. Wrapper script polls `ollama list` until ready

**Decision:** `pull-wrapper.sh` loops calling `ollama list` until it succeeds.

```bash
until ollama list &>/dev/null; do
    echo "Waiting for Ollama..."
    sleep 2
done
exec ollama pull "$MODEL"
```

**Rationale:** `ollama serve` starts at the same priority as the pull program, so supervisord doesn't guarantee ordering. Polling is the simplest reliable way to wait.

**Alternative considered:** Fixed `sleep N` delay. Rejected because N is a guess — too short risks failure, too long slows startup.

### 3. Retry pull up to 3 times on failure

**Decision:** `startretries=3` in supervisord; `exitcodes=0` so supervisord knows when pull succeeded.

**Rationale:** Transient network failures during download should retry. After 3 failures, the container continues without the model — inference will fail at request time with a clear error, which is acceptable.

### 4. prepare.sh warns but does not fail if MODEL is unset

**Decision:** `prepare.sh` logs a warning if `MODEL` is empty, then proceeds.

**Rationale:** The container may be deployed without a model (for admin/testing purposes). A warning is sufficient signal without blocking deployment.

## Risks / Trade-offs

- **[Risk]** Slow cold start: pulling a large model (e.g., 8B = ~4GB) adds minutes to startup time.
  → **Mitigation:** Acceptable for RunPod deployments where container lifetime is long. Document expected startup time.
- **[Risk]** Network failure during pull: model download interrupted.
  → **Mitigation:** `startretries=3` retries. After exhausting retries, container proceeds and inference fails at request time.
- **[Risk]** Pull succeeds but Ollama is restarted (autorestart), losing the model.
  → **Mitigation:** Out of scope for this change. Model persistence depends on RunPod volume configuration.
