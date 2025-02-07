#!/bin/sh

# Check if required commands exist
if ! command -v polybar &> /dev/null; then
    notify-send "Error" "Polybar not found" -u critical

    exit 1
fi

# Check if polybar is running.
if pgrep -x polybar > /dev/null; then
    # Kill polybar.
    if killall polybar; then
        notify-send "Polybar" "Successfully hidden" -i window-close
    else
        notify-send "Error" "Failed to kill polybar" -u critical
    fi
else 
    # Launch polybar.
    if "$HOME/.config/polybar/scripts/polybar_launch.sh"; then
        notify-send "Polybar" "Successfully launched" -i window-new
    else
        notify-send "Error" "Failed to launch polybar" -u critical
    fi
fi