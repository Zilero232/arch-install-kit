#!/bin/bash
# Fish as login shell, fisher plugins, bun.

if is_installed fish && [ "$(getent passwd "$USER" | cut -d: -f7)" != /usr/bin/fish ]; then
    run sudo chsh -s /usr/bin/fish "$USER"
fi

if is_installed fisher; then
    run fish -c 'fisher update' || warn "fisher update failed: run it later inside fish"
fi

if [ ! -x "$HOME/.bun/bin/bun" ]; then
    if ((DRY_RUN)); then
        info "[dry] install bun"
    else
        curl -fsSL https://bun.sh/install | bash || warn "bun install failed"
    fi
fi
ok "Shell ready"
