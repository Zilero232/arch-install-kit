#!/bin/sh

# Check if required commands exist.
if ! command -v notify-send &> /dev/null; then
    echo "Error: notify-send command not found"
    
    exit 1
fi

# Configuration.    
LAST="NONE" 
CRITICAL_LEVEL=10
LOW_LEVEL=25
BATTERY_PATH="/sys/class/power_supply/BATT"
CHECK_INTERVAL=60  # seconds.

while true; do
    # Check if battery exists.
    if [ ! -d "$BATTERY_PATH" ]; then
        sleep "$CHECK_INTERVAL"

        continue
    fi

    # Read battery status.
    CAPACITY=$(cat "$BATTERY_PATH/capacity")
    STATUS=$(cat "$BATTERY_PATH/status")

    # If battery full and not already warned about that.
    if [ "$LAST" != "FULL" ] && [ "$STATUS" = "Full" ]; then
        notify-send "Battery Status" "Battery is fully charged" -i battery-full -t 5000

        LAST="FULL"
    fi

    # If battery is charging, reset the warning state.
    if [ "$STATUS" = "Charging" ]; then
        LAST="NONE"
    fi

    # If low and discharging.
    if [ "$LAST" != "LOW" ] && [ "$LAST" != "CRITICAL" ] && \
       [ "$STATUS" = "Discharging" ] && [ "$CAPACITY" -le "$LOW_LEVEL" ]; then
        notify-send "Battery Warning" "Battery level is low: $CAPACITY%" -i battery-low -u normal -t 10000

        LAST="LOW"
    fi

    # If critical level and discharging.
    if [ "$LAST" = "LOW" ] && [ "$STATUS" = "Discharging" ] && \
       [ "$CAPACITY" -le "$CRITICAL_LEVEL" ]; then
        notify-send "Battery Critical" "Battery level is critical: $CAPACITY%" -i battery-empty -u critical -t 0

        LAST="CRITICAL"
    fi

    sleep "$CHECK_INTERVAL"
done