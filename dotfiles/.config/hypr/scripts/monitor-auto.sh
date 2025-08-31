#!/bin/bash

# Function to apply monitor configuration
apply_monitor_config() {
    if is_dp1_connected; then
        # External monitor connected - set both to same resolution with mirroring
        hyprctl keyword monitor "eDP-1, 2560x1440@120, 0x0, 1"
        hyprctl keyword monitor "DP-1, 2560x1440@165, 0x0, 1, mirror, eDP-1"
    else
        # No external monitor - enable laptop screen with specified resolution
        hyprctl keyword monitor "eDP-1, 2560x1600@120,0x0,1"
        hyprctl keyword monitor "DP-1, disable"
    fi
}

# Function to check if DP-1 is physically connected
is_dp1_connected() {
    for status_file in /sys/class/drm/card*/card*-DP-1/status; do
        if [ -f "$status_file" ]; then
            if grep -q "^connected" "$status_file" 2>/dev/null; then
                return 0  # found connected DP-1
            fi
        fi
    done

    return 1  # not found or not connected
}

# Monitor loop - check every 5 seconds
while true; do
    if is_dp1_connected; then
        current_state=0
    else
        current_state=1
    fi

    if [ "$current_state" != "$previous_state" ]; then
        apply_monitor_config

        previous_state=$current_state
    fi

    sleep 5
done