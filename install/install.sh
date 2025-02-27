#!/bin/bash

# Main installation script for Arch Linux system setup
# This script orchestrates the entire installation process by:
# - Loading all required modules and configurations
# - Performing system checks
# - Installing packages
# - Setting up configurations
# - Enabling services
#
# Usage: ./install.sh
# Requirements: 
# - Fresh Arch Linux installation
# - Internet connection
# - Sudo privileges

set -euo pipefail
IFS=$'\n\t'

# Load utilities
source "utils/logger.sh"
source "utils/checks.sh"

# Load configurations
source "config/packages.sh"
source "config/directories.sh"
source "config/services.sh"

# Load modules
source "modules/setup_dirs.sh"
source "modules/install_pkgs.sh"
source "modules/setup_config.sh"
source "modules/setup_services.sh"

main() {
    log "Starting installation process..."
    
    check_root
    check_dependencies
    
    setup_directories
    install_official_packages
    install_aur_packages
    setup_services
    setup_config
    
    log "Installation completed successfully!"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    trap 'error "Installation failed! See above for details."' ERR
    main "$@"
fi