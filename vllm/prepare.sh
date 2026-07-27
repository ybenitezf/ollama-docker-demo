#!/usr/bin/env bash
set -euo pipefail

main() {
    if [[ -z "${PRIVATE_KEY:-}" ]]; then
        echo "WARNING: PRIVATE_KEY environment variable is not set. Server will start without authentication."
    fi

    if [[ -z "${MODEL:-}" ]]; then
        echo "ERROR: MODEL environment variable is not set."
        exit 1
    fi

    local extra_args=()
    if [[ -n "${PRIVATE_KEY:-}" ]]; then
        extra_args+=(--api-key "$PRIVATE_KEY")
    fi

    if [[ -n "${MAX_MODEL_LEN:-}" ]]; then
        extra_args+=(--max-model-len "$MAX_MODEL_LEN")
    else
        echo "HINT: MAX_MODEL_LEN is not set — defaulting to model's native max_model_len which may be too large for 24GB GPUs. Set MAX_MODEL_LEN=65536 or MAX_MODEL_LEN=131072 if it fails due to KV cache memory."
    fi

    if [[ -n "${GPU_MEMORY_UTILIZATION:-}" ]]; then
        extra_args+=(--gpu-memory-utilization "$GPU_MEMORY_UTILIZATION")
    fi

    echo "Starting vLLM server with model: $MODEL"
    exec vllm serve "$MODEL" \
        --host 0.0.0.0 \
        --port 8000 \
        --quantization awq \
        "${extra_args[@]}"
}

main "$@"
