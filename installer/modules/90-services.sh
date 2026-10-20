#!/usr/bin/env bash
# Enables units from services.txt whose package is installed (they start after reboot).

# is_unit_enabled <unit> <scope>: read-only, so the dry run lists only units still to enable
is_unit_enabled() {
    local args=(is-enabled --quiet "$1")

    if [[ "$2" == user ]]; then
        args=(--user "${args[@]}")
    fi

    systemctl "${args[@]}" 2>/dev/null
}

# One unit that fails to enable must not leave the others disabled: note it and go on
failed=0
while read -r unit scope package; do
    if ! is_installed "$package" || is_unit_enabled "$unit" "$scope"; then
        continue
    fi

    if [[ "$scope" == user ]]; then
        if ! run systemctl --user enable "$unit"; then
            warn "Could not enable $unit (user)"
            failed=1
        fi
    elif ! run sudo systemctl enable "$unit"; then
        warn "Could not enable $unit"
        failed=1
    fi
done < <(sed 's/#.*//; /^[[:space:]]*$/d' "$KIT_DIR/installer/services.txt")

# Boot does not wait for the network
run sudo systemctl mask NetworkManager-wait-online.service

# Earlier versions masked rfkill for TLP; power-profiles-daemon needs it back
if [[ "$(systemctl is-enabled systemd-rfkill.socket 2>/dev/null)" == masked ]]; then
    run sudo systemctl unmask systemd-rfkill.service systemd-rfkill.socket
fi

# Non-zero after the masks, so run_module marks the module failed and the summary shows it
if ((failed)); then
    err "Some units could not be enabled, see the warnings above"
    return 1
fi

ok "Services enabled"
