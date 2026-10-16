#!/usr/bin/env bash
# Deploys dotfiles/ (a mirror of $HOME) by copy or symlink. Replaced files go to ~/.config-backup/<date>.

if ((LINK_DOTFILES)); then
    dotfiles_link
else
    dotfiles_copy
fi

run mkdir -p "$HOME"/{Desktop,Documents,Downloads,Music,Videos,Projects,Screenshots,Images}
run cp --update=none "$KIT_DIR"/assets/images/* "$HOME/Images/"

# Secrets live outside the repo (gitignored even in link mode)
weather_env="$HOME/.config/waybar/weather.env"
if [[ ! -f "$weather_env" ]] && ((!DRY_RUN)); then
    printf 'OPENWEATHER_API_KEY=\nOPENWEATHER_CITY_ID=468902\n' >"$weather_env"
    chmod 600 "$weather_env"
    info "Add your OpenWeatherMap key to $weather_env"
fi

run fc-cache -f
if [[ -d "$BACKUP_DIR" ]]; then
    info "Previous configs: $BACKUP_DIR"
fi
ok "Dotfiles deployed"
