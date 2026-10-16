# Scripts

Everything in [`dotfiles/bin`](https://github.com/Zilero232/arch-install-kit/tree/master/dotfiles/bin) is deployed to `~/bin`.

| Script                | Keys        | What it does                                                                   |
| --------------------- | ----------- | ------------------------------------------------------------------------------ |
| `power_menu.sh`       | `Super + X` | wlogout power menu sized to the focused monitor                                |
| `random_wallpaper.sh` | `Super + W` | sets a random image from `~/Images` via hyprpaper                              |
| `wallpaperengine.sh`  | autostart   | live wallpaper on every monitor; falls back to hyprpaper if not installed      |
| `toggle_waybar.sh`    | `Super + P` | hides or shows Waybar                                                          |
| `update_mirrors.sh`   | —           | picks the fastest pacman mirrors with reflector (keeps a backup of the list)   |
| `plymouth_theme.sh`   | —           | `list` / `set <theme>` for the boot splash                                     |
| `sddm_theme.sh`       | —           | `list` / `set <variant>` for the SDDM Astronaut login screen                   |
| `gtk_theme.sh`        | autostart   | applies the GTK theme, icons, cursor and font from `gtk-3.0/settings.ini`      |
| `anti_afk.sh`         | —           | nudges the cursor every 30–60 s so apps don't mark you as away; `Ctrl+C` stops |

## Waybar scripts

In `~/.config/waybar/scripts`:

| Script              | What it does                                                    |
| ------------------- | --------------------------------------------------------------- |
| `openweathermap.sh` | current weather; key and city in `~/.config/waybar/weather.env` |
| `check_updates.sh`  | number of repo and AUR updates                                  |
| `update_system.sh`  | click on the updates module: updates everything in a terminal   |
| `cava.sh`           | audio visualizer bars                                           |

## Hyprland scripts

`~/.config/hypr/scripts/monitor-auto.sh` (autostart) — mirrors the laptop panel to `DP-1` when it's connected and switches back when it isn't.
