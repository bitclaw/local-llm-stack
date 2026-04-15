#!/bin/bash

# Local LLM Stack - Package Installation
# Installs base dependencies needed for local LLM setup

set -e

echo "🔧 Installing base dependencies for local LLM stack..."

# Check for omarchy
if compgen -c | grep -q '^omarchy-'; then
    echo "✅ Omarchy detected"
fi

# Check if essential tools are already available
echo "🔍 Checking for required tools..."

MISSING=()

for tool in git cmake python pip curl; do
    if command -v $tool &> /dev/null; then
        echo "✅ $tool found"
    else
        MISSING+=($tool)
    fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "📦 Installing missing tools: ${MISSING[*]}"
    sudo pacman -S --noconfirm "${MISSING[@]}"
fi

echo "✅ Base dependencies ready!"
echo "Next: Run ./distros/omarchy/install.sh"