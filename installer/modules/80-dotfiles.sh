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

# Home folders and the bundled wallpapers; existing pictures are never overwritten
run mkdir -p "$HOME"/{Desktop,Documents,Downloads,Music,Videos,Projects,Screenshots,Images}
run cp --update=none "$KIT_DIR"/assets/images/* "$HOME/Images/"

run fc-cache -f

# Papirus folders in the Kanagawa violet accent
if is_installed papirus-folders; then
    # Captured first: `| grep -q` under pipefail can fail on SIGPIPE and recolor every run
    folders="$(papirus-folders -l --theme Papirus-Dark)"

    if [[ "$folders" != *"> violet"* ]]; then
        run sudo papirus-folders -C violet --theme Papirus-Dark
    fi
fi

# swaync's brightness slider needs this machine's backlight device. rsync skips the file
# (dotfiles_copy); it is rendered from the repo copy and written only when it changed.
# Link mode keeps the repo's device (see docs/install/04-run-installer.md).
if ((!LINK_DOTFILES)); then
    rendered="$(swaync_config_render)"
    update_home_file "$SWAYNC_CONFIG" <<<"$rendered"
fi

# Weather fallback location when Wi-Fi lookup has no data; never overwrites your own edit
weather_city="$HOME/.config/waybar-weather/cityname"
if [[ ! -f "$weather_city" ]]; then
    city="$(timezone_city)"

    if [[ -n "$city" ]]; then
        run mkdir -p "$(dirname "$weather_city")"
        run tee "$weather_city" >/dev/null <<<"$city"
        info "Weather location: $city (edit $weather_city if needed)"
    fi
fi

# Chrome opens links from every app (Telegram, the terminal, xdg-open)
if is_installed google-chrome; then
    browser="$(xdg-settings get default-web-browser 2>/dev/null)" || browser=""

    if [[ "$browser" != google-chrome.desktop ]]; then
        run xdg-settings set default-web-browser google-chrome.desktop
    fi
fi

# VS Code opens text files from xdg-open and Tabby's SFTP panel, not LibreOffice Writer
if is_installed visual-studio-code-bin; then
    text_types=(
        text/plain text/markdown text/x-log
        application/json application/yaml application/x-yaml application/toml
        application/x-shellscript application/x-zerosize
    )

    for type in "${text_types[@]}"; do
        editor="$(xdg-mime query default "$type" 2>/dev/null)" || editor=""

        if [[ "$editor" != com.microsoft.VSCode.desktop ]]; then
            run xdg-mime default com.microsoft.VSCode.desktop "$type"
        fi
    done
fi

if [[ -d "$BACKUP_DIR" ]]; then
    info "Previous configs: $BACKUP_DIR"
fi

ok "Dotfiles deployed"
