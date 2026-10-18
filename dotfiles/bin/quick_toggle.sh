#!/usr/bin/env bash
# Night light and microphone toggles for the swaync control centre buttons.
# swaync passes the wanted state in SWAYNC_TOGGLE_STATE; `status` prints the current one.
# Usage: quick_toggle.sh night|mic          apply SWAYNC_TOGGLE_STATE (true = on)
#        quick_toggle.sh night|mic status   print true or false

set -euo pipefail

readonly NIGHT_TEMPERATURE=4500
readonly NEUTRAL_TEMPERATURE=6500
readonly MIC="@DEFAULT_AUDIO_SOURCE@"

# --- Night light (hyprsunset) ---

night_status() {
    local temperature

    temperature=$(hyprctl hyprsunset temperature 2>/dev/null) || temperature=$NEUTRAL_TEMPERATURE

    if ((temperature < NEUTRAL_TEMPERATURE)); then
        echo true
    else
        echo false
    fi
}

night_set() {
    if [[ "$1" == true ]]; then
        hyprctl hyprsunset temperature "$NIGHT_TEMPERATURE" >/dev/null
    else
        # A neutral temperature, not identity: identity keeps reporting the old value, which reads as "on"
        hyprctl hyprsunset temperature "$NEUTRAL_TEMPERATURE" >/dev/null
    fi
}

# --- Microphone (PipeWire) ---

mic_status() {
    if wpctl get-volume "$MIC" | grep -q MUTED; then
        echo true
    else
        echo false
    fi
}

mic_set() {
    if [[ "$1" == true ]]; then
        wpctl set-mute "$MIC" 1
    else
        wpctl set-mute "$MIC" 0
    fi
}

# --- Main ---

usage() {
    echo "Usage: quick_toggle.sh night|mic [status]" >&2
}

main() {
    local target="${1:-}"
    local action="${2:-set}"

    case "$target" in
        night | mic) ;;
        *)
            usage
            exit 1
            ;;
    esac

    if [[ "$action" == status ]]; then
        "${target}_status"
    else
        "${target}_set" "${SWAYNC_TOGGLE_STATE:-false}"
    fi
}

# Sourcing the file (tests) loads the functions without running main
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
