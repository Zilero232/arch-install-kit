#!/bin/bash

#==============================================================================
# Shows WireGuard VPN connection status with icon and label
#==============================================================================

VPN_NAME="vpn"

# Icon Configuration (Using Nerd Fonts)
declare -A ICONS=(
    [CONNECTED]="󰖂"    # VPN connected
    [DISCONNECTED]="󰖑" # VPN disconnected
)

# Colors (Catppuccin Theme)
declare -A COLORS=(
    [CONNECTED]="#89dceb"     # Teal
    [DISCONNECTED]="#45475a"  # Surface0
    [TEXT]="#cdd6f4"         # Text color for "VPN" label
)

# Format output with color
format_output() {
    local icon="$1"
    local color="$2"
    echo "%{F$color}$icon%{F${COLORS[TEXT]}} VPN%{F-}"
}

# Check if VPN is active
is_vpn_active() {
    sudo wg show "$VPN_NAME" >/dev/null 2>&1
}

# Get current VPN status and format output
get_vpn_status() {
    if is_vpn_active; then
        format_output "${ICONS[CONNECTED]}" "${COLORS[CONNECTED]}"
    else
        format_output "${ICONS[DISCONNECTED]}" "${COLORS[DISCONNECTED]}"
    fi
}

# Toggle VPN connection
toggle_vpn() {
    if is_vpn_active; then
        if sudo wg-quick down "$VPN_NAME" 2>/dev/null; then
            notify-send -u normal "VPN Disconnected" "WireGuard interface down" -i dialog-error
        else
            notify-send -u critical "VPN Error" "Failed to disconnect" -i dialog-error
        fi
    else
        if sudo wg-quick up "$VPN_NAME" 2>/dev/null; then
            notify-send -u normal "VPN Connected" "WireGuard interface up" -i dialog-information
        else
            notify-send -u critical "VPN Error" "Failed to connect" -i dialog-error
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