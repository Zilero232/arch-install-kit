#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: plymouth-theme <list|set> [theme-name]"
    echo "  list - show available themes"
    echo "  set <theme-name> - set specific theme"

    exit 1
fi

case "$1" in
    "list")
        if command -v plymouth-set-default-theme >/dev/null; then
            plymouth-set-default-theme -l

            notify-send "Available Plymouth themes listed" "dialog-information"
        else
            echo "Plymouth is not installed. Please install plymouth first."

            notify-send "Plymouth is not installed" "error"
        fi
        ;;
    "set")
        if [ $# -eq 2 ]; then
            if command -v plymouth-set-default-theme >/dev/null; then
                # Check if theme exists in the list
                if plymouth-set-default-theme -l | grep -q "$2"; then
                    if sudo plymouth-set-default-theme -R "$2"; then
                        echo "Theme '$2' has been set successfully."

                        notify-send "Theme '$2' has been set successfully" "dialog-ok"
                    else
                        echo "Failed to set theme '$2'."

                        notify-send "Failed to set theme '$2'" "error"
                    fi
                else
                    echo "Theme '$2' not found. Use 'plymouth-theme list' to see available themes."

                    notify-send "Theme '$2' not found" "error"
                fi
            else
                echo "Plymouth is not installed. Please install plymouth first."
                send_notification "Plymouth is not installed" "error"
            fi
        else
            echo "Usage: plymouth-theme set <theme-name>"

            notify-send "Invalid usage" "error"
        fi
        ;;
    *)
        echo "Unknown command: $1"
        echo "Usage: plymouth-theme <list|set> [theme-name]"

        notify-send "Unknown command: $1" "error"
        exit 1
        ;;
esac