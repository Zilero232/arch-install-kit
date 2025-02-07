#!/bin/bash

# Create log directory if it doesn't exist
mkdir -p /tmp/dunst

# Debug logging.
log_file="/tmp/dunst/dunst-notify.log"

# Logging function.
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$log_file"
}

# Get notification parameters
SUMMARY="$2"
BODY="$3"
URGENCY="${5:-normal}"

# Log incoming parameters.
log_message "Summary: $SUMMARY"
log_message "Body: $BODY"
log_message "Urgency: $URGENCY"

# Sound playing function.
play_sound() {
    local sound="$1"

    canberra-gtk-play -i "$sound" &
    log_message "Playing sound: $sound"
}

# Select sound based on urgency level.
case "$URGENCY" in
    "LOW")
        play_sound "message"            # Soft information sound
        ;;
    "NORMAL")
        play_sound "dialog-information" # Standard notification sound
        ;;
    "CRITICAL")
        play_sound "dialog-warning"     # Warning sound for critical notifications
        
        log_message "CRITICAL: [$SUMMARY] - $BODY"
        ;;
    *)
        log_message "Unknown urgency: $URGENCY, using normal sound"

        play_sound "dialog-information"
        ;;
esac