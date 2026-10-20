#!/usr/bin/env bash
# Summary of what needs attention.

if [[ -s "$FAILED_FILE" ]]; then
    warn "Not installed (check the name with: yay -Ss <name>):"
    while read -r pkg; do
        info "$pkg"
    done < <(sort -u "$FAILED_FILE")
fi

info "Log: $LOG_FILE"

step "Next steps"
info "1. reboot  ->  SDDM  ->  Hyprland"
info "2. hyprctl monitors all  ->  adjust ~/.config/hypr/conf/monitors.lua"
info "3. Steam  ->  Wallpaper Engine (otherwise hyprpaper is used)"
info "4. nwg-look  ->  check GTK theme, icons, cursor"
info "5. sudo timeshift --create --comments \"fresh install\""
