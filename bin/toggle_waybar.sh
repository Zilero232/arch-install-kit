#!/bin/sh

# Check if required commands exist
if ! command -v waybar &> /dev/null; then
    notify-send "Error" "Waybar not found" -u critical
    
    exit 1
fi

# Check if waybar is running
if pgrep -x waybar > /dev/null; then
    # Kill waybar
    if killall waybar; then
        sleep 0.5  # Give waybar time to close

        notify-send "Waybar" "Successfully hidden" -i window-close
    else
        notify-send "Error" "Failed to kill waybar" -u critical
    fi
else 
    # Launch waybar in background
    if waybar > /dev/null 2>&1 & then
        sleep 0.5  # Give waybar time to start

        notify-send "Waybar" "Successfully launched" -i window-new
    else
        notify-send "Error" "Failed to launch waybar" -u critical
    fi
fi