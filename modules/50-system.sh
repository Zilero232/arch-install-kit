#!/usr/bin/env bash
# Locale, user groups, hardware fixes, snapshots, firewall and other system defaults.

WIFI_COUNTRY="RU" # regulatory domain: unlocks the 5/6 GHz channels and TX power allowed here
# Paths default to the real files; tests point them at fixtures
REGDOM_FILE="${KIT_REGDOM_FILE:-/etc/conf.d/wireless-regdom}"
REGDOM_LINE="WIRELESS_REGDOM=\"$WIFI_COUNTRY\""
TIMESHIFT_CONFIG="${KIT_TIMESHIFT_CONFIG:-/etc/timeshift/timeshift.json}"
UFW_CONFIG="${KIT_UFW_CONFIG:-/etc/ufw/ufw.conf}"

# --- User groups ---

# First, so a later failing step can't leave you without them.
# Groups that only make sense when their package is installed: package:group
for pair in docker:docker wireshark-qt:wireshark gamemode:gamemode; do
    package="${pair%%:*}"
    group="${pair##*:}"

    if is_installed "$package" && [[ " $(id -nG "$USER") " != *" $group "* ]]; then
        run sudo usermod -aG "$group" "$USER"
    fi
done

# --- Locale and mirrors ---

if ! grep -q '^ru_RU.UTF-8' /etc/locale.gen; then
    backup_once /etc/locale.gen
    run sudo sed -i 's/^#ru_RU.UTF-8/ru_RU.UTF-8/' /etc/locale.gen
    run sudo locale-gen
fi

# Weekly mirror refresh (reflector.timer is enabled by the services module)
backup_once /etc/xdg/reflector/reflector.conf
write_root_file /etc/xdg/reflector/reflector.conf <"$KIT_DIR/etc/xdg/reflector/reflector.conf"

# --- Hardware ---

# Qualcomm ath11k Wi-Fi hangs resume from suspend unless the driver is unloaded around it
if [[ -d /sys/module/ath11k_pci ]]; then
    write_root_file /usr/lib/systemd/system-sleep/ath11k 755 \
        <"$KIT_DIR/etc/systemd/system-sleep/ath11k.sh"
fi

# Compressed swap in RAM; takes effect after a reboot (archinstall may have written one already)
if is_installed zram-generator; then
    backup_once /etc/systemd/zram-generator.conf
    write_root_file /etc/systemd/zram-generator.conf <"$KIT_DIR/etc/systemd/zram-generator.conf"
fi

# Wi-Fi regulatory domain, see WIFI_COUNTRY
if is_installed wireless-regdb && ! grep -q "^$REGDOM_LINE" "$REGDOM_FILE"; then
    if grep -q "^#$REGDOM_LINE" "$REGDOM_FILE"; then
        backup_once "$REGDOM_FILE"
        run sudo sed -i "s/^#$REGDOM_LINE/$REGDOM_LINE/" "$REGDOM_FILE"
    else
        warn "No $WIFI_COUNTRY line in $REGDOM_FILE: set WIRELESS_REGDOM there by hand"
    fi
fi

# --- Snapshots ---

# Timeshift (rsync) snapshots before every upgrade (timeshift-autosnap). The root partition is
# often too small to hold a copy of the system, and rsync then fails without saying so, so the
# snapshots go to /home when it is a separate, roomier partition.
# The config is written when there is none, or when Timeshift's own first run picked the root
# partition and /home would be better; then only the target changes, your schedule and excludes
# stay. A config pointing anywhere else (an external disk) is left alone.
if is_installed timeshift; then
    root_uuid="$(findmnt -no UUID /)"
    backup_uuid="$root_uuid"

    if mountpoint -q /home \
        && (($(df --output=avail /home | tail -1) > $(df --output=avail / | tail -1))); then
        backup_uuid="$(findmnt -no UUID /home)"
    fi

    write_config=0
    if [[ ! -f "$TIMESHIFT_CONFIG" ]]; then
        write_config=1
    elif [[ "$backup_uuid" != "$root_uuid" ]] \
        && grep -Eq "\"backup_device_uuid\" *: *\"$root_uuid\"" "$TIMESHIFT_CONFIG"; then
        write_config=1
    fi

    # Rendered first, so a failed sed or jq can't install an empty config. An existing config
    # only gets its target changed: schedules, counts and excludes stay as you set them.
    if ((write_config)) && [[ -f "$TIMESHIFT_CONFIG" ]]; then
        config="$(jq --arg uuid "$backup_uuid" '.backup_device_uuid = $uuid' "$TIMESHIFT_CONFIG")"
        backup_once "$TIMESHIFT_CONFIG"
        write_root_file "$TIMESHIFT_CONFIG" <<<"$config"
    elif ((write_config)); then
        config="$(sed "s/@BACKUP_UUID@/$backup_uuid/" "$KIT_DIR/etc/timeshift/timeshift.json")"
        write_root_file "$TIMESHIFT_CONFIG" <<<"$config"
    fi
fi

# --- Security ---

# Firewall: ufw's defaults already deny incoming and allow outgoing (/etc/default/ufw).
# Enabling it here only flips the config; ufw.service (services module) applies it at boot,
# so a kernel upgrade earlier in this run can't make `ufw enable` fail mid-install.
if is_installed ufw && grep -q '^ENABLED=no' "$UFW_CONFIG"; then
    backup_once "$UFW_CONFIG"
    run sudo sed -i 's/^ENABLED=no/ENABLED=yes/' "$UFW_CONFIG"
fi

# INCY VPN connects without a password prompt (the rule allows only its own helper calls)
if is_installed incy-bin; then
    write_root_file /etc/polkit-1/rules.d/50-incy.rules \
        <"$KIT_DIR/etc/polkit-1/rules.d/50-incy.rules"
fi

ok "System configured"
