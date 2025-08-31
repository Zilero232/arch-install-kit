#!/bin/bash

# Configuration
TERMINAL="alacritty -e"
NOTIFY_TIMEOUT=5000

# Notification icons
ICON_UPDATE="󰚰"
ICON_SUCCESS="󰄬"
ICON_ERROR="󰅚"

# Helper function for notifications
notify() {
    local title="$1"
    local message="$2"
    local urgency="$3"
    local icon="$4"

    notify-send "$icon $title" "$message" -u "$urgency" -t $NOTIFY_TIMEOUT
}

# Check for official updates
OFFICIAL=$(checkupdates 2>/dev/null | wc -l)

# Check for AUR updates
AUR=$(yay -Qua 2>/dev/null | wc -l)

# Calculate total updates
TOTAL=$((OFFICIAL + AUR))

if [ "$TOTAL" -gt 0 ]; then
    notify "System Update" "Found updates:\n• Official: $OFFICIAL\n• AUR: $AUR\nStarting update..." "normal" "$ICON_UPDATE"
    
    # Update everything in one terminal session with exit code check
    $TERMINAL bash -c 'sudo pacman -Syu --noconfirm && yay -Sua --noconfirm; exit_code=$?; exit $exit_code'
    UPDATE_EXIT_CODE=$?

    if [ $UPDATE_EXIT_CODE -eq 0 ]; then
        notify "Update Complete" "System has been successfully updated\n• Official: $OFFICIAL\n• AUR: $AUR" "normal" "$ICON_SUCCESS"
    else
        notify "Error" "Update process was interrupted or failed" "critical" "$ICON_ERROR"
    fi
else
    notify "System Update" "Your system is up to date" "normal" "$ICON_SUCCESS"
fi