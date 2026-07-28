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

---

## vLLM Deployment Guide

### Option A: Using the official `vllm/vllm-openai` image (recommended for RunPod)

This was tested and confirmed working on an **L40S GPU (48GB VRAM)**.

**Step 1: Create a RunPod template**
- **Container Image:** `vllm/vllm-openai:latest`
- **Port:** `8000` → HTTP
- **Environment Variables:**
  - `VLLM_API_KEY` — your API key for auth (optional but recommended)
- **Command Override:** (the full model + args, since the image's entrypoint is already `vllm serve`)
  ```
  QuantTrio/Qwen3-VL-30B-A3B-Instruct-AWQ --host 0.0.0.0 --port 8000 --dtype auto --gpu-memory-utilization 0.95 --max-model-len 131072 --quantization awq
  ```

**Step 2: Create a pod from the template**
- Select an L40S GPU (48GB VRAM)
- ⚠️ Click **Additional filters** → **CUDA Versions** → select **CUDA 12.8**
  - This filters host machines to only those whose NVIDIA driver supports CUDA 12.8+
  - Without this, you may land on a machine with an older driver and get a CUDA version mismatch error
- Pick a machine and launch

**Step 3: Wait for startup**
- Check health: `curl https://your-pod-url/health`
- Returns `OK` when ready (first start: ~5–10 min for model download + torch compile)

**Step 4: Test with a request**

```bash
curl https://your-pod-url/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{
    "model": "QuantTrio/Qwen3-VL-30B-A3B-Instruct-AWQ",
    "messages": [{"role": "user", "content": [
      {"type": "text", "text": "Describe this image in detail"},
      {"type": "image_url", "image_url": {"url": "http://images.cocodataset.org/val2017/000000039769.jpg"}}
    ]}],
    "max_tokens": 500
  }'
```

### Option B: Using the custom image (`ybenitezf/ollama-docker-demo:vllm-latest`)

The repo builds a custom vLLM image with env-var convenience:

| Env Variable | Required | Description |
|--------------|----------|-------------|
| `MODEL` | Yes | Hugging Face model name (e.g., `Qwen/Qwen3-VL-30B-A3B-Instruct-AWQ`) |
| `PRIVATE_KEY` | No | API key for authentication (same as `--api-key`) |
| `MAX_MODEL_LEN` | No | Cap context length (e.g., `65536` for 24GB GPUs) |
| `GPU_MEMORY_UTILIZATION` | No | GPU memory usage fraction (e.g., `0.95`) |

- **Port:** 8000
- The image uses `--quantization awq` by default

### Model Compatibility Notes

| Model | HuggingFace ID | Quantization | Min GPU | Min vLLM |
|-------|---------------|--------------|---------|----------|
| Qwen3-VL-30B-A3B (Instruct) | `QuantTrio/Qwen3-VL-30B-A3B-Instruct-AWQ` | AWQ (4-bit) | L40S (48GB) or RTX 4090 (24GB) | ≥ 0.11.0 |
| Qwen3-VL-30B-A3B (Instruct) | `Qwen/Qwen3-VL-30B-A3B-Instruct` | BF16 (full) | A100-80GB (~70GB VRAM) | ≥ 0.11.0 |

- For **24GB GPUs** (RTX 4090/3090): use the AWQ model + `--max-model-len 65536`
- For **48GB GPUs** (L40S): use the AWQ model + `--max-model-len 131072` (tested working)

### Troubleshooting

**"The NVIDIA driver on your system is too old"**
- **Cause:** the pod's host driver doesn't support the CUDA version your container needs
- **Fix:** re-create the pod and use **Additional filters → CUDA Versions** to select a CUDA version that matches your container's requirements

**"KV cache memory insufficient"**
- **Cause:** `max_model_len` is too large for available VRAM
- **Fix:** reduce `--max-model-len` (e.g., from `262144` to `65536` or `131072`)

**First startup is slow**
- Normal: vLLM downloads the model from Hugging Face and runs torch.compile on first start
- Subsequent restarts are faster because models and caches are persisted on the container disk
