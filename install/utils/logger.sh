#!/bin/bash

# Logging utility functions
# Provides colored output for different types of messages:
# - Regular logs (green)
# - Warnings (yellow)
# - Errors (red)
#
# Usage:
# log "Regular message"
# warning "Warning message"
# error "Error message"
# check_error "Error description"

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Regular logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

# Error logging function
error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
}

# Warning logging function
warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

# Error checking function
check_error() {
    if [ $? -ne 0 ]; then
        error "$1"
        exit 1
    fi
}