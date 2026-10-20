#!/usr/bin/env bash
# Stops early when the machine is not ready for the install.

if [[ ! -f /etc/arch-release ]]; then
    die "This kit is for Arch Linux only"
fi

if [[ -f /var/lib/pacman/db.lck ]]; then
    die "pacman is locked: another install running? (or remove /var/lib/pacman/db.lck)"
fi

# HTTPS, not ping: many networks (and CI runners) drop ICMP while the web works fine
if ! curl -fsI --max-time 10 https://archlinux.org &>/dev/null; then
    die "No internet: connect with nmtui first"
fi

free_gb="$(df -BG --output=avail / | tail -1 | tr -dc '0-9')"
if ((free_gb < 15)); then
    warn "Only ${free_gb}G free on /, a full install needs ~15G"
fi

# What the later modules will detect, so a wrong guess shows up before anything changes
info "CPU: $(cpu_vendor)"
while read -r gpu; do
    info "GPU: ${gpu#*: }"
done < <(gpu_info)
info "Bootloader: $(bootloader)"
info "Kernels: $(installed_kernels | xargs)"
info "Package groups: ${PKG_GROUPS[*]}"

ok "Ready"
