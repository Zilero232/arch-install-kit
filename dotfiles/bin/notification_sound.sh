#!/usr/bin/env bash
# Plays the notification sound for swaync, unless Do Not Disturb is on.
# swaync runs its scripts even in DND and cannot pass quoted arguments, hence this file.

set -euo pipefail

readonly SOUND="/usr/share/sounds/freedesktop/stereo/message-new-instant.oga"

main() {
    local dnd

    # Best effort: a failure here would make swaync show a "script failed" notification
    dnd=$(swaync-client --get-dnd) || dnd=false

    if [[ "$dnd" == false ]]; then
        pw-play "$SOUND" || true
    fi
}

# Sourcing the file (tests) loads the functions without running main
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
