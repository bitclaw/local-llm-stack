#!/bin/bash

# Local LLM Stack - Arch Linux NVIDIA/CUDA Installation
# Installs NVIDIA drivers and CUDA toolkit for GPU acceleration

set -e

echo "=€ Installing NVIDIA drivers and CUDA toolkit..."

# Check if we're running on Arch Linux
if [ ! -f /etc/arch-release ]; then
    echo "L This script is designed for Arch Linux"
    exit 1
fi

# Install base dependencies first
echo "=æ Installing base dependencies..."
if [ -f "./packages.sh" ]; then
    ./packages.sh
elif [ -f "../arch/packages.sh" ]; then
    ../arch/packages.sh
else
    echo "   Warning: packages.sh not found, assuming dependencies are installed"
fi

# Install NVIDIA drivers and CUDA
echo "<® Installing NVIDIA drivers and CUDA..."
sudo pacman -S --noconfirm \
    nvidia \
    nvidia-utils \
    cuda \
    cudnn

echo "= Adding current user to video group..."
sudo usermod -a -G video $USER

echo "=Ë Verifying NVIDIA installation..."
if command -v nvidia-smi &> /dev/null; then
    echo " NVIDIA drivers installed successfully!"
    echo "GPU Information:"
    nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader,nounits
else
    echo "   NVIDIA drivers installed but nvidia-smi not found in PATH"
fi

echo "=' Checking CUDA installation..."
if [ -d "/opt/cuda" ]; then
    echo " CUDA toolkit installed at /opt/cuda"
    echo "CUDA Version: $(cat /opt/cuda/version.json 2>/dev/null || echo 'Version file not found')"
else
    echo "   CUDA installation may be incomplete"
fi

echo ""
echo "= IMPORTANT: A reboot is recommended to ensure proper driver loading"
echo "After reboot, verify with:"
echo "  nvidia-smi"
echo ""
echo " Installation complete!"
echo "Next: Run ./engines/llama-cpp/install.sh to build llama.cpp with CUDA support"