# Ollama + vLLM Docker Images for RunPod

Docker images for running [Ollama](https://ollama.com) or [vLLM](https://github.com/vllm-project/vllm) on RunPod.

## Available Images

### Ollama (`ybenitezf/ollama-docker-demo:latest`)

Run any Ollama model with bearer token authentication via nginx reverse proxy.

- **Port:** 8080
- **Environment Variables:**
  - `PRIVATE_KEY` — Bearer token for API authentication (required)
  - `MODEL` — Ollama model name to pull on startup (optional, e.g., `llama3.2`)
- **Architecture:** Ollama server + nginx reverse proxy (auth) + model pull wrapper, orchestrated via supervisord

### vLLM (`ybenitezf/ollama-docker-demo:vllm-latest`)

Serve Hugging Face models via an OpenAI-compatible API with AWQ quantization support.

- **Port:** 8000
- **Environment Variables:**
  - `PRIVATE_KEY` — API key for authentication (optional but recommended, passed as `--api-key`)
  - `MODEL` — Hugging Face model name (required, e.g., `Qwen/Qwen3-VL-30B-AWQ`)
- **Architecture:** Single-process `vllm serve` with native `--api-key` authentication and `--quantization awq`

## Authentication

### Ollama

Bearer token authentication via nginx. All requests must include a valid `Authorization` header.

```bash
curl -H "Authorization: Bearer YOUR_PRIVATE_KEY" http://your-pod-url:8080/api/generate
```

### vLLM

OpenAI-compatible API key authentication. Pass the key via the standard header:

```bash
curl -H "Authorization: Bearer YOUR_PRIVATE_KEY" http://your-pod-url:8000/v1/chat/completions
```

## Docker Images

| Tag | Description | Dockerfile |
|-----|-------------|------------|
| `latest` | Ollama image | `ollama/Dockerfile` |
| `vllm-latest` | vLLM image | `vllm/Dockerfile` |

On push to `main`, both images are built via GitHub Actions matrix workflow and pushed to Docker Hub with both `-latest` and commit SHA tags.
