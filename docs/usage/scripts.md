# Scripts

Only what no package does yet is a script. Everything in [`dotfiles/bin`](https://github.com/Zilero232/arch-install-kit/tree/master/dotfiles/bin) is deployed to `~/bin`.

| Script          | Keys                   | What it does                                                                                          |
| --------------- | ---------------------- | ----------------------------------------------------------------------------------------------------- |
| `power_menu.sh` | `Super + X`            | wlogout power menu sized to the focused monitor                                                       |
| `wallpaper.sh`  | autostart, `Super + W` | live Wallpaper Engine scene or a static picture (`random`, `pick`, `live`); remembers the last choice |
| `gtk_theme.sh`  | autostart              | applies the GTK theme, icons, cursor and font from `gtk-3.0/settings.ini`                             |
| `sddm_theme.sh` | —                      | `list` / `set <variant>` for the SDDM Astronaut login screen                                          |
| `anti_afk.sh`   | —                      | nudges the cursor every 30–60 s so apps don't mark you as away; `Ctrl+C` stops                        |

`~/.config/waybar/scripts/cava.sh` draws the audio visualizer bars (Arch's Waybar is built without its own cava module).

## Handled by packages and built-ins

| Task                        | Tool                                                                                                                  |
| --------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| Random wallpaper, picker    | [waypaper](https://github.com/anufrievroman/waypaper): `Super + W` (random), `Super + Ctrl + W` (picker)              |
| Hide / show Waybar          | `pkill -SIGUSR1 waybar` (`Super + P`)                                                                                 |
| Weather in Waybar           | [wttrbar](https://github.com/bjesus/wttrbar) — no API key, location by IP                                             |
| Pending updates in Waybar   | [waybar-module-pacman-updates](https://github.com/coffebar/waybar-module-pacman-updates); click runs `yay`            |
| Fastest mirrors             | `reflector.timer`, weekly, settings in `/etc/xdg/reflector/reflector.conf`                                            |
| Monitors                    | automatic: preferred mode, auto placement, scale by pixel density, hotplug (`hypr/conf/monitors.lua`)                 |
| VPN without a password      | INCY starts in the tray; a polkit rule (`/etc/polkit-1/rules.d/50-incy.rules`) lets only its own helper calls through |
| Power profiles              | power-profiles-daemon; click the profile icon in Waybar to cycle                                                      |
| Volume / brightness pop-ups | [swayosd](https://github.com/ErikReider/SwayOSD) on the media keys and Caps Lock                                      |
| Low battery warning         | [batsignal](https://github.com/electrickite/batsignal): notifications at 20% and 10%                                  |
| Dim before lock             | hypridle: dims after 5 min, locks after 10, screen off after 15                                                       |
| USB automount               | [udiskie](https://github.com/coldfix/udiskie)                                                                         |
| Clipboard after app quits   | [wl-clip-persist](https://github.com/Linus789/wl-clip-persist)                                                        |
| Swap                        | zram, half of RAM (`/etc/systemd/zram-generator.conf`)                                                                |
| Firewall                    | ufw: incoming denied, outgoing allowed; GUI in `gufw`                                                                 |
| Firmware updates            | `fwupdmgr update`; metadata refreshed by `fwupd-refresh.timer`                                                        |
| Old package cache           | `paccache.timer` keeps the last 3 versions                                                                            |
| Boot splash theme           | `plymouth_theme_list` / `plymouth_theme_set <name>` in fish                                                           |
