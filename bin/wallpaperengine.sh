#!/bin/bash

# Check if linux-wallpaperengine is available
if ! command -v linux-wallpaperengine &> /dev/null; then
    notify-send "Error" "linux-wallpaperengine is not installed" -u critical
    exit 1
fi

# Launch linux-wallpaperengine with specified parameters
linux-wallpaperengine \
    --scaling fill \
    --screen-root eDP-1 \
    --screen-root DP-1 \
    --bg 3162872709 \
    --silent \
    --vsync \
    --hardware-acceleration

# Check if the command executed successfully
if [ $? -eq 0 ]; then
    notify-send "WallpaperEngine" "Successfully launched" -i video-display
else
    notify-send "Error" "Failed to launch WallpaperEngine" -u critical
    exit 1
fi
