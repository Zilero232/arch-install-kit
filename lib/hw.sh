#!/usr/bin/env bash
# Hardware and boot setup detection.

gpu_info() {
    lspci -nn | grep -Ei 'vga|3d|display' || true
}

# Match PCI vendor ids, not names: "ati" is also inside "Corporation"
has_nvidia()    { gpu_info | grep -qi '\[10de:'; }
has_amd_gpu()   { gpu_info | grep -qi '\[1002:'; }
has_intel_gpu() { gpu_info | grep -qi '\[8086:'; }

cpu_vendor() {
    grep -m1 vendor_id /proc/cpuinfo | awk '{print $3}'
}

# grub | systemd-boot | unknown
# /boot is root-only (0700), so look at packages and /etc instead of /boot itself
bootloader() {
    if [[ -f /etc/default/grub ]] && is_installed grub; then
        echo grub
    elif sudo bootctl is-installed &>/dev/null; then
        echo systemd-boot
    else
        echo unknown
    fi
}

# Kernel package names (linux, linux-lts, ...) for headers
installed_kernels() {
    cat /usr/lib/modules/*/pkgbase 2>/dev/null | sort -u
}
