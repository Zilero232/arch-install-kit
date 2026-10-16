#!/usr/bin/env bash
# Summary of what needs attention.

if [[ -s "$FAILED_FILE" ]]; then
    warn "Not installed (check the name with: yay -Ss <name>):"
    sort -u "$FAILED_FILE" | sed 's/^/    /'
fi

info "Log: $LOG_FILE"
cat <<'TXT'

Next steps:
  1. reboot  ->  SDDM  ->  Hyprland
  2. hyprctl monitors all  ->  adjust ~/.config/hypr/conf/monitor.conf
  3. Steam  ->  Wallpaper Engine (otherwise hyprpaper is used)
  4. nwg-look  ->  check GTK theme, icons, cursor
  5. sudo timeshift --create --comments "fresh install"
TXT
