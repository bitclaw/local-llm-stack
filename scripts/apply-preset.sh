#!/bin/bash

# Local LLM Stack - Preset Applier
# Copies a known-good preset into the active llama.cpp config

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PRESET_DIR="$ROOT_DIR/engines/llama-cpp/presets"
TARGET_CONFIG="$ROOT_DIR/engines/llama-cpp/config.env"

usage() {
    echo "Usage: $0 <preset>"
    echo ""
    echo "Available presets:"
    echo "  qwen25-7b-balanced"
    echo "  qwen36-safe"
    echo "  qwen36-survival"
    echo "  qwen36-lowbatch"
    echo "  qwen36-stretch"
}

if [ $# -ne 1 ]; then
    usage
    exit 1
fi

case "$1" in
    qwen25-7b-balanced)
        PRESET_FILE="$PRESET_DIR/qwen25-coder-7b-rtx5050-balanced.env"
        ;;
    qwen36-safe)
        PRESET_FILE="$PRESET_DIR/qwen36-35b-a3b-rtx5050-safe.env"
        ;;
    qwen36-survival)
        PRESET_FILE="$PRESET_DIR/qwen36-35b-a3b-rtx5050-survival.env"
        ;;
    qwen36-lowbatch)
        PRESET_FILE="$PRESET_DIR/qwen36-35b-a3b-rtx5050-lowbatch.env"
        ;;
    qwen36-stretch)
        PRESET_FILE="$PRESET_DIR/qwen36-35b-a3b-rtx5050-stretch.env"
        ;;
    *)
        echo "Unknown preset: $1"
        echo ""
        usage
        exit 1
        ;;
esac

cp "$PRESET_FILE" "$TARGET_CONFIG"
echo "Applied preset: $1"
echo "Active config: $TARGET_CONFIG"
