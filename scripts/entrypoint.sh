#!/bin/bash
set -e

if [ -z "$OPENAI_API_KEY" ]; then
    echo "WARNING: OPENAI_API_KEY is not set."
    echo "Set it in .env or pass via: -e OPENAI_API_KEY=your_key"
fi

if [ -n "$OPENAI_API_BASE" ]; then
    echo "Using custom API base: $OPENAI_API_BASE"
fi

if [ ! -d "/workspace/datasets/R2R/annotations" ]; then
    echo "WARNING: Dataset not found at /workspace/datasets/R2R/"
    echo "Run: bash /workspace/scripts/download_data.sh"
fi

exec "$@"
