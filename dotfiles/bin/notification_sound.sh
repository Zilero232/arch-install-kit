#!/usr/bin/env bash
# Plays the notification sound for swaync, unless Do Not Disturb is on.
# swaync runs its scripts even in DND and cannot pass quoted arguments, hence this file.

set -euo pipefail

readonly SOUND="/usr/share/sounds/freedesktop/stereo/message-new-instant.oga"

main() {
    local dnd

    dnd=$(swaync-client --get-dnd)

    if [[ "$dnd" == false ]]; then
        pw-play "$SOUND"
    fi
}

main "$@"
