#!/usr/bin/env bash
# Deploys dotfiles/ (a mirror of $HOME) by copy or symlink. Replaced files go to ~/.config-backup/<date>.

if ((LINK_DOTFILES)); then
    dotfiles_link
else
    dotfiles_copy
fi

# Hyprland moved to Lua (hyprland.lua, conf/*.lua); copy mode leaves the old hyprlang
# files behind, so move them to the backup. hypridle/hyprlock/hyprpaper/hyprsunset keep .conf.
legacy_hypr=("$HOME"/.config/hypr/{hyprland,hyprtheme}.conf "$HOME"/.config/hypr/conf/*.conf)
for file in "${legacy_hypr[@]}"; do
    if [[ -f "$file" ]] && [[ ! -L "$HOME/.config/hypr" ]]; then
        run mkdir -p "$BACKUP_DIR/hypr-legacy"
        run mv "$file" "$BACKUP_DIR/hypr-legacy/"
    fi
done

run mkdir -p "$HOME"/{Desktop,Documents,Downloads,Music,Videos,Projects,Screenshots,Images}
run cp --update=none "$KIT_DIR"/assets/images/* "$HOME/Images/"

run fc-cache -f

# Papirus folders in the Kanagawa violet accent
if is_installed papirus-folders && ! papirus-folders -l --theme Papirus-Dark | grep -q '> violet'; then
    run sudo papirus-folders -C violet --theme Papirus-Dark
fi
if [[ -d "$BACKUP_DIR" ]]; then
    info "Previous configs: $BACKUP_DIR"
fi
ok "Dotfiles deployed"
