#!/usr/bin/env bash
# Watches the DP-1 port: mirrors the laptop panel onto an external monitor when one is
# plugged in, restores the native laptop mode when it is unplugged. Started from autostart;
# exits together with the Hyprland session that launched it.

set -euo pipefail

readonly POLL_SECONDS=5
readonly HYPR_SOCKET="${XDG_RUNTIME_DIR:-}/hypr/${HYPRLAND_INSTANCE_SIGNATURE:-}/.socket.sock"

hyprland_running() {
    [[ -S "$HYPR_SOCKET" ]]
}

dp1_connected() {
    local status_file
    for status_file in /sys/class/drm/card*/card*-DP-1/status; do
        if [[ -f "$status_file" ]] && grep -q '^connected' "$status_file"; then
            return 0
        fi
    done
    return 1
}

use_external_mirror() {
    hyprctl keyword monitor "eDP-1, 2560x1440@120, 0x0, 1"
    hyprctl keyword monitor "DP-1, 2560x1440@165, 0x0, 1, mirror, eDP-1"
}

use_laptop_only() {
    hyprctl keyword monitor "eDP-1, 2560x1600@120, 0x0, 1"
    hyprctl keyword monitor "DP-1, disable"
}

main() {
    local previous="" current
    while hyprland_running; do
        if dp1_connected; then current="external"; else current="laptop"; fi

        if [[ "$current" != "$previous" ]]; then
            if [[ "$current" == "external" ]]; then
                use_external_mirror || true
            else
                use_laptop_only || true
            fi
            previous="$current"
        fi

        sleep "$POLL_SECONDS"
    done
}

main "$@"
