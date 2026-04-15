#!/bin/bash

# Local LLM Stack - llama.cpp Server Runner
# Starts llama.cpp server with optimized configuration

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.env"

# Load configuration
if [ -f "$CONFIG_FILE" ]; then
    echo "=� Loading configuration from $CONFIG_FILE"
    source "$CONFIG_FILE"
else
    echo "L Configuration file not found: $CONFIG_FILE"
    echo "Please ensure config.env exists with proper settings"
    exit 1
fi

# Check if model exists
if [ ! -f "$MODEL_PATH" ]; then
    echo "L Model not found: $MODEL_PATH"
    echo "Please download a model first:"
    echo "  ./models/download-qwen.sh"
    exit 1
fi

# Check if llama-server exists
LLAMA_SERVER_BIN=""
if command -v llama-server &> /dev/null; then
    LLAMA_SERVER_BIN="llama-server"
elif [ -f "$HOME/llama.cpp/build/bin/llama-server" ]; then
    LLAMA_SERVER_BIN="$HOME/llama.cpp/build/bin/llama-server"
else
    echo "L llama-server binary not found"
    echo "Please install llama.cpp first:"
    echo "  ./engines/llama-cpp/install.sh"
    exit 1
fi

echo ">� Starting llama.cpp server..."
echo "=� Configuration:"
echo "  Model: $MODEL_PATH"
echo "  Host: $HOST:$PORT"
echo "  GPU Layers: $GPU_LAYERS"
echo "  Context Size: $CONTEXT_SIZE"
echo "  Threads: $THREADS"
echo ""

# Build command arguments
CMD_ARGS=(
    "$LLAMA_SERVER_BIN"
    --model "$MODEL_PATH"
    --host "$HOST"
    --port "$PORT"
    --ctx-size "$CONTEXT_SIZE"
    --n-gpu-layers "$GPU_LAYERS"
    --threads "$THREADS"
    --cache-type-k "$CACHE_TYPE_K"
    --cache-type-v "$CACHE_TYPE_V"
    --batch-size "$BATCH_SIZE"
    --ubatch-size "$UBATCH_SIZE"
)

# Add optional flags
if [ "$FLASH_ATTN" != "0" ]; then
    CMD_ARGS+=(--flash-attn "$FLASH_ATTN")
fi

if [ "$MMAP" = "1" ]; then
    CMD_ARGS+=(--mmap)
fi

if [ "$CONT_BATCHING" = "1" ]; then
    CMD_ARGS+=(--cont-batching)
fi

if [ "$PARALLEL" = "1" ]; then
    CMD_ARGS+=(--parallel 1)
fi

echo "=� Starting server with command:"
echo "${CMD_ARGS[*]}"
echo ""
echo "< Server will be available at: http://$HOST:$PORT"
echo "=� API documentation: http://$HOST:$PORT/docs"
echo "=' Health check: http://$HOST:$PORT/health"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Handle graceful shutdown
trap 'echo ""; echo "Shutting down server..."; exit 0' INT TERM

# Check for background mode
if [ "$1" = "--daemon" ] || [ "$1" = "-d" ]; then
    echo "Starting server in background..."
    exec "${CMD_ARGS[@]}" &>/dev/null &
    echo "Server started (PID: $!)"
    exit 0
fi

# Start the server
exec "${CMD_ARGS[@]}"