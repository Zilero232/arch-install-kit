#!/usr/bin/env bash
# Removes conflicting packages, then installs every selected group from packages/.

pkg_remove_conflicts

for group in "${PKG_GROUPS[@]}"; do
    pkg_install_list "$group"
done

# DKMS modules (VirtualBox) build against the headers of every installed kernel
if is_installed virtualbox-host-dkms; then
    headers=()
    while read -r kernel; do
        headers+=("$kernel-headers")
    done < <(installed_kernels)
    pkg_install "${headers[@]}"
fi

ok "Packages done"
