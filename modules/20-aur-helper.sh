#!/usr/bin/env bash
# Bootstraps yay from the prebuilt yay-bin package (git and base-devel come from bootstrap.txt).

if command -v yay &>/dev/null; then
    ok "yay already installed"
    return 0
fi

tmp="$(mktemp -d)"
# The module runs in its own subshell, so this fires when the module ends, even on failure
trap 'rm -rf "$tmp"' EXIT

run git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"

if ((DRY_RUN)); then
    dry "makepkg -si in $tmp/yay-bin"
else
    (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
fi

ok "yay installed"
