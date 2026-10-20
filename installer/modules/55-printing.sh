#!/usr/bin/env bash
# Network printers and scanners: mDNS host names and the firewall port for discovery (needs cups).

NSSWITCH_FILE="${KIT_NSSWITCH_FILE:-/etc/nsswitch.conf}" # KIT_*: tests point it at a fixture

if ! is_installed cups; then
    info "Printing skipped (the printing group is not installed)"
    return 0
fi

# Resolve printer.local names through Avahi, before systemd-resolved (Arch Wiki, Avahi)
if is_installed nss-mdns && ! grep -q '^hosts:.*mdns' "$NSSWITCH_FILE"; then
    backup_once "$NSSWITCH_FILE"
    run sudo sed -i '/^hosts:/ s/resolve/mdns_minimal [NOTFOUND=return] resolve/' "$NSSWITCH_FILE"
fi

# Printers answer discovery from port 5353; ufw drops those replies unless it is open
if is_installed ufw; then
    run sudo ufw allow 5353/udp comment 'mDNS: network printers and scanners'
fi

ok "Printing configured"
