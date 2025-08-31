#!/bin/bash

VPN_NAME="vpn"

# Check if VPN is active
is_vpn_active() {
    sudo wg show "$VPN_NAME" >/dev/null 2>&1
}

# Get current VPN status with icon
get_vpn_status() {
    if is_vpn_active; then
        echo "󰖂 VPN"
    else
        echo "󰖑 VPN"
    fi
}

# Toggle VPN connection
toggle_vpn() {
    if is_vpn_active; then
        if sudo wg-quick down "$VPN_NAME" 2>/dev/null; then
            notify-send -u normal "VPN Disconnected" "WireGuard interface down"
        else
            notify-send -u critical "VPN Error" "Failed to disconnect"
        fi
    else
        if sudo wg-quick up "$VPN_NAME" 2>/dev/null; then
            notify-send -u normal "VPN Connected" "WireGuard interface up"
        else
            notify-send -u critical "VPN Error" "Failed to connect"
        fi
    fi
}

case "$1" in
    --toggle)
        toggle_vpn
        ;;
    *)
        get_vpn_status
        ;;
esac