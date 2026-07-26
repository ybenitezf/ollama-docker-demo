## Why

The Ollama container starts without any models pre-loaded. The first inference request must first download the model, adding significant latency. By pulling the model at container startup, it is immediately available for requests.

## What Changes

- Add `pull-wrapper.sh` script that waits for Ollama to be ready, then runs `ollama pull`
- Add `[program:pull]` to `supervisord.conf` that runs the wrapper script
- Add `MODEL` environment variable warning to `prepare.sh` (warning only, not a failure)
- Update `Dockerfile` to copy `pull-wrapper.sh` into the container

## Capabilities

### New Capabilities

- `model-pull-on-startup`: Pulls a configured Ollama model when the container starts, ensuring the model is available immediately without waiting for the first request to trigger a download.

### Modified Capabilities

- None

## Impact

- **prepare.sh**: Added `MODEL` env var warning
- **supervisord.conf**: New `[program:pull]` section
- **Dockerfile**: New `COPY pull-wrapper.sh` instruction
- **New file**: `pull-wrapper.sh` - wrapper script that waits for Ollama and pulls the model
