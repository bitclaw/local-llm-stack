#!/bin/bash

# Local LLM Stack - Main Entrypoint
# Unified script to start different LLM engines

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Print usage information
usage() {
    echo "Local LLM Stack - Start Script"
    echo ""
    echo "Usage: $0 <engine> [options]"
    echo ""
    echo "Engines:"
    echo "  llama-cpp    Start llama.cpp server (recommended)"
    echo "  vllm         Start vLLM server (coming soon)"
    echo ""
    echo "Options:"
    echo "  -h, --help   Show this help message"
    echo "  -v, --version Show version information"
    echo "  -d, --daemon Run server in background"
    echo ""
    echo "Examples:"
    echo "  $0 llama-cpp           Start llama.cpp with default config"
    echo ""
    echo "For Claude Code integration:"
    echo "  export OPENAI_API_BASE=http://localhost:8000/v1"
    echo "  export OPENAI_API_KEY=sk-local"
}

# Print version information
version() {
    echo "Local LLM Stack v1.0.0"
    echo "Optimized for Omarchy + NVIDIA GPUs"
    echo "Repository: https://github.com/bitclaw/local-llm-stack"
}

# Detect distribution
detect_distro() {
    if [ -f "$SCRIPT_DIR/detect-distro.sh" ]; then
        DISTRO=$("$SCRIPT_DIR/detect-distro.sh")
        echo "=� Detected distribution: $DISTRO"

        if [ "$DISTRO" != "omarchy" ] && [ "$DISTRO" != "arch" ]; then
            echo "�  Warning: This tool is primarily tested on Omarchy"
            echo "   Detected: $DISTRO"
            echo "   Some features may not work as expected"
        fi
    else
        echo "�  Could not detect distribution"
    fi
}

# Start llama.cpp engine
start_llama_cpp() {
    echo ">� Starting llama.cpp engine..."

    local engine_dir="$ROOT_DIR/engines/llama-cpp"
    local run_script="$engine_dir/run.sh"

    if [ ! -f "$run_script" ]; then
        echo "L llama.cpp run script not found: $run_script"
        echo "Please ensure llama.cpp is installed:"
        echo "  ./engines/llama-cpp/install.sh"
        exit 1
    fi

    if [ ! -x "$run_script" ]; then
        echo "L llama.cpp run script is not executable"
        echo "Run: chmod +x $run_script"
        exit 1
    fi

    echo "=� Executing: $run_script"
    exec "$run_script" "$@"
}

# Start vLLM engine
start_vllm() {
    echo "=� vLLM support is coming soon!"
    echo "For now, please use: $0 llama-cpp"
    exit 1
}

# Main execution
main() {
    # Check for help or version flags
    case "${1:-}" in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--version)
            version
            exit 0
            ;;
    esac

    # Check if engine parameter is provided
    if [ $# -eq 0 ]; then
        echo "L No engine specified"
        echo ""
        usage
        exit 1
    fi

    local engine="$1"
    shift  # Remove engine from arguments

    # Handle daemon mode flag
    local daemon_flag=""
    case "${1:-}" in
        -d|--daemon)
            daemon_flag="--daemon"
            shift
            ;;
    esac

    # Display header
    echo "> Local LLM Stack Starter"
    echo "=========================="

    # Detect distribution
    detect_distro
    echo ""

    # Route to appropriate engine
    case "$engine" in
        llama-cpp|llamacpp)
            start_llama_cpp "$daemon_flag" "$@"
            ;;
        vllm)
            start_vllm "$@"
            ;;
        *)
            echo "L Unknown engine: $engine"
            echo ""
            echo "Available engines:"
            echo "  llama-cpp"
            echo "  vllm (coming soon)"
            echo ""
            echo "Use '$0 --help' for more information"
            exit 1
            ;;
    esac
}

# Execute main function with all arguments
main "$@"