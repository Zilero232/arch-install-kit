#!/bin/bash

# Check if hyprctl is available
if ! command -v hyprctl &> /dev/null; then
    notify-send "Error" "hyprctl is not installed" -u critical
    exit 1
fi

# Check if Images directory exists
if [ ! -d "$HOME/Images" ]; then
    notify-send "Error" "Images directory not found" -u critical
    exit 1
fi

# Find all image files
IMAGES=($(find "$HOME/Images" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) 2>/dev/null))

# Check if there are any images in the directory
if [ ${#IMAGES[@]} -eq 0 ]; then
    notify-send "Error" "No images found in Images directory" -u critical
    exit 1
fi

# Select random image
RANDOM_IMAGE=${IMAGES[$RANDOM % ${#IMAGES[@]}]}

# Update hyprpaper config
HYPRPAPER_CONFIG="$HOME/.config/hypr/hyprpaper.conf"

# Create hyprpaper config file
cat > "$HYPRPAPER_CONFIG" << EOF
preload = $RANDOM_IMAGE
wallpaper = ,$RANDOM_IMAGE
splash = false
ipc = on
EOF

# Set wallpaper using hyprctl
if hyprctl hyprpaper preload "$RANDOM_IMAGE" && hyprctl hyprpaper wallpaper ",$RANDOM_IMAGE"; then
    notify-send "Wallpaper" "Successfully changed" -i image
else
    # Fallback: restart hyprpaper if hyprctl fails
    pkill hyprpaper 
    hyprpaper &
    notify-send "Wallpaper" "Successfully changed (restarted hyprpaper)" -i image
fi