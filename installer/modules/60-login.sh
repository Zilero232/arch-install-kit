#!/usr/bin/env bash
# SDDM theme and the Plymouth boot splash.

PLYMOUTH_THEME="arch-logo"

write_root_file /etc/sddm.conf.d/theme.conf <"$SYSTEM_DIR/sddm.conf.d/theme.conf"

if ((!WITH_PLYMOUTH)) || ! is_installed plymouth; then
    info "Plymouth skipped"
    return 0
fi

# Drop-in: lets the splash animation finish before SDDM starts
write_root_file /etc/systemd/system/plymouth-quit.service.d/wait-for-animation.conf \
    <"$SYSTEM_DIR/systemd/system/plymouth-quit.service.d/wait-for-animation.conf"

if ! grep -q '^HOOKS=.*plymouth' /etc/mkinitcpio.conf; then
    backup_once /etc/mkinitcpio.conf
    run sudo sed -i -E '/^HOOKS=/ s/\b(systemd|udev)\b/\1 plymouth/' /etc/mkinitcpio.conf
fi

# The splash only shows with "splash" on the kernel command line
if [[ "$(bootloader)" == grub ]]; then
    if ! grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=.*splash' /etc/default/grub; then
        backup_once /etc/default/grub
        run sudo sed -i -E '/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/"$/ splash"/' /etc/default/grub

        # The sed only handles a double-quoted value; a single-quoted one is left as it was
        if ((!DRY_RUN)) && ! grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=.*splash' /etc/default/grub; then
            warn "Add 'splash' to GRUB_CMDLINE_LINUX_DEFAULT in /etc/default/grub by hand"
        fi
    fi
elif ! grep -qw splash /proc/cmdline; then
    warn "Add 'quiet splash' to the kernel command line manually ($(bootloader))"
fi

# Arch logo with a progress bar (plymouth-theme-arch-logo); the boot module rebuilds the initramfs
# Captured first: `| grep -q` under pipefail can fail on SIGPIPE
themes="$(plymouth-set-default-theme -l)"
if ! grep -qx "$PLYMOUTH_THEME" <<<"$themes"; then
    warn "Plymouth theme $PLYMOUTH_THEME not found, keeping the default"
elif [[ "$(plymouth-set-default-theme)" != "$PLYMOUTH_THEME" ]]; then
    run sudo plymouth-set-default-theme "$PLYMOUTH_THEME"
fi

ok "Login configured (initramfs is rebuilt in the boot step)"
