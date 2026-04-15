#!/bin/bash

# Local LLM Stack - Qwen2.5-Coder Model Downloader
# Downloads recommended Qwen2.5-Coder models for development work

set -e

# Configuration
MODELS_DIR="$HOME/models"
TEMP_DIR="/tmp/model-download"

# Model definitions
# Format: "model_name|huggingface_repo|file_name|description|size"
MODELS=(
    "qwen-7b|Qwen/Qwen2.5-Coder-7B-Instruct-GGUF|qwen2.5-coder-7b-instruct-q4_k_m.gguf|Fast 7B model for basic coding|4.4GB"
    "qwen-14b|Qwen/Qwen2.5-Coder-14B-Instruct-GGUF|qwen2.5-coder-14b-instruct-q4_k_m.gguf|Balanced 14B model for most tasks (recommended)|8.5GB"
    "qwen-32b|Qwen/Qwen2.5-Coder-32B-Instruct-GGUF|qwen2.5-coder-32b-instruct-q4_k_m.gguf|Large 32B model for complex tasks|19.6GB"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
echo_success() { echo -e "${GREEN}✅ $1${NC}"; }
echo_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
echo_error() { echo -e "${RED}❌ $1${NC}"; }

print_header() {
    echo "📥 Qwen2.5-Coder Model Downloader"
    echo "=================================="
    echo ""
    echo "This script downloads optimized GGUF models for local development."
    echo "Models are saved to: $MODELS_DIR"
    echo ""
}

show_models() {
    echo "Available models:"
    echo ""
    local i=1
    for model_def in "${MODELS[@]}"; do
        IFS='|' read -r name repo file desc size <<< "$model_def"
        echo -e "${BLUE}$i)${NC} ${GREEN}$name${NC}"
        echo "   $desc"
        echo "   File: $file"
        echo "   Size: $size"
        echo ""
        ((i++))
    done
    echo -e "${BLUE}a)${NC} Download all models"
    echo -e "${BLUE}q)${NC} Quit"
    echo ""
}

download_model() {
    local repo="$1"
    local file="$2"
    local name="$3"

    echo_info "Downloading $name..."
    echo "Repository: $repo"
    echo "File: $file"
    echo "Destination: $MODELS_DIR/$file"
    echo ""

    # Create directories
    mkdir -p "$MODELS_DIR"
    mkdir -p "$TEMP_DIR"

    # Check if file already exists
    if [ -f "$MODELS_DIR/$file" ]; then
        echo_warning "File already exists: $MODELS_DIR/$file"
        read -p "Overwrite? (y/N): " confirm
        if [[ ! $confirm =~ ^[Yy]$ ]]; then
            echo_info "Skipping download"
            return 0
        fi
    fi

    # Download using wget
    echo_info "Starting download (this may take a while)..."
    local url="https://huggingface.co/$repo/resolve/main/$file"

    if command -v wget &> /dev/null; then
        if wget --progress=bar:force:noscroll -O "$TEMP_DIR/$file" "$url"; then
            mv "$TEMP_DIR/$file" "$MODELS_DIR/$file"
            echo_success "Download completed: $file"
        else
            echo_error "Download failed"
            rm -f "$TEMP_DIR/$file"
            return 1
        fi
    elif command -v curl &> /dev/null; then
        if curl -L --progress-bar -o "$TEMP_DIR/$file" "$url"; then
            mv "$TEMP_DIR/$file" "$MODELS_DIR/$file"
            echo_success "Download completed: $file"
        else
            echo_error "Download failed"
            rm -f "$TEMP_DIR/$file"
            return 1
        fi
    else
        echo_error "Neither wget nor curl found. Please install one of them."
        return 1
    fi

    # Verify file
    if [ -f "$MODELS_DIR/$file" ]; then
        local size=$(du -h "$MODELS_DIR/$file" | cut -f1)
        echo_success "Model saved: $MODELS_DIR/$file ($size)"

        # Update config file if this is the default model
        if [ "$file" = "qwen2.5-coder-14b-instruct-q4_k_m.gguf" ]; then
            echo_info "This is the default model - configuration is already set"
        fi
    else
        echo_error "Verification failed - file not found after download"
        return 1
    fi
}

check_space() {
    local required_gb="$1"
    local available_gb=$(df "$MODELS_DIR" --output=avail -B1G 2>/dev/null | tail -1 || echo "0")

    if [ "$available_gb" -lt "$required_gb" ]; then
        echo_warning "Insufficient disk space. Required: ${required_gb}GB, Available: ${available_gb}GB"
        return 1
    fi
    return 0
}

interactive_download() {
    while true; do
        show_models
        read -p "Select model to download (number, 'a' for all, 'q' to quit): " choice

        case $choice in
            [1-3])
                local index=$((choice - 1))
                local model_def="${MODELS[$index]}"
                IFS='|' read -r name repo file desc size <<< "$model_def"

                # Extract size number for space check
                local size_gb=$(echo "$size" | sed 's/[^0-9.]*//g' | cut -d'.' -f1)
                if check_space "$((size_gb + 1))"; then
                    download_model "$repo" "$file" "$name"
                fi
                ;;
            a|A)
                echo_info "Downloading all models..."
                # Check total space needed
                local total_size=32  # Rough estimate
                if check_space "$total_size"; then
                    for model_def in "${MODELS[@]}"; do
                        IFS='|' read -r name repo file desc size <<< "$model_def"
                        download_model "$repo" "$file" "$name"
                    done
                fi
                ;;
            q|Q)
                echo_info "Goodbye!"
                exit 0
                ;;
            *)
                echo_error "Invalid selection. Please try again."
                ;;
        esac

        echo ""
        read -p "Download another model? (y/N): " continue
        if [[ ! $continue =~ ^[Yy]$ ]]; then
            break
        fi
        echo ""
    done
}

cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

main() {
    # Set trap for cleanup
    trap cleanup EXIT

    print_header

    # Check internet connectivity
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        echo_error "No internet connection detected"
        exit 1
    fi

    # Check for download tools
    if ! command -v wget &> /dev/null && ! command -v curl &> /dev/null; then
        echo_error "Neither wget nor curl found. Please install one:"
        echo "  sudo pacman -S wget"
        exit 1
    fi

    # Create models directory
    mkdir -p "$MODELS_DIR"

    # Check if specific model requested
    if [ $# -gt 0 ]; then
        case "$1" in
            7b|qwen-7b)
                download_model "Qwen/Qwen2.5-Coder-7B-Instruct-GGUF" "qwen2.5-coder-7b-instruct-q4_k_m.gguf" "qwen-7b"
                ;;
            14b|qwen-14b|default)
                download_model "Qwen/Qwen2.5-Coder-14B-Instruct-GGUF" "qwen2.5-coder-14b-instruct-q4_k_m.gguf" "qwen-14b"
                ;;
            32b|qwen-32b)
                download_model "Qwen/Qwen2.5-Coder-32B-Instruct-GGUF" "qwen2.5-coder-32b-instruct-q4_k_m.gguf" "qwen-32b"
                ;;
            --help|-h)
                echo "Usage: $0 [model]"
                echo ""
                echo "Models:"
                echo "  7b, qwen-7b     Download 7B model"
                echo "  14b, qwen-14b   Download 14B model (recommended)"
                echo "  32b, qwen-32b   Download 32B model"
                echo "  default         Download 14B model"
                echo ""
                echo "If no model specified, interactive selection is shown."
                exit 0
                ;;
            *)
                echo_error "Unknown model: $1"
                echo "Use '$0 --help' for available models"
                exit 1
                ;;
        esac
    else
        # Interactive mode
        interactive_download
    fi

    echo_success "Download process completed!"
    echo ""
    echo_info "Next steps:"
    echo "1. Start the LLM server: ./scripts/start.sh llama-cpp"
    echo "2. Configure Claude Code with:"
    echo "   export OPENAI_API_BASE=http://localhost:8000/v1"
    echo "   export OPENAI_API_KEY=sk-local"
}

main "$@"