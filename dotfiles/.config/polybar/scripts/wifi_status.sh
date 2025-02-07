#!/bin/bash

#==============================================================================
# Network Status Script for Polybar
# 
# Description:
#   Displays WiFi connection status with:
#   - Network SSID
#   - Connection security status
#   - Signal strength indicator
#   - Dynamic icons based on signal level
#
# Author: Your Name
# Last Modified: 2024-02-02
#==============================================================================

#------------------------------------------------------------------------------
# Environment Check
#------------------------------------------------------------------------------

# Check for required commands
for cmd in nmcli iwgetid awk grep; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: Required command '$cmd' not found"

        exit 1
    fi
done


#------------------------------------------------------------------------------
# Configuration Variables
#------------------------------------------------------------------------------

# Network Interface Settings
INTERFACE="${NETWORK_INTERFACE:-wlan0}"

# Icon Configuration
declare -A ICONS=(
    # WiFi Signal Strength Icons
    [SIGNAL_0]="󰤯"    # 0-20%
    [SIGNAL_1]="󰤟"    # 20-40%
    [SIGNAL_2]="󰤢"    # 40-60%
    [SIGNAL_3]="󰤥"    # 60-80%
    [SIGNAL_4]="󰤨"    # 80-100%
    
    # Status Icons
    [WIFI_OFF]="󰖪"    # WiFi disabled
    [WIFI_NONE]="󰤭"   # No connection
    [LOCK]="󰌾"        # Secure network
    [SEPARATOR]="│"   # Element separator
)

# Color Configuration (Catppuccin Theme)
declare -A COLORS=(
    [CONNECTED]="#89dceb"    # Teal
    [DISCONNECTED]="#45475a" # Surface0
    [ALERT]="#f38ba8"        # Red
    [TEXT]="#cdd6f4"         # Text
    [SEPARATOR]="#6c7086"    # Overlay0
)


#------------------------------------------------------------------------------
# Helper Functions
#------------------------------------------------------------------------------

# Format output with colors and icons
# Usage: format_output "icon" "text" "color"
format_output() {
    local icon="$1"
    local text="$2"
    local icon_color="$3"

    echo "%{F$icon_color}$icon%{F${COLORS[TEXT]}} $text%{F-}"
}


# Add separator between elements
# Usage: add_separator "text"
add_separator() {
    local text="$1"

    echo " %{F${COLORS[SEPARATOR]}}${ICONS[SEPARATOR]}%{F-} $text"
}


# Get WiFi signal strength
# Usage: get_signal_strength
get_signal_strength() {
    awk 'NR==3 {print int($3 * 100 / 70)}' /proc/net/wireless 2>/dev/null
}


# Get signal icon based on strength
# Usage: get_signal_icon "strength_percentage"
get_signal_icon() {
    local signal="$1"
    local icon_index=$(( signal / 20 ))
    
    [[ $icon_index -gt 4 ]] && icon_index=4
    
    echo "${ICONS[SIGNAL_$icon_index]}"
}


#------------------------------------------------------------------------------
# Network Status Functions
#------------------------------------------------------------------------------

# Get current WiFi status and format output
get_wifi_status() {
    # Check if WiFi is enabled
    if ! nmcli radio wifi | grep -q "enabled"; then
        format_output "${ICONS[WIFI_OFF]}" "disabled" "${COLORS[DISCONNECTED]}"
				
        return
    fi

    # Check connection state
    if [[ "$(cat /sys/class/net/$INTERFACE/operstate 2>/dev/null)" = "up" ]]; then
        # Get network information
        local signal=$(get_signal_strength)
        local essid=$(iwgetid -r)
        local secure=$(iwgetid -p | grep -q "WPA\|WEP" && echo "true" || echo "false")
        
        # Get appropriate signal icon
        local icon=$(get_signal_icon "$signal")
        
        # Build status text
        local status_text="$essid"
        
        # Add security indicator if network is secure
        if [[ "$secure" == "true" ]]; then
            status_text="$status_text %{F${COLORS[CONNECTED]}}${ICONS[LOCK]}%{F-}"
        fi

        # Add signal strength with separator
        status_text="${status_text}$(add_separator "%{F${COLORS[CONNECTED]}}${signal}%%{F-}")"
        
        format_output "$icon" "$status_text" "${COLORS[CONNECTED]}"
    else
        format_output "${ICONS[WIFI_NONE]}" "disconnected" "${COLORS[DISCONNECTED]}"
    fi
}


# Toggle WiFi state and show notification
toggle_wifi() {
    if nmcli radio wifi | grep -q "enabled"; then
        nmcli radio wifi off

        notify-send -u normal \
            "WiFi" \
            "Disabled" \
            -i network-wireless-offline
    else
        nmcli radio wifi on

        notify-send -u normal \
            "WiFi" \
            "Enabled" \
            -i network-wireless
    fi
}


#------------------------------------------------------------------------------
# Main Script Logic
#------------------------------------------------------------------------------

main() {
    case "$1" in
        --toggle)
            toggle_wifi
            ;;
        *)
            get_wifi_status
            ;;
    esac
}


# Execute main function
main "$@"