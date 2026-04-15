#!/bin/bash

# Local LLM Stack - System Doctor
# Diagnoses system health and configuration for local LLM setup

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Status tracking
ISSUES=0

echo_info() { echo -e "${BLUE}9  $1${NC}"; }
echo_success() { echo -e "${GREEN} $1${NC}"; }
echo_warning() { echo -e "${YELLOW}�  $1${NC}"; ((ISSUES++)); }
echo_error() { echo -e "${RED}L $1${NC}"; ((ISSUES++)); }

# Print header
print_header() {
    echo ">z Local LLM Stack System Doctor"
    echo "================================"
    echo ""
}

# Check distribution
check_distribution() {
    echo_info "Checking Linux distribution..."

    if [ -f "$SCRIPT_DIR/detect-distro.sh" ]; then
        DISTRO=$("$SCRIPT_DIR/detect-distro.sh")
        if [ "$DISTRO" = "omarchy" ]; then
            echo_success "Omarchy detected (fully supported)"
        elif [ "$DISTRO" = "arch" ]; then
            echo_success "Arch Linux detected (supported)"
        elif [ "$DISTRO" = "unknown" ]; then
            echo_warning "Unknown distribution detected"
        else
            echo_warning "Non-Arch distribution detected: $DISTRO (limited support)"
        fi
    else
        echo_error "detect-distro.sh script not found"
    fi
    echo ""
}

# Check system specifications
check_system_specs() {
    echo_info "Checking system specifications..."

    # Check RAM
    if command -v free &> /dev/null; then
        RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
        if [ "$RAM_GB" -ge 32 ]; then
            echo_success "RAM: ${RAM_GB}GB (excellent for large models)"
        elif [ "$RAM_GB" -ge 16 ]; then
            echo_success "RAM: ${RAM_GB}GB (good for medium models)"
        else
            echo_warning "RAM: ${RAM_GB}GB (may limit model choices)"
        fi
    else
        echo_warning "Cannot determine RAM amount"
    fi

    # Check CPU cores
    CPU_CORES=$(nproc)
    if [ "$CPU_CORES" -ge 8 ]; then
        echo_success "CPU cores: $CPU_CORES (excellent)"
    elif [ "$CPU_CORES" -ge 4 ]; then
        echo_success "CPU cores: $CPU_CORES (good)"
    else
        echo_warning "CPU cores: $CPU_CORES (may affect performance)"
    fi

    echo ""
}

# Check NVIDIA setup
check_nvidia() {
    echo_info "Checking NVIDIA GPU setup..."

    # Check if nvidia-smi exists
    if command -v nvidia-smi &> /dev/null; then
        echo_success "nvidia-smi found"

        # Check GPU information
        GPU_INFO=$(nvidia-smi --query-gpu=name,memory.total --format=csv,noheader,nounits 2>/dev/null || echo "")
        if [ -n "$GPU_INFO" ]; then
            echo_success "GPU detected: $GPU_INFO"

            # Extract VRAM amount (rough)
            VRAM=$(echo "$GPU_INFO" | awk -F',' '{print $2}' | xargs)
            if [ "$VRAM" -ge 12000 ]; then
                echo_success "VRAM: ${VRAM}MB (excellent for large models)"
            elif [ "$VRAM" -ge 8000 ]; then
                echo_success "VRAM: ${VRAM}MB (good for medium models)"
            elif [ "$VRAM" -ge 6000 ]; then
                echo_warning "VRAM: ${VRAM}MB (limited to smaller models)"
            else
                echo_warning "VRAM: ${VRAM}MB (may struggle with larger models)"
            fi
        else
            echo_error "Cannot query GPU information"
        fi
    else
        echo_error "nvidia-smi not found - NVIDIA drivers not installed"
        echo_info "Install with: ./distros/arch/install.sh"
    fi

    # Check CUDA
    if command -v nvcc &> /dev/null; then
        CUDA_VERSION=$(nvcc --version | grep release | sed 's/.*release \([0-9.]*\).*/\1/')
        echo_success "CUDA toolkit found: v$CUDA_VERSION"
    else
        echo_error "CUDA toolkit not found"
        echo_info "Install with: ./distros/arch/install.sh"
    fi

    echo ""
}

