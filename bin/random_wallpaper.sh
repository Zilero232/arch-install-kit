#!/bin/bash

# Check if feh is installed
if ! command -v feh &> /dev/null; then
    notify-send "Error" "feh is not installed" -u critical

    exit 1
fi

# Check if Images directory exists.
if [ ! -d "$HOME/Images" ]; then
    notify-send "Error" "Images directory not found" -u critical

    exit 1
fi

# Check if there are any images in the directory.
if [ -z "$(ls -A $HOME/Images)" ]; then
    notify-send "Error" "No images found in Images directory" -u critical

    exit 1
fi

# Set random wallpaper.
if feh --randomize --no-fehbg --bg-fill ~/Images/; then
    notify-send "Wallpaper" "Successfully changed" -i image
else
    notify-send "Error" "Failed to set wallpaper" -u critical
fi