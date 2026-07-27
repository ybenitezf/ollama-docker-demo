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
ollama pull "$MODEL"

echo "Model pull complete. Warming up model: $MODEL"
readonly WARMUP_TIMEOUT="${WARMUP_TIMEOUT:-600}"
readonly KEEP_ALIVE="${KEEP_ALIVE:-24h}"

if curl -s -X POST "http://localhost:11434/api/generate" \
    -H "Content-Type: application/json" \
    -d "{
  \"model\": \"$MODEL\",
  \"prompt\": \"\",
  \"stream\": false,
  \"keep_alive\": \"$KEEP_ALIVE\"
}" \
    --max-time "$WARMUP_TIMEOUT" > /dev/null 2>&1; then
    echo "Model warm-up completed successfully"
else
    echo "WARNING: Model warm-up failed (non-fatal). Model will load on first request."
fi
