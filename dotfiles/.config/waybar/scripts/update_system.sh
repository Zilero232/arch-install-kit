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

# Line count of a command's output; 0 when the command is not installed
count_updates() {
    command -v "$1" >/dev/null || { echo 0; return; }
    { "$@" 2>/dev/null || true; } | wc -l
}

# The terminal's exit code is not the upgrade's, so the result comes back through a file
run_upgrade() {
    local status_file status
    status_file=$(mktemp)
    # shellcheck disable=SC2016 # $? and $1 belong to the inner bash inside the terminal
    "${TERMINAL[@]}" bash -c '
        sudo pacman -Syu --noconfirm && { ! command -v yay >/dev/null || yay -Sua --noconfirm; }
        echo $? >"$1"
        read -rp "Done. Press Enter to close..."
    ' bash "$status_file" || true
    status=$(<"$status_file")
    rm -f "$status_file"
    [[ "$status" == 0 ]]
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

    # notify-send does not expand "\n", so the newlines are real ones
    local summary
    summary=$(printf '• Official: %s\n• AUR: %s' "$official" "$aur")
    notify "$ICON_UPDATE" "System Update" "$(printf 'Found updates:\n%s\nStarting update...' "$summary")"

    if run_upgrade; then
        refresh_waybar
        notify "$ICON_SUCCESS" "Update Complete" "$(printf 'System has been successfully updated\n%s' "$summary")"
    else
        refresh_waybar
        notify "$ICON_ERROR" "Error" "Update process was interrupted or failed" critical
    fi
}

main "$@"
