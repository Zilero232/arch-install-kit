#!/bin/bash

echo "🖱️ Starting anti-AFK script..."
echo "Press Ctrl+C to stop"

# Check if xdotool is installed
if ! command -v xdotool &> /dev/null; then
	echo "❌ Error: xdotool is not installed"
  echo "📦 Install it with: sudo pacman -S xdotool"

  exit 1
fi

while true; do
	# Get current mouse coordinates
  eval $(xdotool getmouselocation --shell)
    
  # Generate random offset from -50 to 50 pixels
  rand_x=$((RANDOM % 100 - 50))
  rand_y=$((RANDOM % 100 - 50))

	echo "🖱️ Moving mouse to $rand_x, $rand_y"
    
  # Move mouse to random distance
  xdotool mousemove_relative -- $rand_x $rand_y
    
  sleep 2

  # Return mouse to original position
  xdotool mousemove $X $Y
    
  # Wait for random time between 30 and 60 seconds
  sleep $((RANDOM % 30 + 30))
done