#!/bin/bash
# Stops early when the machine is not ready for the install.

[ -f /etc/arch-release ] || die "This kit is for Arch Linux only"
[ ! -f /var/lib/pacman/db.lck ] || die "pacman is locked: another install running? (or remove /var/lib/pacman/db.lck)"
ping -c1 -W5 archlinux.org &>/dev/null || die "No internet: connect with nmtui first"

free_gb="$(df -BG --output=avail / | tail -1 | tr -dc '0-9')"
((free_gb >= 15)) || warn "Only ${free_gb}G free on /, a full install needs ~15G"

info "CPU: $(cpu_vendor)"
while read -r gpu; do
    info "GPU: ${gpu#*: }"
done < <(gpu_info)
info "Bootloader: $(bootloader)"
info "Kernels: $(installed_kernels | xargs)"
info "Package groups: ${PKG_GROUPS[*]}"
ok "Ready"
