# llama.cpp Configuration Guide

This guide helps you tune settings for YOUR hardware.

## Quick Start Presets

### RTX 5050 (8GB VRAM) - CPU Mode
```
GPU_LAYERS=0
CONTEXT_SIZE=16384
MODEL=7B (only works)
```

### RTX 4060 Ti (10GB VRAM)
```
GPU_LAYERS=20
CONTEXT_SIZE=16384
MODEL=7B or 14B
```

### RTX 4080 Super (16GB VRAM)
```
GPU_LAYERS=35
CONTEXT_SIZE=16384
MODEL=14B
```

### RTX 4090 (24GB VRAM)
```
GPU_LAYERS=all
CONTEXT_SIZE=32768
MODEL=14B or 32B
```

## Critical Settings

### 1. GPU Layers (--n-gpu-layers)

**This is where most people fail.**

| Your GPU | VRAM | 7B Model | 14B Model | 32B Model |
|---------|-----|----------|-----------|-----------|
| RTX 5050 | 8GB | 0 (CPU) | can't | can't |
| RTX 4060 | 8GB | 20-28 | can't | can't |
| RTX 4070 | 12GB | 35 | 20-28 | can't |
| RTX 4080 | 16GB | all | 35 | can't |
| RTX 4090 | 24GB | all | all | 20-30 |

**If it crashes (OOM):** Lower GPU_LAYERS by 5-10

**If it's slow:** Increase GPU_LAYERS by 5

### 2. Context Size (--ctx-size)

**Very important for coding.** Larger context = more memory but more context.

| Context | RAM Usage | Use Case |
|---------|----------|----------|
| 8192 | ~2GB | Fast, simple tasks |
| 16384 | ~4GB | Good default (recommended) |
| 32768 | ~8GB | Complex refactoring |
| 65536 | ~16GB | Full file analysis |

**Start with 16384, increase if you need more context.**

### 3. CPU Threads (--threads)

Set to your CPU thread count:
```bash
# Check your CPU threads
nproc
```

| CPU | Cores/Threads | Recommended |
|-----|--------------|-------------|
| Ryzen 5 5600 | 6/12 | 12 |
| Ryzen 7 5800 | 8/16 | 16 |
| i7-12700 | 12/20 | 16-20 |

## Troubleshooting

### "out of memory" / Crash on Start
```
→ Lower GPU_LAYERS by 10
→ If GPU_LAYERS=0 still fails, lower CONTEXT_SIZE
→ Try smaller model (7B instead of 14B)
```

### Slow Generation
```
→ Increase GPU_LAYERS by 5-10
→ Increase THREADS (up to CPU thread count)
→ Disable FLASH_ATTN (slower but uses less memory)
```

### Context Too Short
```
→ Increase CONTEXT_SIZE (watch RAM usage)
→ nvidia-smi to check VRAM
→ free -h to check RAM
```

## Monitoring

```bash
# Check VRAM usage
nvidia-smi

# Check RAM usage  
free -h

# Check if server is running
curl -s http://localhost:8000/health
```

## Full Command Reference

```bash
llama-server \
  -m ~/models/qwen2.5-coder-7b-instruct-q4_k_m.gguf \
  --host 0.0.0.0 \
  --port 8000 \
  --ctx-size 16384 \
  --n-gpu-layers 0 \
  --threads 12 \
  --cache-type-k q4_0 \
  --cache-type-v q4_0 \
  --batch-size 512 \
  --ubatch-size 512 \
  --flash-attn auto \
  --mmap \
  --cont-batching \
  --parallel 1
```

## Performance Tips

1. **GPU > CPU** - Use GPU_layers if you have enough VRAM
2. **Batch size** - Higher = faster but more memory
3. **Flash Attention** - Enable (`auto`) for speed
4. **MMAP** - Enable for faster model loading
5. **Parallel** - Keep at 1 for single user