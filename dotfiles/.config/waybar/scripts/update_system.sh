#!/usr/bin/env bash
# Runs pacman + yay upgrades in a terminal and reports the result via notifications
# (click on the custom/updates module).
set -euo pipefail

readonly TERMINAL=(alacritty -e)
readonly NOTIFY_TIMEOUT=5000
readonly ICON_UPDATE="󰚰"
readonly ICON_SUCCESS="󰄬"
readonly ICON_ERROR="󰅚"

notify() {
    local icon=$1 title=$2 message=$3 urgency=${4:-normal}
    notify-send "$icon $title" "$message" -u "$urgency" -t "$NOTIFY_TIMEOUT"
}

count_updates() {
    { "$@" 2> /dev/null || true; } | wc -l
}

run_upgrade() {
    "${TERMINAL[@]}" bash -c 'sudo pacman -Syu --noconfirm && yay -Sua --noconfirm'
}

# Ask waybar to re-run check_updates.sh ("signal": 1)
refresh_waybar() {
    pkill -RTMIN+1 -x waybar || true
}

main() {
    local official aur
    official=$(count_updates checkupdates)
    aur=$(count_updates yay -Qua)

    if [[ $((official + aur)) -eq 0 ]]; then
        notify "$ICON_SUCCESS" "System Update" "Your system is up to date"
        exit 0
    fi

    local summary="• Official: $official\n• AUR: $aur"
    notify "$ICON_UPDATE" "System Update" "Found updates:\n$summary\nStarting update..."

    if run_upgrade; then
        refresh_waybar
        notify "$ICON_SUCCESS" "Update Complete" "System has been successfully updated\n$summary"
    else
        refresh_waybar
        notify "$ICON_ERROR" "Error" "Update process was interrupted or failed" critical
    fi
}

main "$@"
