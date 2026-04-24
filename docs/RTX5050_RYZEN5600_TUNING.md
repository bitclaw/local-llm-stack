# RTX 5050 8GB + Ryzen 5600 + 64GB RAM Tuning

This guide is for the exact class of machine this repo targets:

- NVIDIA RTX 5050 8GB
- Ryzen 5 5600 / 5600T class CPU
- 64GB DDR4
- Arch or Omarchy

The goal is to maximize useful local coding performance without pretending this is a 16GB or 24GB GPU box.

## Practical Model Ranking

1. `Qwen2.5-Coder-7B Q4_K_M`
   Best default for daily responsiveness.
2. `Qwen3.6-35B-A3B Q4_K_M`
   Best stretch experiment if you want stronger reasoning and accept slower output.
3. `Qwen2.5-Coder-14B Q4_K_M`
   Less compelling on this exact machine than the 7B fast path or the newer sparse 3.6 stretch path.

## Preset Workflow

Fast baseline:

```bash
./scripts/apply-preset.sh qwen25-7b-balanced
./scripts/start.sh llama-cpp
```

Qwen 3.6 safe mode:

```bash
./scripts/apply-preset.sh qwen36-safe
./scripts/start.sh llama-cpp
```

Qwen 3.6 survival mode:

```bash
./scripts/apply-preset.sh qwen36-survival
./scripts/start.sh llama-cpp
```

Low-batch probe:

```bash
./scripts/apply-preset.sh qwen36-lowbatch
./scripts/start.sh llama-cpp
```

If safe mode works cleanly, test:

```bash
./scripts/apply-preset.sh qwen36-stretch
./scripts/start.sh llama-cpp
```

## How To Squeeze Performance

### Keep Context Small First

- Start `Qwen2.5-Coder-7B` at `16384`
- Start `Qwen3.6-35B-A3B` survival mode at `4096`
- Start `Qwen3.6-35B-A3B` at `8192`

Increase context only after speed and stability are already acceptable.

### Probe `GPU_LAYERS`, Do Not Assume It

On your machine:

- `0` is the safe baseline
- `2-4` is worth testing on large stretch models
- if load fails or becomes unstable, go back to `0`

### Lower Batch Sizes For Marginal Fits

If a model barely loads, reduce:

- `BATCH_SIZE`
- `UBATCH_SIZE`

This usually helps stability more than chasing extra GPU layers.

For your box, the practical low-memory values are:

- `BATCH_SIZE=128`
- `UBATCH_SIZE=64`

### Keep Cache Quantized

`CACHE_TYPE_K=q4_0` and `CACHE_TYPE_V=q4_0` are the right defaults on this hardware class.

This is one of the few real wins available on low-VRAM systems because KV cache growth becomes painful fast as context grows.

### Use All CPU Threads, But Verify

Start with:

```bash
THREADS=12
```

If the system feels too busy, compare `10` and `12`.

### Leave `MMAP=1`

This is usually the right tradeoff for loading large local GGUFs.

## Arch / Omarchy Notes

- Use the proprietary NVIDIA stack.
- Keep CUDA and the driver version aligned.
- Close browsers and Electron apps before benchmarking.
- Treat swap as a safety net, not a performance feature.
- Keep `llama.cpp` current for newer Qwen 3.6 support.

## Reality Check

If you want the best daily coding experience, use the 7B preset.

If you want to see how far the box can be pushed locally, test Qwen 3.6 safe mode first, then stretch mode.

Use `./scripts/benchmark-qwen36.sh` to run the recommended test order instead of guessing.
