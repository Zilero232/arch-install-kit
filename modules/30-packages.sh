#!/bin/bash
# Removes conflicting packages, then installs every selected group from packages/.

pkg_remove_conflicts

for group in "${PKG_GROUPS[@]}"; do
    pkg_install_list "$group"
done
ok "Packages done"
