#!/bin/bash
echo "=== NavGPT Reproduction Verification ==="

echo ""
echo "--- Python & Dependencies ---"
echo -n "Python: "
python --version

python -c "import langchain; print(f'langchain: {langchain.__version__}')" 2>&1
python -c "import openai; print(f'openai: {openai.__version__}')" 2>&1
python -c "import numpy; print(f'numpy: {numpy.__version__}')" 2>&1
python -c "import transformers; print(f'transformers: {transformers.__version__}')" 2>&1
python -c "import networkx; print(f'networkx: {networkx.__version__}')" 2>&1

echo ""
echo "--- API Key ---"
if [ -n "$OPENAI_API_KEY" ]; then
    echo "OPENAI_API_KEY: set (${#OPENAI_API_KEY} chars)"
else
    echo "OPENAI_API_KEY: NOT SET"
fi
if [ -n "$OPENAI_API_BASE" ]; then
    echo "OPENAI_API_BASE: $OPENAI_API_BASE"
fi

echo ""
echo "--- Dataset ---"
for dir in annotations connectivity navigable observations_list_summarized observations_summarized objects_list; do
    path="/workspace/datasets/R2R/${dir}"
    if [ -d "$path" ]; then
        count=$(ls "$path" | wc -l)
        echo "  [OK] ${dir} (${count} files)"
    else
        echo "  [MISSING] ${dir}"
    fi
done

echo ""
echo "--- Source Files ---"
for f in NavGPT.py agent.py agent_base.py env.py parser.py data_utils.py eval_utils.py; do
    if [ -f "/workspace/nav_src/$f" ]; then
        echo "  [OK] $f"
    else
        echo "  [MISSING] $f"
    fi
done

echo ""
echo "--- Import Test ---"
cd /workspace/nav_src
python -c "
from data_utils import construct_instrs
from utils.data import ImageObservationsDB
from parser import parse_args
from env import R2RNavBatch
from agent import NavAgent
print('All imports successful!')
" 2>&1

echo ""
echo "=== Verification complete ==="
