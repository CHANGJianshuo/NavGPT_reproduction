#!/bin/bash
set -e

MODEL=${1:-gpt-3.5-turbo}
ITERS=${2:-10}
OUTPUT_DIR="../outputs/${MODEL}-$(date +%Y%m%d-%H%M%S)"

echo "Running NavGPT with model=${MODEL}, iters=${ITERS}"
echo "Output: ${OUTPUT_DIR}"

cd /workspace/nav_src
python NavGPT.py \
    --llm_model_name "$MODEL" \
    --output_dir "$OUTPUT_DIR" \
    --iters "$ITERS"
