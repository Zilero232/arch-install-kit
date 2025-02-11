#!/bin/bash

# Check if necessary commands exist
check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: $1 is not installed"
        
        exit 1
    fi
}

check_command checkupdates
check_command yay

# Get official repo updates
OFFICIAL=$(checkupdates 2>/dev/null | wc -l)

# Get AUR updates
AUR=$(yay -Qua 2>/dev/null | wc -l)

# Calculate total updates
TOTAL=$((OFFICIAL + AUR))

if [ "$TOTAL" -gt 0 ]; then
    OUTPUT=""
    if [ "$OFFICIAL" -gt 0 ]; then
        OUTPUT+="%{F#7aa2f7}P%{F-}: $OFFICIAL"
    fi

    if [ "$AUR" -gt 0 ]; then
        [ -n "$OUTPUT" ] && OUTPUT+=" "
        OUTPUT+="%{F#e0af68}A%{F-}: $AUR"
    fi
    echo "$OUTPUT"
else
    echo "0"
fi