# Check llama.cpp installation
check_llama_cpp() {
    echo_info "Checking llama.cpp installation..."

    # Check binary locations
    LLAMA_FOUND=false
    if command -v llama-server &> /dev/null; then
        echo_success "llama-server found in PATH"
        LLAMA_FOUND=true
    elif [ -f "$HOME/llama.cpp/build/bin/llama-server" ]; then
        echo_success "llama-server found at $HOME/llama.cpp/build/bin/llama-server"
        LLAMA_FOUND=true
    else
        echo_error "llama-server not found"
        echo_info "Install with: ./engines/llama-cpp/install.sh"
    fi

    # Test CUDA support if binary exists
    if $LLAMA_FOUND; then
        LLAMA_BIN=""
        if command -v llama-server &> /dev/null; then
            LLAMA_BIN="llama-server"
        else
            LLAMA_BIN="$HOME/llama.cpp/build/bin/llama-server"
        fi

        if "$LLAMA_BIN" --help 2>&1 | grep -q "gpu-layers"; then
            echo_success "CUDA support detected in llama.cpp"
        else
            echo_warning "CUDA support not detected in llama.cpp binary"
        fi
    fi

    echo ""
}

# Check configuration files
check_config() {
    echo_info "Checking configuration files..."

    # Check llama.cpp config
    LLAMA_CONFIG="$ROOT_DIR/engines/llama-cpp/config.env"
    if [ -f "$LLAMA_CONFIG" ]; then
        echo_success "llama.cpp config found: $LLAMA_CONFIG"

        # Check if model path is set
        if grep -q "MODEL_PATH=" "$LLAMA_CONFIG"; then
            MODEL_PATH=$(grep "MODEL_PATH=" "$LLAMA_CONFIG" | cut -d'=' -f2 | tr -d '"' | envsubst)
            if [ -f "$MODEL_PATH" ]; then
                echo_success "Configured model found: $MODEL_PATH"
            else
                echo_warning "Configured model not found: $MODEL_PATH"
                echo_info "Download with: ./models/download-qwen.sh"
            fi
        fi
    else
        echo_error "llama.cpp config not found: $LLAMA_CONFIG"
    fi

    echo ""
}

# Check models directory
check_models() {
    echo_info "Checking models directory..."

    MODELS_DIR="$HOME/models"
    if [ -d "$MODELS_DIR" ]; then
        echo_success "Models directory exists: $MODELS_DIR"

        # List GGUF files
        GGUF_COUNT=$(find "$MODELS_DIR" -name "*.gguf" 2>/dev/null | wc -l)
        if [ "$GGUF_COUNT" -gt 0 ]; then
            echo_success "Found $GGUF_COUNT GGUF model(s)"
            find "$MODELS_DIR" -name "*.gguf" -printf "  %f\n" 2>/dev/null | head -5
            if [ "$GGUF_COUNT" -gt 5 ]; then
                echo "  ... and $((GGUF_COUNT - 5)) more"
            fi
        else
            echo_warning "No GGUF models found in $MODELS_DIR"
            echo_info "Download with: ./models/download-qwen.sh"
        fi
    else
        echo_warning "Models directory not found: $MODELS_DIR"
        echo_info "Will be created when downloading models"
    fi

    echo ""
}

# Check network connectivity
check_network() {
    echo_info "Checking network connectivity for model downloads..."

    if ping -c 1 8.8.8.8 &> /dev/null; then
        echo_success "Internet connectivity available"
    else
        echo_warning "No internet connectivity detected"
        echo_info "Internet required for model downloads"
    fi

    # Check if HuggingFace is reachable
    if command -v curl &> /dev/null; then
        if curl -s --connect-timeout 5 https://huggingface.co > /dev/null; then
            echo_success "HuggingFace repository accessible"
        else
            echo_warning "Cannot reach HuggingFace repository"
        fi
    fi

    echo ""
}

# Generate recommendations
generate_recommendations() {
    echo_info "Generating recommendations..."

    if [ $ISSUES -eq 0 ]; then
        echo_success "System is ready for local LLM setup! <�"
        echo ""
        echo_info "Quick start:"
        echo "  1. Download a model: ./models/download-qwen.sh"
        echo "  2. Start the server: ./scripts/start.sh llama-cpp"
        echo "  3. Configure Claude Code with:"
        echo "     export OPENAI_API_BASE=http://localhost:8000/v1"
        echo "     export OPENAI_API_KEY=sk-local"
    else
        echo_warning "Found $ISSUES issue(s) that should be addressed"
        echo ""
        echo_info "Common fixes:"
        echo "  • Install NVIDIA/CUDA: ./distros/omarchy/install.sh"
        echo "  • Install llama.cpp: ./engines/llama-cpp/install.sh"
        echo "  • Download models: ./models/download-qwen.sh"
    fi

    echo ""
}

# Main execution
main() {
    print_header
    check_distribution
    check_system_specs
    check_nvidia
    check_llama_cpp
    check_config
    check_models
    check_network
    generate_recommendations
}

# Run the doctor
main "$@"