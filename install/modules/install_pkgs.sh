#!/bin/bash

# Package installation module
# Handles installation of official, AUR and VPN-required packages
# 
# Functions:
# - install_official_packages: Installs packages from official repos
# - install_aur_packages: Installs AUR packages
# - install_vpn_packages: Installs packages requiring VPN
# - install_yay: Installs AUR helper
# - check_installed: Verifies package installation
# 
# Note: VPN packages installation is optional and can be skipped

# Install official packages from repositories
install_official_packages() {
    log "Installing official packages..."
    
    # Update system first
    sudo pacman -Syu --noconfirm
    check_error "System update failed"

    # Install packages
    sudo pacman -S --needed --noconfirm "${ALL_OFFICIAL_PACKAGES[@]}"
    check_error "Package installation failed"

    # Verify installation
    check_installed "${ALL_OFFICIAL_PACKAGES[@]}"
}

# Install AUR packages
install_aur_packages() {
    log "Installing AUR packages..."
    
    # Install yay if not present
    if ! command -v yay >/dev/null 2>&1; then
        install_yay
    fi

    # Install each AUR package
    for pkg in "${AUR_PACKAGES[@]}"; do
        if ! check_if_installed "$pkg"; then
            log "Installing AUR package: $pkg"
            yay -S --noconfirm "$pkg"
            check_error "Failed to install AUR package: $pkg"
        else
            log "Package $pkg is already installed"
        fi
    done
}

# Install packages requiring VPN
install_vpn_packages() {
    log "Checking for VPN packages installation..."
    
    # Ask user if they want to install VPN packages
    read -p "Do you want to install packages requiring VPN? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        warning "Skipping VPN packages installation"
        return
    fi

    # Check if yay is installed
    if ! command -v yay >/dev/null 2>&1; then
        install_yay
    fi

    # Install each VPN package
    for pkg in "${VPN_PACKAGES[@]}"; do
        if ! check_if_installed "$pkg"; then
            log "Installing VPN package: $pkg"
            yay -S --noconfirm "$pkg"
            check_error "Failed to install VPN package: $pkg"
        else
            log "Package $pkg is already installed"
        fi
    done
}

# Install yay AUR helper
install_yay() {
    log "Installing yay AUR helper..."
    
    # Create temporary directory
    local tmp_dir
    tmp_dir=$(mktemp -d)
    check_error "Failed to create temporary directory"
    
    # Clone and build yay
    git clone https://aur.archlinux.org/yay.git "$tmp_dir/yay"
    check_error "Failed to clone yay repository"
    
    (cd "$tmp_dir/yay" && makepkg -si --noconfirm)
    check_error "Failed to install yay"
    
    # Cleanup
    rm -rf "$tmp_dir"
}

# Check if a package is installed
check_if_installed() {
    local pkg=$1
    pacman -Qi "$pkg" &>/dev/null
}

# Check if multiple packages are installed
check_installed() {
    local missing_pkgs=()
    
    for pkg in "$@"; do
        if ! check_if_installed "$pkg"; then
            missing_pkgs+=("$pkg")
        fi
    done
    
    if [ ${#missing_pkgs[@]} -ne 0 ]; then
        error "Following packages failed to install:"
        printf '%s\n' "${missing_pkgs[@]}"
        exit 1
    fi
}

# Install optional packages
install_optional_packages() {
    log "Checking for optional packages installation..."
    
    # Ask user if they want to install optional packages
    read -p "Do you want to install optional packages? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        warning "Skipping optional packages installation"
        return
    fi

    # Install optional packages
    for pkg in "${OPTIONAL_PACKAGES[@]}"; do
        if ! check_if_installed "$pkg"; then
            log "Installing optional package: $pkg"
            sudo pacman -S --needed --noconfirm "$pkg"
            check_error "Failed to install optional package: $pkg"
        else
            log "Package $pkg is already installed"
        fi
    done
}

# Update system and refresh package databases
update_system() {
    log "Updating system..."
    
    # Refresh package databases
    sudo pacman -Sy
    check_error "Failed to refresh package databases"
    
    # Update mirrorlist using reflector
    if command -v reflector >/dev/null 2>&1; then
        log "Updating mirrorlist..."
        sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
        check_error "Failed to update mirrorlist"
    fi
}

# Clean package cache
clean_packages() {
    log "Cleaning package cache..."
    
    # Remove unused packages
    sudo pacman -Sc --noconfirm
    check_error "Failed to clean package cache"
    
    if command -v yay >/dev/null 2>&1; then
        yay -Sc --noconfirm
        check_error "Failed to clean AUR package cache"
    fi
}

# Main package installation function
install_all_packages() {
    update_system
    install_official_packages
    install_aur_packages
    install_vpn_packages
    install_optional_packages
    clean_packages
    
    log "All packages installed successfully!"
}