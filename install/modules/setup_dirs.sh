#!/bin/bash

# Directory setup module
# Creates the directory structure defined in config/directories.sh
# 
# Functions:
# - setup_directories: Creates all required directories
# - check_permissions: Verifies directory permissions
# - backup_existing: Backs up existing directories

setup_directories() {
    log "Creating directories..."
    
    for dir in "${ALL_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            warning "Directory already exists: $dir"
        else
            mkdir -p "$dir"
            check_error "Failed to create directory: $dir"
        fi
    done

    # Set specific permissions
    chmod -R 700 "$HOME/.config/"
    check_error "Failed to set permissions for .config"
}