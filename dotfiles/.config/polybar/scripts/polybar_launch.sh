#!/usr/bin/env bash

# Terminate already running polybar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Create log files if they don't exist
mkdir -p /tmp/polybar
echo "---" | tee -a /tmp/polybar/top.log

# Launch polybar
polybar top -r >>/tmp/polybar/top.log 2>&1 & disown

echo "Polybar launched successfully"