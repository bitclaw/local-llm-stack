#!/bin/bash

# Local LLM Stack - Arch Linux Package Installation
# Installs base dependencies needed for local LLM setup

set -e

echo "=' Installing base dependencies for local LLM stack..."

# Update system packages
echo "=æ Updating system packages..."
sudo pacman -Syu --noconfirm

# Install base development tools
echo "=à  Installing base development tools..."
sudo pacman -S --noconfirm \
    git \
    base-devel \
    cmake \
    python \
    python-pip \
    wget \
    curl

# Install Python packages
echo "= Installing Python dependencies..."
pip install --user --upgrade pip
pip install --user requests tqdm

# Install optional but recommended packages
echo "=Ê Installing recommended tools..."
sudo pacman -S --noconfirm \
    htop \
    nvtop \
    tree \
    unzip

echo " Base dependencies installed successfully!"
echo "Next: Run ./distros/arch/install.sh to install NVIDIA drivers and CUDA"