#!/bin/bash

# Configuration setup module
# Handles copying and setting up all configuration files
# 
# Functions:
# - setup_config: Main configuration setup
# - backup_existing_config: Backup existing configurations
# - copy_config_files: Copy configuration files
# - set_permissions: Set correct permissions
# - setup_shell: Configure shell settings

setup_config() {
    log "Setting up configurations..."
    
    # Backup existing configurations
    backup_existing_config
    
    # Create necessary directories
    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/.local/bin"
    
    # Copy configuration files
    copy_config_files
    
    # Set correct permissions
    set_permissions
    
    # Setup shell
    setup_shell
    
    log "Configuration setup completed!"
}

backup_existing_config() {
    log "Backing up existing configurations..."
    
    local backup_dir="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
    
    if [ -d "$HOME/.config" ]; then
        mkdir -p "$backup_dir"
        cp -r "$HOME/.config" "$backup_dir/"
        log "Existing configurations backed up to $backup_dir"
    fi
}

copy_config_files() {
    log "Copying configuration files..."
    
    # Copy .config directory
    if [ -d "configs/.config" ]; then
        cp -r configs/.config/* "$HOME/.config/"
        check_error "Failed to copy .config files"
    fi
    
    # Copy bin directory
    if [ -d "configs/bin" ]; then
        cp -r configs/bin/* "$HOME/.local/bin/"
        check_error "Failed to copy bin files"
    fi
    
    # Create symlink for terminal
    sudo ln -sf /usr/bin/alacritty /usr/bin/xterm
    check_error "Failed to create terminal symlink"
}

set_permissions() {
    log "Setting file permissions..."
    
    # Set .config permissions
    chmod -R 700 "$HOME/.config/"
    check_error "Failed to set .config permissions"
    
    # Set bin permissions
    chmod -R 755 "$HOME/.local/bin/"
    check_error "Failed to set bin permissions"
}

setup_shell() {
    log "Setting up shell configuration..."
    
    # Make fish the default shell
    if command -v fish >/dev/null 2>&1; then
        chsh -s "$(which fish)"
        check_error "Failed to set fish as default shell"
        
        # Install fisher (plugin manager for fish)
        if [ ! -f "$HOME/.config/fish/functions/fisher.fish" ]; then
            curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
            check_error "Failed to install fisher"
        fi
    else
        warning "Fish shell is not installed"
    fi
}