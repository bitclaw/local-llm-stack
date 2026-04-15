#!/bin/bash

# Local LLM Stack - Omarchy NVIDIA/CUDA Installation
# Omarchy-safe installation of NVIDIA drivers and CUDA toolkit

set -e

echo "🚀 Omarchy-safe NVIDIA/CUDA installation for Local LLM Stack..."

# Check if we're running on Omarchy
if ! command -v omarchy &> /dev/null; then
    echo "❌ This script is designed specifically for Omarchy"
    echo "Omarchy command not found in system PATH"
    exit 1
fi

echo "✅ Omarchy detected - using safe installation method"

echo ""
echo "🔍 IMPORTANT: Omarchy System Update Required"
echo "=============================================="
echo ""
echo "For Omarchy systems, NVIDIA drivers and CUDA must be installed through"
echo "the official Omarchy update system to prevent kernel compatibility issues."
echo ""
echo "📋 Required steps:"
echo ""
echo "1. 🔄 Update Omarchy first:"
echo "   Super + Alt + Space → 'Update' → 'Omarchy'"
echo "   OR click the circular arrow icon next to your clock"
echo ""
echo "2. 📦 Install NVIDIA drivers via Omarchy package manager:"
echo "   Super + Alt + Space → 'Store' → Search for 'nvidia'"
echo "   Install: nvidia, nvidia-utils, cuda, cudnn"
echo ""
echo "3. 🔄 Reboot your system"
echo ""
echo "4. ✅ Verify installation:"
echo "   nvidia-smi"
echo ""

echo "⚠️  WARNING: Do NOT run 'pacman -S' commands directly on Omarchy!"
echo "   This can break your system and require kernel recompilation."
echo ""
echo "🛡️  Omarchy's update system ensures kernel compatibility and"
echo "   proper driver integration."
echo ""

# Check if NVIDIA is already installed
if command -v nvidia-smi &> /dev/null; then
    echo "✅ NVIDIA drivers already detected!"
    echo ""
    echo "📊 Current GPU Information:"
    nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader,nounits
    echo ""

    # Check CUDA
    if command -v nvcc &> /dev/null; then
        CUDA_VERSION=$(nvcc --version | grep release | sed 's/.*release \([0-9.]*\).*/\1/')
        echo "✅ CUDA toolkit found: v$CUDA_VERSION"
        echo ""
        echo "🎉 System appears ready for Local LLM Stack!"
        echo "Next: Run ./engines/llama-cpp/install.sh"
        exit 0
    else
        echo "⚠️  CUDA toolkit not found. Please install via Omarchy Store."
    fi
else
    echo "❌ NVIDIA drivers not found"
    echo ""
fi

# Interactive helper for Omarchy users
echo "🤖 Would you like me to guide you through the installation?"
read -p "Continue with guided setup? (y/N): " confirm

if [[ $confirm =~ ^[Yy]$ ]]; then
    echo ""
    echo "📋 Step-by-step guide:"
    echo ""
    echo "1. Press Super + Alt + Space to open Omarchy menu"
    echo "2. Type 'Update' and press Enter"
    echo "3. Click 'Omarchy' to update your system"
    echo "4. Wait for update to complete"
    echo ""
    read -p "Press Enter when update is complete..."
    echo ""
    echo "5. Press Super + Alt + Space again"
    echo "6. Type 'Store' and press Enter"
    echo "7. Search for 'nvidia' and install:"
    echo "   - nvidia"
    echo "   - nvidia-utils"
    echo "   - cuda"
    echo "   - cudnn"
    echo ""
    read -p "Press Enter when packages are installed..."
    echo ""
    echo "8. Reboot your system now"
    echo ""
    read -p "Press Enter after reboot to verify installation..."

    # Verify installation
    if command -v nvidia-smi &> /dev/null; then
        echo "✅ Installation successful!"
        nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader,nounits
        echo ""
        echo "🎉 Ready for Local LLM Stack!"
        echo "Next: Run ./engines/llama-cpp/install.sh"
    else
        echo "❌ Installation verification failed"
        echo "Please try the installation process again"
        exit 1
    fi
else
    echo ""
    echo "💡 Manual installation summary:"
    echo "1. Update Omarchy system"
    echo "2. Install nvidia, nvidia-utils, cuda, cudnn via Omarchy Store"
    echo "3. Reboot"
    echo "4. Run this script again to verify"
fi

echo ""
echo "📚 Resources:"
echo "- Omarchy Manual: https://omarchy.com/manual"
echo "- NVIDIA Documentation: https://wiki.archlinux.org/title/NVIDIA"