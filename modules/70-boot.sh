#!/usr/bin/env bash
# Rebuilds initramfs (drivers, plymouth) and the GRUB menu with Windows detection.

run sudo mkinitcpio -P

if [[ "$(bootloader)" == grub ]]; then
    if ! grep -q '^GRUB_DISABLE_OS_PROBER=false' /etc/default/grub; then
        backup_once /etc/default/grub
        echo 'GRUB_DISABLE_OS_PROBER=false' | run sudo tee -a /etc/default/grub >/dev/null
    fi
    run sudo grub-mkconfig -o /boot/grub/grub.cfg
fi
ok "Boot updated"
