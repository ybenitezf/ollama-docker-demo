## ADDED Requirements

### Requirement: vLLM Docker image is built and pushed
The project SHALL build a Docker image for vLLM and push it to Docker Hub as `ybenitezf/ollama-docker-demo:vllm-latest` and `:vllm-<sha>`.

#### Scenario: Image builds successfully on push to main
- **WHEN** code is pushed to the main branch
- **THEN** GitHub Actions builds the vLLM Docker image using the Dockerfile at `vllm/Dockerfile`
- **AND** the image is tagged with both `:vllm-latest` and `:vllm-<sha>`

#### Scenario: Image builds but is NOT pushed on pull request
- **WHEN** a pull request is opened or updated
- **THEN** the vLLM image is built to verify it compiles
- **AND** the image is NOT pushed to Docker Hub

### Requirement: vLLM image uses runpod/pytorch base
The vLLM Docker image SHALL use `runpod/pytorch:1.0.2-cu1281-torch280-ubuntu2404` as its base image.

#### Scenario: Base image is specified
- **WHEN** the vLLM Dockerfile is built
- **THEN** the FROM directive specifies `runpod/pytorch:1.0.2-cu1281-torch280-ubuntu2404`

### Requirement: vLLM is installed via pip
The Dockerfile SHALL install vLLM using `pip install vllm` with automatic version resolution against the base image's PyTorch 2.8 and CUDA 12.8.

#### Scenario: vLLM is present in image
- **WHEN** the Docker image is built
- **THEN** `vllm` is installed and the `vllm serve` command is available

### Requirement: Entrypoint validates environment variables
The vLLM container SHALL use a `prepare.sh` entrypoint that validates required environment variables before starting the vLLM server.

#### Scenario: PRIVATE_KEY is missing
- **WHEN** the container starts without the `PRIVATE_KEY` environment variable
- **THEN** a warning is printed to stdout
- **AND** the vLLM server starts without authentication

#### Scenario: MODEL is missing
- **WHEN** the container starts without the `MODEL` environment variable
- **THEN** an error message is printed
- **AND** the container exits with a non-zero status

#### Scenario: Both PRIVATE_KEY and MODEL are set
- **WHEN** the container starts with both `PRIVATE_KEY` and `MODEL` environment variables
- **THEN** the vLLM server starts with `--api-key "$PRIVATE_KEY"` and `--model "$MODEL"`

### Requirement: vLLM serves on port 8000 with AWQ quantization
The vLLM server SHALL listen on port 8000 and use AWQ quantization.

#### Scenario: Server starts with AWQ quantization
- **WHEN** the vLLM server starts
- **THEN** it passes `--host 0.0.0.0 --port 8000 --quantization awq` flags
- **AND** the server downloads the model from Hugging Face if not cached

#### Scenario: Model is downloaded automatically
- **WHEN** the vLLM server starts and the model is not in the Hugging Face cache
- **THEN** vLLM downloads the model from Hugging Face before starting the HTTP server

### Requirement: Docker image exposes port 8000
The Dockerfile SHALL expose port 8000.

#### Scenario: EXPOSE directive present
- **WHEN** the Docker image is built
- **THEN** EXPOSE 8000 is present in the image metadata
