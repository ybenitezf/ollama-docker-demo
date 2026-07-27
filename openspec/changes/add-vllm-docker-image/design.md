## Context

The project currently builds a single Docker image (`ybenitezf/ollama-docker-demo`) that runs Ollama on RunPod. It uses supervisord to orchestrate three processes: an Ollama server, an nginx reverse proxy (for bearer token auth), and a model pull/warmup script. The entrypoint (`prepare.sh`) validates `PRIVATE_KEY` and `MODEL` environment variables, renders the nginx config with envsubst, and starts supervisord.

We are adding a second Docker image for vLLM — a different inference engine that serves models via an OpenAI-compatible API. vLLM has native `--api-key` support, eliminating the need for nginx. It runs as a single process, eliminating the need for supervisord.

The overall project structure needs to house both Docker images cleanly.

## Goals / Non-Goals

**Goals:**
- A new Docker image (`ybenitezf/ollama-docker-demo:vllm-latest`) that runs vLLM with a configurable model and API key
- Same base image (`runpod/pytorch`) and same env var conventions (`PRIVATE_KEY`, `MODEL`) as the existing Ollama image
- AWQ quantization support via `--quantization awq`
- Clean project structure with subdirectories for each image
- Updated GitHub Actions workflow that builds and pushes both images on push to main

**Non-Goals:**
- Replacing or modifying the existing Ollama image
- Adding nginx or supervisord to the vLLM image
- Adding automated tests
- Supporting multiple quantization types in the same image
- Changing RunPod deployment procedures

## Decisions

### Base Image: Keep runpod/pytorch

Use the same `runpod/pytorch:1.0.2-cu1281-torch280-ubuntu2404` base as the Ollama image for consistency across the project. vLLM will be installed via `pip` (the base image has PyTorch 2.8 and CUDA 12.8, which vLLM supports). Let `pip install vllm` resolve the correct version.

*Alternatives considered:* `vllm/vllm-openai:latest` — purpose-built but different base than the Ollama image, and harder to customize (e.g., adding our own prepare.sh, file copying).

### Architecture: Single Process, No nginx, No supervisord

The vLLM image runs exactly one process: `vllm serve`. The `--api-key` flag provides bearer token authentication natively. RunPod's proxy provides SSL termination.

*Alternatives considered:* nginx in front of vLLM (like the Ollama setup) — adds complexity without benefit since vLLM's native auth covers the primary use case.

### Quantization: AWQ

The image passes `--quantization awq` to `vllm serve`. The user provides the exact AWQ-quantized Hugging Face model name via the `MODEL` env var at pod start.

*Alternatives considered:* FP8 (simpler, no quantized model needed but higher VRAM), FP16 (largest VRAM requirement). AWQ offers the best VRAM/quality tradeoff for the user's target GPU class.

### Project Structure: Subdirectories

Existing Ollama files move to `ollama/`. New vLLM files live in `vllm/`. This keeps the root clean and makes it obvious which files belong to which image.

```
├── ollama/
│   ├── Dockerfile
│   ├── prepare.sh
│   ├── pull-wrapper.sh
│   ├── nginx.conf.template
│   └── supervisord.conf
├── vllm/
│   ├── Dockerfile
│   └── prepare.sh
├── .github/workflows/build.yml
└── ... (AGENTS.md, README.md, openspec/, etc.)
```

### CI/CD: Matrix Build, Same Docker Hub Repo

The GitHub Actions workflow uses a matrix strategy with two entries. Both images push to `ybenitezf/ollama-docker-demo` with distinct tags:

| Image | Tags |
|-------|------|
| Ollama | `:latest`, `:<sha>` |
| vLLM | `:vllm-latest`, `:vllm-<sha>` |

Each matrix entry has its own Docker layer cache key (based on the respective Dockerfile).

### Entrypoint Error Handling

Following the existing Ollama pattern:
- Missing `PRIVATE_KEY` → warning printed, server starts without auth
- Missing `MODEL` → error and exit (vLLM cannot start without a model)

Unlike the Ollama image (where nginx returns 401 for missing keys), a vLLM server with no `--api-key` leaves endpoints unprotected. The warning pattern is kept for consistency, but users are strongly advised to always provide a key.

### Model Download and Warmup

vLLM downloads the model from Hugging Face automatically on first `vllm serve` invocation. No separate pull step is needed. The server blocks on port 8000 until the model is downloaded and loaded, so clients polling for readiness will wait naturally. No warmup request is needed since vLLM loads the model into GPU memory during startup.

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| `pip install vllm` resolves to a version incompatible with PyTorch 2.8 | Let pip resolve — if it fails, pin a known-compatible version explicitly |
| Missing `PRIVATE_KEY` leaves API endpoints unprotected | Warning printed at startup; documented in README |
| Model download from Hugging Face at pod start adds cold start time | Inherent to vLLM's design; pre-downloading at build time would bloat the image |
| AWQ model naming on HF varies (user must provide exact name) | Document the expected pattern in README; vLLM's error messages are clear |
| Moving existing files to `ollama/` breaks the current Dockerfile path | CI update is part of this change; the image tags and behavior are unchanged |
