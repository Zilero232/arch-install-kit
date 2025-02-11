#!/bin/bash

#==============================================================================
# Shows WiFi connection status with dynamic icon and network name
#==============================================================================

# Icon Configuration (Using Nerd Fonts)
declare -A ICONS=(
    [SIGNAL_0]="󰤯"    # 0-20%
    [SIGNAL_1]="󰤟"    # 20-40%
    [SIGNAL_2]="󰤢"    # 40-60%
    [SIGNAL_3]="󰤥"    # 60-80%
    [SIGNAL_4]="󰤨"    # 80-100%
    [WIFI_OFF]="󰖪"    # WiFi disabled
    [WIFI_NONE]="󰤭"   # No connection
)

# Colors (Catppuccin Theme)
declare -A COLORS=(
    [CONNECTED]="#89dceb"    # Teal
    [DISCONNECTED]="#45475a" # Surface0
    [TEXT]="#cdd6f4"         # Text
)

# Format output with color
format_output() {
    local icon="$1"
    local text="$2"
    local color="$3"
    echo "%{F$color}$icon%{F${COLORS[TEXT]}} $text%{F-}"
}

# Get WiFi signal strength (0-100)
get_signal_strength() {
    awk 'NR==3 {print int($3 * 100 / 70)}' /proc/net/wireless 2>/dev/null
}

# Get signal icon based on strength
get_signal_icon() {
    local signal="$1"
    local icon_index=$(( signal / 20 ))
    [[ $icon_index -gt 4 ]] && icon_index=4

    echo "${ICONS[SIGNAL_$icon_index]}"
}

# Get current WiFi status and format output
get_wifi_status() {
    # Check if WiFi is enabled
    if ! nmcli radio wifi | grep -q "enabled"; then
        format_output "${ICONS[WIFI_OFF]}" "disabled" "${COLORS[DISCONNECTED]}"

        return
    fi

    # Check connection state
    if [[ "$(cat /sys/class/net/wlan0/operstate 2>/dev/null)" = "up" ]]; then
        local signal=$(get_signal_strength)
        local icon=$(get_signal_icon "$signal")
        local ssid=$(iwgetid -r)

        format_output "$icon" "$ssid" "${COLORS[CONNECTED]}"
    else
        format_output "${ICONS[WIFI_NONE]}" "disconnected" "${COLORS[DISCONNECTED]}"
    fi
}

# Toggle WiFi state
toggle_wifi() {
    if nmcli radio wifi | grep -q "enabled"; then
        nmcli radio wifi off

        notify-send -u normal "WiFi" "Disabled" -i network-wireless-offline
    else
        nmcli radio wifi on

        notify-send -u normal "WiFi" "Enabled" -i network-wireless
    fi
}

# Main logic
case "$1" in
    --toggle)
        toggle_wifi
        ;;
    *)
        get_wifi_status
        ;;
esac