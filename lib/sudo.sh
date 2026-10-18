#!/usr/bin/env bash
# Root guard and sudo keepalive for long installs.

require_not_root() {
    if ((EUID == 0)); then
        die "Run as your user, not root: sudo is used where needed"
    fi
}

# Asks for the password once and refreshes the sudo timestamp until the installer exits
sudo_keepalive() {
    if ! sudo -v; then
        die "sudo is required"
    fi

    while true; do
        sudo -n true
        sleep 50
    done 2>/dev/null &
    SUDO_KEEPALIVE_PID=$!

    trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null' EXIT
    # Ctrl+C must stop the installer: a trap that only cleans up would let it go on to the next module
    trap 'exit 130' INT TERM
}
