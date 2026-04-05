FROM python:3.9-slim-bullseye

RUN apt-get update && apt-get install -y --no-install-recommends \
    git wget curl unzip vim \
    && rm -rf /var/lib/apt/lists/*

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
