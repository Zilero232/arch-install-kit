#!/bin/bash
# Hardware and boot setup detection.

gpu_info() {
    lspci -nn | grep -Ei 'vga|3d|display' || true
}

has_nvidia()    { gpu_info | grep -qi nvidia; }
has_amd_gpu()   { gpu_info | grep -Eqi 'amd|ati'; }
has_intel_gpu() { gpu_info | grep -qi intel; }

cpu_vendor() {
    grep -m1 vendor_id /proc/cpuinfo | awk '{print $3}'
}

# grub | systemd-boot | unknown
bootloader() {
    if [ -f /etc/default/grub ] && [ -d /boot/grub ]; then
        echo grub
    elif bootctl is-installed &>/dev/null; then
        echo systemd-boot
    else
        echo unknown
    fi
}

# Kernel package names (linux, linux-lts, ...) for headers
installed_kernels() {
    cat /usr/lib/modules/*/pkgbase 2>/dev/null | sort -u
}
