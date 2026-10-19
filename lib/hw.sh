#!/usr/bin/env bash
# Hardware and boot setup detection.

# One directory per installed kernel; each has a pkgbase file with the package name
KERNEL_MODULES_DIR=/usr/lib/modules

# --- GPU and CPU ---

gpu_info() {
    lspci -nn | grep -Ei 'vga|3d|display' || true
}

# Match PCI vendor ids, not names: "ati" is also inside "Corporation"
# Captured first: `| grep -q` under pipefail can fail on SIGPIPE
has_gpu_vendor() {
    local vendor_id="$1"
    local gpus

    gpus="$(gpu_info)"
    grep -qi "\[$vendor_id:" <<<"$gpus"
}

has_nvidia() {
    has_gpu_vendor 10de
}

has_amd_gpu() {
    has_gpu_vendor 1002
}

has_intel_gpu() {
    has_gpu_vendor 8086
}

cpu_vendor() {
    grep -m1 vendor_id /proc/cpuinfo | awk '{print $3}'
}

# --- Boot ---

# grub | systemd-boot | unknown
# /boot is root-only (0700), so look at packages and /etc instead of /boot itself
bootloader() {
    local entries

    # systemd-boot registers itself as "Linux Boot Manager"; no sudo needed (dry runs stay quiet).
    # Captured first, like has_gpu_vendor, so pipefail can't turn a match into a failure
    entries="$(efibootmgr 2>/dev/null)" || entries=""

    if [[ -f /etc/default/grub ]] && is_installed grub; then
        echo grub
    elif grep -q 'Linux Boot Manager' <<<"$entries"; then
        echo systemd-boot
    else
        echo unknown
    fi
}

# Kernel package names (linux, linux-lts, ...) for headers
installed_kernels() {
    cat "$KERNEL_MODULES_DIR"/*/pkgbase 2>/dev/null | sort -u
}

# --- Location ---

# "City,Country" for the system timezone, from tzdata (Europe/Moscow → Moscow,Russia); empty if unknown
timezone_city() {
    local zone
    local country_code
    local country
    local city

    zone=$(timedatectl show -p Timezone --value 2>/dev/null) || return 0

    # zone1970.tab may list several countries for one zone ("CH,DE"); the first one names it
    country_code=$(awk -F'\t' -v zone="$zone" '$3 == zone { print $1; exit }' /usr/share/zoneinfo/zone1970.tab)
    country_code="${country_code%%,*}"
    country=$(awk -F'\t' -v code="$country_code" '$1 == code { print $2; exit }' /usr/share/zoneinfo/iso3166.tab)

    city="${zone##*/}"
    city="${city//_/ }"

    if [[ -n "$country" ]]; then
        echo "$city,$country"
    fi
}
