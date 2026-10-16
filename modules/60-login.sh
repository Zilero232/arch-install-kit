#!/usr/bin/env bash
# SDDM theme and the Plymouth boot splash.

write_root_file /etc/sddm.conf.d/theme.conf <"$KIT_DIR/etc/sddm.conf.d/theme.conf"

if ((!WITH_PLYMOUTH)) || ! is_installed plymouth; then
    info "Plymouth skipped"
    return 0
fi

# Drop-in: lets the splash animation finish before SDDM starts
write_root_file /etc/systemd/system/plymouth-quit.service.d/wait-for-animation.conf \
    <"$KIT_DIR/etc/systemd/system/plymouth-quit.service.d/wait-for-animation.conf"

if ! grep -q '^HOOKS=.*plymouth' /etc/mkinitcpio.conf; then
    backup_once /etc/mkinitcpio.conf
    run sudo sed -i -E '/^HOOKS=/ s/\b(systemd|udev)\b/\1 plymouth/' /etc/mkinitcpio.conf
fi

if [[ "$(bootloader)" == grub ]]; then
    if ! grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=.*splash' /etc/default/grub; then
        backup_once /etc/default/grub
        run sudo sed -i -E '/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/"$/ splash"/' /etc/default/grub
    fi
else
    warn "Add 'quiet splash' to the kernel command line manually ($(bootloader))"
fi

theme="$(plymouth-set-default-theme -l | grep -m1 -i deus || true)"
if [[ -n "$theme" ]]; then
    run sudo plymouth-set-default-theme "$theme"
else
    warn "Deus Ex Plymouth theme not found, keeping the default"
fi
ok "Login configured (initramfs is rebuilt in the boot step)"
