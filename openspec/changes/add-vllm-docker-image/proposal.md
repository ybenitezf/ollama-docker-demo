## Why

The project currently builds a single Docker image for Ollama on RunPod. Adding a vLLM-based image lets users deploy Qwen3-VL-30B and other Hugging Face models with native OpenAI-compatible API support, built-in API key authentication, and AWQ quantization support — without needing nginx or supervisord.

## What Changes

- **New vLLM Docker image** — build and push `ybenitezf/ollama-docker-demo:vllm-latest` and `:vllm-<sha>` alongside the existing Ollama image
- **Restructure project files** — move existing Ollama files (`Dockerfile`, `prepare.sh`, `pull-wrapper.sh`, `nginx.conf.template`, `supervisord.conf`) into an `ollama/` subdirectory
- **New `vllm/` subdirectory** — contains `Dockerfile` and `prepare-vllm.sh` for the vLLM image
- **Update GitHub Actions workflow** — matrix build that produces both images
- **Remove nginx and supervisord from vLLM image** — vLLM's native `--api-key` and single-process model eliminate the need for both

## Capabilities

### New Capabilities

- `vllm-docker-image`: The vLLM-based Docker image that serves models via an OpenAI-compatible API on port 8000, with built-in API key authentication and AWQ quantization support
- `ci-matrix-build`: The GitHub Actions workflow builds and pushes both the Ollama and vLLM Docker images using a matrix strategy

### Modified Capabilities

<!-- No existing spec requirements are changing — we're adding new capabilities, not altering existing ones -->

## Impact

- **`ollama/`** — new subdirectory containing existing Dockerfile, prepare.sh, pull-wrapper.sh, nginx.conf.template, supervisord.conf
- **`vllm/`** — new subdirectory with Dockerfile and prepare-vllm.sh
- **`.github/workflows/build.yml`** — updated to build both images via matrix strategy
- **Docker Hub** — new image tags `ybenitezf/ollama-docker-demo:vllm-latest` and `:vllm-<sha>` pushed on main branch commits
- **Existing users** — the Ollama image (built from `ollama/Dockerfile`) is unchanged in behavior; files moved to subdirectory but container functionality is identical
