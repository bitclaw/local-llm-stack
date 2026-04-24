#!/bin/bash

# Local LLM Stack - Qwen 3.6 benchmark matrix
# Prints a compact matrix of recommended survival/stability test configurations

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$ROOT_DIR/engines/llama-cpp/config.env"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Missing config: $CONFIG_FILE"
    exit 1
fi

echo "Qwen 3.6 local benchmark matrix"
echo "==============================="
echo ""
echo "Use these in order. Stop when a setup becomes unstable or slower."
echo ""

echo "Preset probes:"
echo "  ./scripts/apply-preset.sh qwen36-survival"
echo "  ./scripts/start.sh llama-cpp"
echo ""
echo "  ./scripts/apply-preset.sh qwen36-safe"
echo "  ./scripts/start.sh llama-cpp"
echo ""
echo "  ./scripts/apply-preset.sh qwen36-lowbatch"
echo "  ./scripts/start.sh llama-cpp"
echo ""
echo "  ./scripts/apply-preset.sh qwen36-stretch"
echo "  ./scripts/start.sh llama-cpp"
echo ""

echo "Manual sweep after a stable baseline:"
echo ""
printf "%-12s %-14s %-12s %-12s\n" "GPU_LAYERS" "CONTEXT_SIZE" "BATCH" "UBATCH"
printf "%-12s %-14s %-12s %-12s\n" "0" "4096" "128" "64"
printf "%-12s %-14s %-12s %-12s\n" "0" "8192" "128" "64"
printf "%-12s %-14s %-12s %-12s\n" "2" "8192" "128" "64"
printf "%-12s %-14s %-12s %-12s\n" "4" "8192" "128" "64"
printf "%-12s %-14s %-12s %-12s\n" "0" "8192" "256" "128"
printf "%-12s %-14s %-12s %-12s\n" "2" "8192" "256" "128"
printf "%-12s %-14s %-12s %-12s\n" "4" "8192" "256" "128"
echo ""

echo "Suggested measurement routine:"
echo "1. Start a config."
echo "2. Send the same coding prompt 3 times."
echo "3. Compare startup success, first-token delay, and usable tokens/sec."
echo "4. Keep the fastest stable setup."
