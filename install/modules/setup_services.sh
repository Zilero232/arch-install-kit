#!/bin/bash

# Services setup module
# Handles enabling and starting system services
# 
# Functions:
# - setup_services: Main service setup
# - enable_service: Enable individual service
# - start_service: Start individual service
# - check_service_status: Verify service status

setup_services() {
    log "Setting up system services..."
    
    # Network services
    enable_service "NetworkManager"
    start_service "NetworkManager"
    
    # Bluetooth services
    enable_service "bluetooth"
    start_service "bluetooth"
    
    # Power management
    enable_service "tlp"
    enable_service "cpupower"
    
    # Display manager
    enable_service "sddm"
    
    # Other services
    setup_additional_services
    
    log "Services setup completed!"
}

enable_service() {
    local service=$1
    log "Enabling service: $service"
    
    if ! systemctl is-enabled "$service" &>/dev/null; then
        sudo systemctl enable "$service"
        check_error "Failed to enable $service"
    else
        log "Service $service is already enabled"
    fi
}

start_service() {
    local service=$1
    log "Starting service: $service"
    
    if ! systemctl is-active "$service" &>/dev/null; then
        sudo systemctl start "$service"
        check_error "Failed to start $service"
    else
        log "Service $service is already running"
    fi
}

check_service_status() {
    local service=$1
    
    if ! systemctl is-active "$service" &>/dev/null; then
        error "Service $service is not running"
        return 1
    fi
    
    if ! systemctl is-enabled "$service" &>/dev/null; then
        error "Service $service is not enabled"
        return 1
    fi
    
    return 0
}

setup_additional_services() {
    log "Setting up additional services..."
    
    # Docker (if installed)
    if command -v docker >/dev/null 2>&1; then
        enable_service "docker"
        # Add user to docker group
        sudo usermod -aG docker "$USER"
        check_error "Failed to add user to docker group"
    fi
    
    # CUPS (if installed)
    if command -v cupsd >/dev/null 2>&1; then
        enable_service "cups"
    fi
    
    # SSH (if needed)
    if [ -f "/etc/ssh/sshd_config" ]; then
        enable_service "sshd"
    fi
}

verify_services() {
    log "Verifying service status..."
    
    local services=(
        "NetworkManager"
        "bluetooth"
        "tlp"
        "cpupower"
        "sddm"
    )
    
    local failed=0
    
    for service in "${services[@]}"; do
        if ! check_service_status "$service"; then
            failed=1
        fi
    done
    
    if [ $failed -eq 1 ]; then
        error "Some services failed to start properly"
        return 1
    fi
    
    log "All services are running correctly"
    return 0
}