#!/bin/bash

# Local LLM Stack - Distribution Detection
# Detects the Linux distribution for appropriate installation scripts

# Check for Arch Linux and derivatives
if [ -f /etc/arch-release ]; then
    echo "arch"
    exit 0
fi

# Check for Manjaro (Arch-based)
if [ -f /etc/manjaro-release ]; then
    echo "arch"
    exit 0
fi

# Check for EndeavourOS (Arch-based)
if [ -f /etc/endeavouros-release ]; then
    echo "arch"
    exit 0
fi

# Check for ArcoLinux (Arch-based)
if [ -f /etc/arcolinux-release ]; then
    echo "arch"
    exit 0
fi

# Check for Debian-based distributions
if [ -f /etc/debian_version ]; then
    echo "debian"
    exit 0
fi

# Check for Ubuntu (Debian-based)
if [ -f /etc/lsb-release ] && grep -q "Ubuntu" /etc/lsb-release; then
    echo "ubuntu"
    exit 0
fi

# Check for Fedora
if [ -f /etc/fedora-release ]; then
    echo "fedora"
    exit 0
fi

# Check for Red Hat Enterprise Linux
if [ -f /etc/redhat-release ]; then
    echo "rhel"
    exit 0
fi

# Check for openSUSE
if [ -f /etc/os-release ] && grep -q "openSUSE" /etc/os-release; then
    echo "opensuse"
    exit 0
fi

# If no specific distribution detected, try to parse /etc/os-release
if [ -f /etc/os-release ]; then
    source /etc/os-release
    case "$ID" in
        arch|manjaro|endeavouros|arcolinux)
            echo "arch"
            ;;
        ubuntu|debian)
            echo "debian"
            ;;
        fedora)
            echo "fedora"
            ;;
        rhel|centos|rocky|almalinux)
            echo "rhel"
            ;;
        opensuse*|sles)
            echo "opensuse"
            ;;
        *)
            echo "unknown"
            ;;
    esac
else
    echo "unknown"
fi