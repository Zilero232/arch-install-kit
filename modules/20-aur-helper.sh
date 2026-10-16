#!/bin/bash
# Bootstraps yay from the prebuilt yay-bin package.

if command -v yay &>/dev/null; then
    ok "yay already installed"
    return 0
fi

run sudo pacman -S --needed --noconfirm git base-devel

tmp="$(mktemp -d)"
run git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
if ((DRY_RUN)); then
    info "[dry] makepkg -si in $tmp/yay-bin"
else
    (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
fi
rm -rf "$tmp"
ok "yay installed"
