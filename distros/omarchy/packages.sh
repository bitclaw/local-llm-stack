#!/bin/bash

# Local LLM Stack - Omarchy Package Installation
# Installs base dependencies needed for local LLM setup

set -e

echo "🔧 Installing base dependencies for local LLM stack..."

# Check if we're on Omarchy
if ! command -v omarchy &> /dev/null; then
    echo "❌ This script is designed specifically for Omarchy"
    echo "Omarchy command not found in system PATH"
    exit 1
fi

echo "✅ Omarchy detected"
echo ""
echo "🔍 IMPORTANT: Package Installation on Omarchy"
echo "============================================="
echo ""
echo "For Omarchy systems, packages should be installed through:"
echo "1. Omarchy system updates (Super + Alt + Space → Update → Omarchy)"
echo "2. Omarchy Store for additional packages"
echo ""
echo "⚠️  Avoid direct pacman usage on Omarchy to prevent system issues."
echo ""

# Check if essential tools are already available
echo "🔍 Checking for required tools..."

MISSING_TOOLS=()

if ! command -v git &> /dev/null; then
    MISSING_TOOLS+=("git")
else
    echo "✅ git found"
fi

if ! command -v cmake &> /dev/null; then
    MISSING_TOOLS+=("cmake")
else
    echo "✅ cmake found"
fi

if ! command -v python &> /dev/null; then
    MISSING_TOOLS+=("python")
else
    echo "✅ python found"
fi

if ! command -v pip &> /dev/null; then
    MISSING_TOOLS+=("python-pip")
else
    echo "✅ pip found"
fi

if ! command -v wget &> /dev/null; then
    MISSING_TOOLS+=("wget")
else
    echo "✅ wget found"
fi

if ! command -v curl &> /dev/null; then
    MISSING_TOOLS+=("curl")
else
    echo "✅ curl found"
fi

if [ ${#MISSING_TOOLS[@]} -eq 0 ]; then
    echo ""
    echo "🎉 All required tools are already installed!"
    echo ""

    # Install Python packages
    echo "🐍 Installing Python dependencies..."
    pip install --user --upgrade pip
    pip install --user requests tqdm

    echo "✅ Base dependencies ready!"
    echo "Next: Run ./distros/omarchy/install.sh to install NVIDIA drivers and CUDA"
else
    echo ""
    echo "📦 Missing tools detected: ${MISSING_TOOLS[*]}"
    echo ""
    echo "Please install these via Omarchy Store:"
    echo "1. Super + Alt + Space → Store"
    echo "2. Search and install: ${MISSING_TOOLS[*]}"
    echo ""
    read -p "Press Enter after installing missing packages..."
    echo ""
    echo "✅ Dependencies should now be ready!"
fi

echo "Next: Run ./distros/omarchy/install.sh to install NVIDIA drivers and CUDA"