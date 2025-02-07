#!/bin/bash

echo "🔒 Locking screen..."

# Switch to English layout.
setxkbmap us

betterlockscreen -l blur \
    --off 300 \
    --blur 0.5 \
    --dim 40 \
    --time-format "%H:%M" \
    --show-layout

if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to lock screen"

    exit 1
fi