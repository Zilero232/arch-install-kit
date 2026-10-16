#!/usr/bin/env bash
# Root guard and sudo keepalive for long installs.

require_not_root() {
    [[ "$EUID" -ne 0 ]] || die "Run as your user, not root: sudo is used where needed"
}

# Asks for the password once and refreshes the sudo timestamp until the installer exits
sudo_keepalive() {
    sudo -v || die "sudo is required"
    while true; do
        sudo -n true
        sleep 50
    done 2>/dev/null &
    SUDO_KEEPALIVE_PID=$!
    trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null' EXIT INT TERM
}
