#!/bin/bash

# Kill any running instances.
killall -q wlogout

# Wait until processes have been shut down.
while pgrep -u $UID -x wlogout >/dev/null; do 
    sleep 0.5
done

# Launch with centered compact layout.
wlogout \
    --buttons-per-row 2 \
    --margin-top 300 \
    --margin-bottom 300 \
    --margin-left 500 \
    --margin-right 500
