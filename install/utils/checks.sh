#!/bin/bash

# System check utilities
# Provides functions to verify system requirements and dependencies
#
# Functions:
# - check_root: Ensures script is not run as root
# - check_dependencies: Verifies all required tools are installed
# - check_internet: Ensures internet connectivity
# - check_arch: Verifies running on Arch Linux

check_root() {
    if [ "$(id -u)" = 0 ]; then
        error "This script should not be run as root"
        exit 1
    fi
}

check_dependencies() {
    local deps=("git" "sudo" "pacman")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            error "Required dependency not found: $dep"
            exit 1
        fi
    done
}

check_internet() {
    if ! ping -c 1 archlinux.org >/dev/null 2>&1; then
        error "No internet connection"
        exit 1
    fi
}

check_arch() {
    if [ ! -f /etc/arch-release ]; then
        error "This script must be run on Arch Linux"
        exit 1
    fi
}