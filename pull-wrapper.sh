#!/usr/bin/env bash
set -euo pipefail

readonly MODEL="${MODEL:-}"

if [[ -z "$MODEL" ]]; then
    echo "WARNING: MODEL environment variable is not set. Skipping model pull."
    exit 0
fi

echo "Waiting for Ollama to be ready..."
until ollama list &>/dev/null; do
    echo "Ollama not ready, waiting..."
    sleep 2
done

echo "Ollama ready. Pulling model: $MODEL"
exec ollama pull "$MODEL"
