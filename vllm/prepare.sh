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
        extra_args=(--api-key "$PRIVATE_KEY")
    fi

    echo "Starting vLLM server with model: $MODEL"
    exec vllm serve "$MODEL" \
        --host 0.0.0.0 \
        --port 8000 \
        --quantization awq \
        "${extra_args[@]}"
}

main "$@"
