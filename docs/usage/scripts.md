# Scripts

Only what no package does yet is a script. Everything in [`dotfiles/bin`](https://github.com/Zilero232/arch-install-kit/tree/master/dotfiles/bin) is deployed to `~/bin`.

| Script               | Keys        | What it does                                                                   |
| -------------------- | ----------- | ------------------------------------------------------------------------------ |
| `power_menu.sh`      | `Super + X` | wlogout power menu sized to the focused monitor                                |
| `wallpaperengine.sh` | autostart   | live wallpaper on every monitor; falls back to hyprpaper if not installed      |
| `gtk_theme.sh`       | autostart   | applies the GTK theme, icons, cursor and font from `gtk-3.0/settings.ini`      |
| `sddm_theme.sh`      | —           | `list` / `set <variant>` for the SDDM Astronaut login screen                   |
| `anti_afk.sh`        | —           | nudges the cursor every 30–60 s so apps don't mark you as away; `Ctrl+C` stops |

`~/.config/waybar/scripts/cava.sh` draws the audio visualizer bars (Arch's Waybar is built without its own cava module).

## Handled by packages and built-ins

| Task                      | Tool                                                                                                       |
| ------------------------- | ---------------------------------------------------------------------------------------------------------- |
| Random wallpaper, picker  | [waypaper](https://github.com/anufrievroman/waypaper): `Super + W`, or run `waypaper`                      |
| Hide / show Waybar        | `pkill -SIGUSR1 waybar` (`Super + P`)                                                                      |
| Weather in Waybar         | [wttrbar](https://github.com/bjesus/wttrbar) — no API key, location by IP                                  |
| Pending updates in Waybar | [waybar-module-pacman-updates](https://github.com/coffebar/waybar-module-pacman-updates); click runs `yay` |
| Fastest mirrors           | `reflector.timer`, weekly, settings in `/etc/xdg/reflector/reflector.conf`                                 |
| Monitors                  | automatic: preferred mode, auto placement, hotplug (`hypr/conf/monitor.conf`)                              |
| Boot splash theme         | `plymouth_theme_list` / `plymouth_theme_set <name>` in fish                                                |
