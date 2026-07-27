## ADDED Requirements

### Requirement: GitHub Actions builds both images via matrix strategy
The GitHub Actions workflow SHALL use a matrix strategy to build both the Ollama and vLLM Docker images in a single workflow run.

#### Scenario: Both images built on push to main
- **WHEN** code is pushed to the main branch
- **THEN** the workflow builds both the Ollama and vLLM images
- **AND** both images are pushed to Docker Hub

#### Scenario: Both images built on pull request
- **WHEN** a pull request is opened or updated
- **THEN** the workflow builds both the Ollama and vLLM images
- **AND** neither image is pushed to Docker Hub

#### Scenario: Each image uses its own Dockerfile
- **WHEN** the matrix build runs
- **THEN** the Ollama entry uses `ollama/Dockerfile` as its Dockerfile and `ollama/` as its build context
- **AND** the vLLM entry uses `vllm/Dockerfile` as its Dockerfile and `vllm/` as its build context

### Requirement: Each image has its own layer cache key
The workflow SHALL use distinct cache keys per matrix entry based on the respective Dockerfile content hash.

#### Scenario: Cache is separate per image
- **WHEN** the workflow runs
- **THEN** the cache key for the Ollama build includes the hash of `ollama/Dockerfile`
- **AND** the cache key for the vLLM build includes the hash of `vllm/Dockerfile`

### Requirement: Ollama image tags are unchanged
The Ollama image SHALL continue to be pushed with the same tags as before: `:latest` and `:<sha>`.

#### Scenario: Ollama tags preserved
- **WHEN** a successful build completes on main
- **THEN** the Ollama image is tagged `ybenitezf/ollama-docker-demo:latest` and `ybenitezf/ollama-docker-demo:<sha>`

### Requirement: vLLM image uses vllm- prefixed tags
The vLLM image SHALL use `:vllm-latest` and `:vllm-<sha>` tags.

#### Scenario: vLLM tags are distinct
- **WHEN** a successful build completes on main
- **THEN** the vLLM image is tagged `ybenitezf/ollama-docker-demo:vllm-latest` and `ybenitezf/ollama-docker-demo:vllm-<sha>`
