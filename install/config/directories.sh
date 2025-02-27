#!/bin/bash

# Directory structure configuration
# Defines the directory structure to be created in the user's home
# 
# Categories:
# - Home directories (Documents, Downloads, etc.)
# - Configuration directories (.config, .local)
# - Application-specific directories

# User home directories
HOME_DIRS=(
    "$HOME/Videos"      # Video files
    "$HOME/Documents"   # Documents
    "$HOME/Downloads"   # Downloads
    "$HOME/Music"       # Music files
    "$HOME/Desktop"     # Desktop
    "$HOME/Projects"    # Development projects
    "$HOME/Screenshots" # Screenshots
)

# Configuration directories
CONFIG_DIRS=(
    "$HOME/.config"      # User configurations
    "$HOME/.local/bin"   # User binaries
    "$HOME/.local/share" # User data
)

# All directories combined
ALL_DIRS=(
    "${HOME_DIRS[@]}"
    "${CONFIG_DIRS[@]}"
)