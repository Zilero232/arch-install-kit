#!/usr/bin/env bash
# Deploys dotfiles/ (a mirror of $HOME) by copy or symlink. Replaced files go to ~/.config-backup/<date>.

if ((LINK_DOTFILES)); then
    dotfiles_link
else
    dotfiles_copy
fi

run mkdir -p "$HOME"/{Desktop,Documents,Downloads,Music,Videos,Projects,Screenshots,Images}
run cp --update=none "$KIT_DIR"/assets/images/* "$HOME/Images/"

run fc-cache -f
if [[ -d "$BACKUP_DIR" ]]; then
    info "Previous configs: $BACKUP_DIR"
fi
ok "Dotfiles deployed"
