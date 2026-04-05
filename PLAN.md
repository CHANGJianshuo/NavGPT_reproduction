# NavGPT 复现计划

## Context

复现论文 [NavGPT (AAAI 2024)](https://arxiv.org/abs/2305.16986) 的代码，原项目在 https://github.com/GengzeZhou/NavGPT。NavGPT 将视觉导航转化为纯文本推理：预处理阶段将3D场景转为文本描述（BLIP-2 + 目标检测），运行时由 LLM 基于文本进行导航决策。

**关键发现**：NavGPT 运行时不需要 C++ Matterport3D 渲染器，它读取的是预提取的 JSON 文本观测数据，因此 Docker 容器不需要 CUDA/OpenGL。

## Step 1: 初始化仓库

- Clone 用户的空仓库到 `/home/chang/NavGPT_reproduction`
- Clone 原始 NavGPT 仓库作为参考
- 复制 `nav_src/` 源码到复现仓库
- 创建初始目录结构：

```
NavGPT_reproduction/
├── Dockerfile
├── docker-compose.yml
├── .dockerignore
├── .gitignore
├── .env.example          # OPENAI_API_KEY, OPENAI_API_BASE 模板
├── README.md
├── requirements.txt
├── scripts/
│   ├── entrypoint.sh
│   ├── download_data.sh
│   ├── verify_setup.sh
│   └── run_navgpt.sh
├── nav_src/              # 从原始仓库复制
│   ├── NavGPT.py
│   ├── agent.py
│   ├── agent_base.py
│   ├── env.py
│   ├── parser.py
│   ├── data_utils.py
│   ├── eval_utils.py
│   ├── prompt/
│   ├── scripts/
│   ├── utils/
│   └── LLMs/
├── datasets/             # 挂载卷，不入git
└── outputs/              # 挂载卷，不入git
```

**首次 commit**：初始项目结构

## Step 2: 编写 Dockerfile

基础镜像：`python:3.9-slim-bullseye`（轻量，无CUDA）

```dockerfile
FROM python:3.9-slim-bullseye
RUN apt-get update && apt-get install -y --no-install-recommends \
    git wget curl unzip vim && rm -rf /var/lib/apt/lists/*
WORKDIR /workspace
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY nav_src/ /workspace/nav_src/
COPY scripts/ /workspace/scripts/
RUN chmod +x /workspace/scripts/*.sh
RUN mkdir -p /workspace/datasets /workspace/outputs
ENV PYTHONPATH=/workspace
WORKDIR /workspace/nav_src
ENTRYPOINT ["/workspace/scripts/entrypoint.sh"]
CMD ["bash"]
```

**requirements.txt**（关键版本锁定）:
```
langchain==0.0.246
openai==0.28.1
numpy
transformers
networkx
```

**Commit**：添加 Dockerfile 和依赖配置

## Step 3: 编写 docker-compose.yml

```yaml
version: '3.8'
services:
  navgpt:
    build: .
    container_name: navgpt_reproduction
    runtime: nvidia                    # 预留GPU支持
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - OPENAI_API_BASE=${OPENAI_API_BASE}  # 支持兼容API
    volumes:
      - ./datasets:/workspace/datasets
      - ./outputs:/workspace/outputs
    stdin_open: true
    tty: true
    # X11可视化（预留，取消注释即可启用）
    # environment:
    #   - DISPLAY=${DISPLAY}
    # volumes:
    #   - /tmp/.X11-unix:/tmp/.X11-unix:ro
```

## Step 4: 适配 OpenAI 兼容 API

原始代码使用 `openai==0.28.1`，需修改 `nav_src/agent.py` 以支持自定义 API base URL：

- 在 agent 初始化时检查 `OPENAI_API_BASE` 环境变量
- 设置 `openai.api_base` 指向兼容服务商（如 DeepSeek 等）
- 确保 `--llm_model_name` 参数可以传入兼容服务商的模型名

关键修改文件：
- `nav_src/agent.py`：LLM 初始化逻辑（约 line 160-196）

**Commit**：适配 OpenAI 兼容 API

## Step 5: 编写辅助脚本

### scripts/entrypoint.sh
- 检查 OPENAI_API_KEY 是否设置
- 检查数据集是否存在
- 执行传入的命令

### scripts/download_data.sh
- 从 Dropbox 下载 R2R 数据集
- 从 Matterport3DSimulator 仓库下载 connectivity 数据
- 验证目录完整性（annotations, connectivity, navigable, observations_list_summarized, observations_summarized, objects_list）

### scripts/verify_setup.sh
- 检查 Python 版本和依赖
- 检查 API key
- 检查数据集完整性
- 测试 import

### scripts/run_navgpt.sh
- 封装常用运行命令

**Commit**：添加辅助脚本

## Step 6: 构建和测试容器

```bash
cd /home/chang/NavGPT_reproduction
docker compose build
docker compose run --rm navgpt bash
# 容器内：
bash /workspace/scripts/download_data.sh
bash /workspace/scripts/verify_setup.sh
```

**Commit**：验证环境搭建成功

## Step 7: 运行 NavGPT（需要 API Key 后）

```bash
# 快速测试（10个样本）
python NavGPT.py --llm_model_name gpt-3.5-turbo \
    --output_dir ../outputs/test-run \
    --iters 10

# 完整验证
python NavGPT.py --llm_model_name gpt-4 \
    --output_dir ../outputs/gpt4-val-unseen
```

**Commit**：首次运行结果

## 已知问题与应对

| 问题 | 应对方案 |
|------|---------|
| `langchain==0.0.246` 的 import 路径在新版已废弃 | 严格锁定版本，不升级 |
| `openai==0.28.1` 旧版 SDK 格式 | 锁定版本 + 设置 `openai.api_base` 支持兼容API |
| Dropbox 下载链接可能失效 | 如失效，需联系原作者或自行预处理 |
| GPT-3.5/4 模型名可能已下线 | 通过兼容API传入可用模型名 |

## 周期 Commit 策略

每完成一个 Step 就 commit 一次，commit message 格式：
- `step1: initialize repository structure`
- `step2: add Dockerfile and dependencies`
- `step3: add docker-compose configuration`
- ...

## 验证清单

- [ ] Docker 镜像构建成功
- [ ] 容器内 Python 依赖安装正确
- [ ] R2R 数据集下载完整
- [ ] `python -c "from agent import NavAgent"` 无报错
- [ ] 10 sample 快速测试通过（需 API Key）
- [ ] 输出指标（SR, SPL）与论文可比
