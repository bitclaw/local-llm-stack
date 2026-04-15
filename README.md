# Local LLM Stack

Fast, minimal, no vendor lock-in local LLM setup for Omarchy. Replace OpenAI/Anthropic APIs with a local stack optimized for development work.

## Tested Hardware

✅ **Reference Configuration:**
- **GPU:** NVIDIA GeForce RTX 5050
- **CPU:** AMD Ryzen 5 5600T (3.5-4.5 GHz)
- **RAM:** 64GB DDR4 3200MHz
- **Motherboard:** ASUS PRIME B550M-A AC
- **OS:** Omarchy (Arch-based)

## Quick Start

```bash
git clone https://github.com/bitclaw/local-llm-stack.git
cd local-llm-stack

# Install dependencies and NVIDIA/CUDA (Omarchy-safe)
./distros/omarchy/install.sh

# Build and install llama.cpp
./engines/llama-cpp/install.sh

# Download recommended model
./models/download-qwen.sh

# Start the local LLM server
./scripts/start.sh llama-cpp
```

Your local OpenAI-compatible API will be running at `http://localhost:8000`

## Claude Code Integration

After starting the server, configure your environment:

```bash
export OPENAI_API_BASE=http://localhost:8000/v1
export OPENAI_API_KEY=sk-local
```

In Claude Code or OpenCode, use:
- **Provider:** OpenAI-compatible
- **Base URL:** `http://localhost:8000/v1`
- **Model:** `qwen2.5-coder` (or whatever model you loaded)

## Supported Engines
- **llama.cpp** (recommended) - Fast, reliable, CUDA-optimized
- **vLLM** (coming soon) - High throughput for multiple users

## System Requirements
- **OS:** Omarchy (other Arch-based distros may work with modifications)
- **Minimum:** 16GB RAM, any NVIDIA GPU with 6GB+ VRAM
- **Recommended:** 32GB+ RAM, RTX 4060 or better
- **Optimal:** 64GB RAM, RTX 4080+ (tested configuration above)
