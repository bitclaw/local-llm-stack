#!/bin/bash

# Local LLM Stack - llama.cpp Installation with CUDA
# Builds llama.cpp with CUDA support for optimal GPU performance

set -e

LLAMA_CPP_DIR="$HOME/llama.cpp"

echo ">™ Installing llama.cpp with CUDA support..."

# Check if CUDA is available
if ! command -v nvcc &> /dev/null; then
    echo "L CUDA not found. Please run ./distros/arch/install.sh first"
    exit 1
fi

echo " CUDA found: $(nvcc --version | grep release | cut -d' ' -f5-6)"

# Remove existing installation if it exists
if [ -d "$LLAMA_CPP_DIR" ]; then
    echo "=Ñ  Removing existing llama.cpp installation..."
    rm -rf "$LLAMA_CPP_DIR"
fi

# Clone llama.cpp repository
echo "=å Cloning llama.cpp repository..."
git clone https://github.com/ggerganov/llama.cpp "$LLAMA_CPP_DIR"
cd "$LLAMA_CPP_DIR"

# Build with CUDA support
echo "=( Building llama.cpp with CUDA support (this may take a few minutes)..."
mkdir -p build
cd build

# Configure with CUDA
cmake -DGGML_CUDA=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DGGML_CUDA_FORCE_DMMV=ON \
      -DGGML_CUDA_FORCE_MMQ=ON \
      ..

# Build (use all available cores)
make -j$(nproc)

echo "= Verifying installation..."
if [ -f "./bin/llama-server" ]; then
    echo " llama.cpp built successfully!"
    echo "Server binary: $LLAMA_CPP_DIR/build/bin/llama-server"

    # Test CUDA support
    echo ">ê Testing CUDA support..."
    if ./bin/llama-server --help | grep -q "gpu-layers"; then
        echo " CUDA support confirmed - GPU layers option available"
    else
        echo "   Warning: GPU layers option not found in help output"
    fi
else
    echo "L Build failed - server binary not found"
    exit 1
fi

# Create symlink for easier access
echo "= Creating convenient symlink..."
sudo ln -sf "$LLAMA_CPP_DIR/build/bin/llama-server" /usr/local/bin/llama-server

echo ""
echo " llama.cpp installation complete!"
echo ""
echo "Binary location: $LLAMA_CPP_DIR/build/bin/llama-server"
echo "Symlink created: /usr/local/bin/llama-server"
echo ""
echo "Next: Download a model with ./models/download-qwen.sh"