#!/usr/bin/env bash
# Fish as the login shell.

if is_installed fish && [[ "$(getent passwd "$USER" | cut -d: -f7)" != /usr/bin/fish ]]; then
    run sudo chsh -s /usr/bin/fish "$USER"
fi

ok "Shell ready"
