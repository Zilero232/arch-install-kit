#!/usr/bin/env bash
# Refreshes the pacman mirror list with reflector (fastest HTTPS mirrors nearby).
# The previous list is kept in mirrorlist.backup and restored on failure.
set -euo pipefail

readonly MIRRORLIST=/etc/pacman.d/mirrorlist
readonly BACKUP="$MIRRORLIST.backup"

rank_mirrors() {
    sudo reflector \
        --protocol https \
        --country Russia,Belarus,Kazakhstan \
        --age 6 \
        --ipv4 \
        --fastest 10 \
        --download-timeout 10 \
        --sort score \
        --save "$MIRRORLIST"
}

main() {
    echo "Updating mirror list..."
    sudo cp "$MIRRORLIST" "$BACKUP"

    if rank_mirrors; then
        echo "Mirror list has been updated. Backup: $BACKUP"
    else
        echo "Error updating mirror list. Restoring the previous one..." >&2
        sudo mv "$BACKUP" "$MIRRORLIST"
        exit 1
    fi
}

main "$@"
