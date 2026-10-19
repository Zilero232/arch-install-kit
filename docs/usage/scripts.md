# Scripts

Only what no package does yet is a script. Everything in [`dotfiles/bin`](https://github.com/Zilero232/arch-install-kit/tree/master/dotfiles/bin) is deployed to `~/bin`.

| Script                  | Keys                                                            | What it does                                                                                          |
| ----------------------- | --------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| `power_menu.sh`         | `Super + X`                                                     | wlogout power menu sized to the focused monitor                                                       |
| `wallpaper.sh`          | autostart, `Super + W`, `Super + Ctrl + W`, `Super + Shift + W` | live Wallpaper Engine scene or a static picture (`random`, `pick`, `live`); remembers the last choice |
| `gtk_theme.sh`          | autostart                                                       | applies the GTK theme, icons, cursor and font from `gtk-3.0/settings.ini`                             |
| `sddm_theme.sh`         | —                                                               | `list` / `set <variant>` for the SDDM Astronaut login screen                                          |
| `anti_afk.sh`           | —                                                               | nudges the cursor every 30–60 s so apps don't mark you as away; `Ctrl+C` stops                        |
| `notification_sound.sh` | swaync                                                          | plays the message sound for new notifications, silent in Do not disturb                               |
| `quick_toggle.sh`       | swaync buttons                                                  | night light and microphone toggles: `quick_toggle.sh night\|mic [status]`                             |

`~/.config/waybar/scripts/cava.sh` draws the audio visualizer bars (Arch's Waybar is built without its own cava module).

## Handled by packages and built-ins

### Desktop

| Task                        | Tool                                                                                                                                                                                                                        |
| --------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Random wallpaper, picker    | [waypaper](https://github.com/anufrievroman/waypaper) + hyprpaper, called by `wallpaper.sh` (`Super + W`, `Super + Ctrl + W`)                                                                                               |
| Hide / show Waybar          | `pkill -SIGUSR1 waybar` (`Super + P`)                                                                                                                                                                                       |
| Weather in Waybar           | [waybar-weather](https://github.com/wneessen/waybar-weather) — Open-Meteo, no API key; location from Wi-Fi (beaconDB) or `~/.config/waybar-weather/cityname`                                                                |
| Pending updates in Waybar   | [waybar-module-pacman-updates](https://github.com/coffebar/waybar-module-pacman-updates); click runs `yay`                                                                                                                  |
| Monitors                    | automatic: preferred mode, auto placement, scale by pixel density, hotplug (`hypr/conf/monitors.lua`)                                                                                                                       |
| Volume / brightness pop-ups | [swayosd](https://github.com/ErikReider/SwayOSD) on the media keys and Caps Lock                                                                                                                                            |
| Low battery warning         | [batsignal](https://github.com/electrickite/batsignal): notifications at 20% and 10%                                                                                                                                        |
| Dim, lock, sleep            | hypridle: dims after 5 min, locks after 10, screen off after 15, suspends after 30 on battery (never on AC)                                                                                                                 |
| USB automount               | [udiskie](https://github.com/coldfix/udiskie)                                                                                                                                                                               |
| Clipboard after app quits   | [wl-clip-persist](https://github.com/Linus789/wl-clip-persist)                                                                                                                                                              |
| Night light                 | hyprsunset: 4500 K from 20:00, 6500 K from 07:00; toggle from the swaync control center                                                                                                                                     |
| AnyDesk on Wayland          | a launcher override (`~/.local/share/applications/anydesk.desktop`) runs the X11-only app on XWayland, scaled for a 1.6 screen; outgoing sessions only, see [troubleshooting](../reference/troubleshooting.md#bar-and-apps) |
| Notification center         | swaync (`Super + N`); a sound plays on new notifications unless Do not disturb is on                                                                                                                                        |

### System

| Task                      | Tool                                                                                                                                                                                                                            |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Snapshots before upgrades | Timeshift (rsync) + timeshift-autosnap: one snapshot before each `pacman -Syu` (at most every 18 h, last 3 kept); stored on `/home` when it is a separate, bigger partition; `/home`, the package cache and Docker are excluded |
| Swap                      | zram, half of RAM (`/etc/systemd/zram-generator.conf`), swap tuned for it (`/etc/sysctl.d/99-vm-zram-parameters.conf`), zswap off                                                                                               |
| Firewall                  | ufw: incoming denied, outgoing allowed; GUI in `gufw`                                                                                                                                                                           |
| Suspend with ath11k Wi-Fi | a sleep hook unloads the Qualcomm driver around suspend (installed only on that hardware)                                                                                                                                       |
| Firmware updates          | `fwupdmgr update`; metadata refreshed by `fwupd-refresh.timer`                                                                                                                                                                  |
| Old package cache         | `paccache.timer` keeps the last 3 versions                                                                                                                                                                                      |
| VPN without a password    | INCY starts in the tray; a polkit rule (`/etc/polkit-1/rules.d/50-incy.rules`) lets only its own helper calls through                                                                                                           |
| Power profiles            | power-profiles-daemon; hover the CPU icon in Waybar to open the system drawer, then click the profile icon to cycle                                                                                                             |
| Fastest mirrors           | `reflector.timer`, weekly, settings in `/etc/xdg/reflector/reflector.conf`                                                                                                                                                      |
| Boot splash theme         | `plymouth-theme-arch-logo`; switch with `plymouth_theme_list` / `plymouth_theme_set <name>` in fish                                                                                                                             |

swaync buttons and scripts call these as `~/bin/<name>`: systemd user services such as swaync don't have `~/bin` on their `PATH`.
