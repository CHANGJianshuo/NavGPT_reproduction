# NavGPT Reproduction

Reproduction of [NavGPT: Explicit Reasoning in Vision-and-Language Navigation with Large Language Models](https://arxiv.org/abs/2305.16986) (AAAI 2024).

Original repository: https://github.com/GengzeZhou/NavGPT

## Quick Start

```bash
# 1. Copy and configure environment
cp .env.example .env
# Edit .env with your API key

# 2. Build and run container
docker compose up -d
docker exec -it navgpt_reproduction bash

# 3. Inside container: download dataset
bash /workspace/scripts/download_data.sh

# 4. Verify setup
bash /workspace/scripts/verify_setup.sh

# 5. Run NavGPT (10 samples quick test)
cd /workspace/nav_src
python NavGPT.py --llm_model_name gpt-3.5-turbo \
    --output_dir ../outputs/test-run \
    --iters 10
```

## Project Structure

```
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
├── nav_src/              # NavGPT source code
├── scripts/              # Helper scripts
├── datasets/             # R2R dataset (mounted volume)
└── outputs/              # Experiment results (mounted volume)
```

## Notes

- Uses `openai==0.28.1` and `langchain==0.0.246` (pinned for compatibility)
- Supports OpenAI-compatible APIs via `OPENAI_API_BASE` environment variable
- GPU not required for runtime (uses pre-extracted text observations)
