#!/usr/bin/env bash
# Locale, user groups and small system defaults.

WIFI_COUNTRY="RU" # regulatory domain: unlocks the 5/6 GHz channels and TX power allowed here

if ! grep -q '^ru_RU.UTF-8' /etc/locale.gen; then
    backup_once /etc/locale.gen
    run sudo sed -i 's/^#ru_RU.UTF-8/ru_RU.UTF-8/' /etc/locale.gen
    run sudo locale-gen
fi

# Weekly mirror refresh (reflector.timer is enabled by the services module)
write_root_file /etc/xdg/reflector/reflector.conf <"$KIT_DIR/etc/xdg/reflector/reflector.conf"

# Compressed swap in RAM; takes effect after a reboot
if is_installed zram-generator; then
    write_root_file /etc/systemd/zram-generator.conf <"$KIT_DIR/etc/systemd/zram-generator.conf"
fi

if is_installed wireless-regdb && ! grep -q "^WIRELESS_REGDOM=\"$WIFI_COUNTRY\"" /etc/conf.d/wireless-regdom; then
    backup_once /etc/conf.d/wireless-regdom
    run sudo sed -i "s/^#WIRELESS_REGDOM=\"$WIFI_COUNTRY\"/WIRELESS_REGDOM=\"$WIFI_COUNTRY\"/" /etc/conf.d/wireless-regdom
fi

# Firewall: deny incoming, allow outgoing (ufw.service is enabled by the services module)
if is_installed ufw && ! sudo grep -q '^ENABLED=yes' /etc/ufw/ufw.conf; then
    run sudo ufw default deny incoming
    run sudo ufw default allow outgoing
    run sudo ufw --force enable
fi

# INCY VPN connects without a password prompt (the rule allows only its own helper calls)
if is_installed incy-bin; then
    write_root_file /etc/polkit-1/rules.d/50-incy.rules <"$KIT_DIR/etc/polkit-1/rules.d/50-incy.rules"
fi

for group in video input; do
    if ! id -nG "$USER" | grep -qw "$group"; then
        run sudo usermod -aG "$group" "$USER"
    fi
done

# Groups that only make sense when their package is installed: package:group
for pair in docker:docker wireshark-qt:wireshark gamemode:gamemode; do
    package="${pair%%:*}"
    group="${pair##*:}"
    if is_installed "$package" && ! id -nG "$USER" | grep -qw "$group"; then
        run sudo usermod -aG "$group" "$USER"
    fi
done
ok "System configured"
