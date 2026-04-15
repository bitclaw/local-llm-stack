#!/bin/bash

# Local LLM Stack - NVIDIA/CUDA Installation
# Installs NVIDIA drivers and CUDA toolkit via pacman

set -e

echo "🚀 NVIDIA/CUDA installation for Local LLM Stack..."

# Check for omarchy commands
if compgen -c | grep -q '^omarchy-'; then
    echo "✅ Omarchy detected"
fi

# Add CUDA to PATH if installed
if [ -d /opt/cuda/bin ]; then
    export PATH="/opt/cuda/bin:$PATH"
fi

# Check NVIDIA drivers
if command -v nvidia-smi &> /dev/null; then
    echo "✅ NVIDIA drivers installed"
    nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader,nounits
else
    echo "❌ NVIDIA drivers not found, installing..."
    sudo pacman -S --noconfirm nvidia nvidia-utils
fi

# Check CUDA
if command -v nvcc &> /dev/null; then
    CUDA_VERSION=$(nvcc --version | grep release | sed 's/.*release \([0-9.]*\).*/\1/')
    echo "✅ CUDA $CUDA_VERSION installed"
elif [ -x /opt/cuda/bin/nvcc ]; then
    echo "✅ CUDA installed at /opt/cuda/bin (added to PATH)"
else
    echo "❌ CUDA not found, installing..."
    sudo pacman -S --noconfirm cuda
fi

echo ""
echo "🎉 Ready for Local LLM Stack!"
echo "Next: Run ./engines/llama-cpp/install.sh"