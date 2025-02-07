#!/bin/bash

# Check if required commands exist.
if ! command -v setxkbmap &> /dev/null || ! command -v notify-send &> /dev/null; then
    echo "Error: Required commands (setxkbmap or notify-send) not found"

    exit 1
fi

# Get current keyboard layout.
CURRENT_LAYOUT=$(setxkbmap -query | awk -F : 'NR==3{print $2}' | sed 's/ //g')

if [ "$CURRENT_LAYOUT" = "us" ]; then
    if ! setxkbmap "ru"; then
        notify-send "Keyboard Layout Error" "Failed to switch to Russian layout" -t 1500 -i input-keyboard

        exit 1
    fi

    notify-send "Keyboard Layout" "Switched to Russian Layout" -t 1500 -i input-keyboard
else
    if ! setxkbmap "us"; then
        notify-send "Keyboard Layout Error" "Failed to switch to English layout" -t 1500 -i input-keyboard
        
        exit 1
    fi

    notify-send "Keyboard Layout" "Switched to English Layout" -t 1500 -i input-keyboard
fi