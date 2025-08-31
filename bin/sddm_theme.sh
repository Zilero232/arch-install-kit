#!/bin/bash

if [ -f /usr/share/sddm/themes/sddm-astronaut-theme/setup.sh ]; then
    if sudo sh /usr/share/sddm/themes/sddm-astronaut-theme/setup.sh; then
        echo "SDDM Astronaut theme has been set successfully."

        notify-send "SDDM Astronaut theme has been set successfully" "dialog-ok"
    else
        echo "Failed to set SDDM Astronaut theme."

        notify-send "Failed to set SDDM Astronaut theme" "error"
    fi
else
    echo "SDDM Astronaut theme is not installed. Please install it first."

    notify-send "SDDM Astronaut theme is not installed" "error"
fi