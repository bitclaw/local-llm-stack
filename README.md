# Local LLM Stack

Fast, minimal local LLM setup for Omarchy. Replace OpenAI/Anthropic APIs with a local stack.

## Tested Hardware

- **GPU:** NVIDIA GeForce RTX 5050 (8GB VRAM)
- **CPU:** AMD Ryzen 5 5600T (6 cores, 12 threads)
- **RAM:** 64GB DDR4 3200MHz
- **OS:** Omarchy (Arch-based)

## Tested Configuration

**RTX 5050 8GB VRAM:** Uses CPU inference (GPU layers = 0) due to VRAM limitations.
- 7B model works on CPU (~4.4 tokens/sec)
- 14B+ models need more VRAM

## Quick Start

```bash
git clone https://github.com/bitclaw/local-llm-stack.git
cd local-llm-stack

# Install dependencies
./distros/omarchy/packages.sh
./distros/omarchy/install.sh

# Build llama.cpp
./engines/llama-cpp/install.sh

# Download model (7B works with 8GB VRAM)
./models/download-qwen.sh

# Start server (CPU mode for 8GB VRAM)
./scripts/start.sh llama-cpp
```

Server runs at `http://localhost:8000`

### Background/Daemon Mode
```bash
./scripts/start.sh llama-cpp -d   # or --daemon
```

Server will run in background. Stop with:
```bash
pkill -f llama-server
```

## Configuration

Edit `engines/llama-cpp/config.env`:
- `GPU_LAYERS`: 0=CPU only, 20+=GPU (needs 10GB+ VRAM)
- `MODEL_PATH`: Path to model file
- `CONTEXT_SIZE`: 16384 default

See [engines/llama-cpp/CONFIG_GUIDE.md](engines/llama-cpp/CONFIG_GUIDE.md) for detailed tuning.

### Quick VRAM Guide

| GPU | VRAM | Recommended | Max Layers |
|-----|-----|-------------|------------|
| RTX 5050 | 8GB | 7B, CPU mode | 0 |
| RTX 4060 | 8GB | 7B | 20-28 |
| RTX 4070 | 12GB | 7B/14B | 28-35 |
| RTX 4080 | 16GB | 14B | all |
| RTX 4090 | 24GB | 14B/32B | all |

## Claude Code / OpenCode

```bash
export OPENAI_API_BASE=http://localhost:8000/v1
export OPENAI_API_KEY=sk-local
```

Editor config:
- Provider: OpenAI-compatible
- Base URL: `http://localhost:8000/v1`
- Model: `qwen2.5-coder`

## Model Recommendations

| Model | Size | VRAM | Notes |
|-------|------|-----|-------|
| qwen-7b | 4.4GB | CPU | Works on CPU |
| qwen-14b | 8.5GB | 10GB+ | Needs GPU |
| qwen-32b | 19.6GB | 22GB+ | Needs powerful GPU |

## Troubleshooting

### Server won't start / Connection refused
```bash
# Check if already running
pkill -f llama-server

# Start in background
./scripts/start.sh llama-cpp -d
```

### Out of memory (OOM)
RTX 5050 8GB can't run with GPU. Set in config.env:
```bash
GPU_LAYERS=0  # CPU only
```

### CORS / Connection errors in browser
- Use 127.0.0.1 instead of localhost
- Check firewall: `sudo firewall-cmd --add-port=8000/tcp`

### CUDA not found
```bash
export PATH="/opt/cuda/bin:$PATH"
```

### llama-server not found
```bash
export PATH="$HOME/llama.cpp/build/bin:$PATH"
```

## System Requirements

- **OS:** Omarchy/Arch Linux
- **RAM:** 16GB+ recommended
- **GPU:** Any NVIDIA (8GB VRAM limited to CPU mode)