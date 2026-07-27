## 1. Project Restructure

- [x] 1.1 Create `ollama/` subdirectory and move existing files: `Dockerfile`, `prepare.sh`, `pull-wrapper.sh`, `nginx.conf.template`, `supervisord.conf`
- [x] 1.2 Create `vllm/` subdirectory for the new vLLM image files

## 2. vLLM Docker Image

- [x] 2.1 Create `vllm/Dockerfile` — base `runpod/pytorch:1.0.2-cu1281-torch280-ubuntu2404`, install vLLM via pip, copy entrypoint, expose port 8000
- [x] 2.2 Create `vllm/prepare.sh` — validate `PRIVATE_KEY` and `MODEL` env vars, exec `vllm serve` with `--api-key`, `--quantization awq`, port 8000
- [x] 2.3 Verify both files are executable and syntactically correct

## 3. CI/CD Update

- [x] 3.1 Update `.github/workflows/build.yml` to use a matrix strategy with two entries (ollama and vllm), each pointing to their respective Dockerfile and build context
- [x] 3.2 Add distinct Docker layer cache keys per matrix entry using the respective Dockerfile hash
- [x] 3.3 Set the Ollama image tags to `ybenitezf/ollama-docker-demo:latest` and `:<sha>`
- [x] 3.4 Set the vLLM image tags to `ybenitezf/ollama-docker-demo:vllm-latest` and `:vllm-<sha>`

## 4. Documentation

- [x] 4.1 Update `README.md` with the vLLM image description, env vars, and tag information
- [x] 4.2 Update `AGENTS.md` to reflect the new project structure and vLLM image
