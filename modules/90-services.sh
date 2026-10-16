#!/usr/bin/env bash
# Enables units from services.txt whose package is installed (they start after reboot).

while read -r unit scope package; do
    is_installed "$package" || continue
    if [[ "$scope" == user ]]; then
        run systemctl --user enable "$unit"
    else
        run sudo systemctl enable "$unit"
    fi
done < <(sed 's/#.*//; /^[[:space:]]*$/d' "$KIT_DIR/services.txt")

# Boot does not wait for the network
run sudo systemctl mask NetworkManager-wait-online.service

# Earlier versions masked rfkill for TLP; power-profiles-daemon needs it back
if [[ "$(systemctl is-enabled systemd-rfkill.socket 2>/dev/null)" == masked ]]; then
    run sudo systemctl unmask systemd-rfkill.service systemd-rfkill.socket
fi
ok "Services enabled"
