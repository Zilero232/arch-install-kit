# 5. After installation

```bash
reboot
```

SDDM → **Hyprland** session → log in.

## 5.1. Tune it for your hardware

**Monitors.** Nothing to do: every monitor gets its preferred mode, a scale that matches its pixel density (1.6 on a 16" 2560×1600 panel) and is placed automatically, including ones you plug in later. If you want a fixed layout, refresh rate or scale, list your outputs with `hyprctl monitors all` and add rules to `~/.config/hypr/conf/monitors.lua`.

**Waybar weather.** Works out of the box, no API key: [waybar-weather](https://github.com/wneessen/waybar-weather) takes the forecast from [Open-Meteo](https://open-meteo.com) and finds you by nearby Wi-Fi networks ([beaconDB](https://beacondb.net)). Where beaconDB has no data, it uses `~/.config/waybar-weather/cityname`, which the installer fills from your timezone (`Moscow,Russia`). Lookups by IP are off, because behind a VPN they report the VPN server's city. If the city is wrong, edit that file (`City,Country`) and restart Waybar. Click the weather to see the forecast.

**Live wallpapers.** You need Steam and a purchased copy of Wallpaper Engine. Without it, static wallpapers from `~/Images` are used automatically via hyprpaper.

1. Steam → install **Wallpaper Engine**.
2. Subscribe to a wallpaper in the Workshop and put its ID into `WALLPAPER_ID` at the top of `~/bin/wallpaper.sh`.

`Super + W` switches to a random static picture, `Super + Ctrl + W` lets you pick one in waypaper, and `Super + Shift + W` goes back to the live scene; the last choice is kept after a reboot.

**Themes.** Open `nwg-look` and check the `Kanagawa-Purple-Dark` GTK theme, `Papirus-Dark` icons and the `Hackneyed` cursor.

**Keyboard layout.** us and ru; tap `Alt + Shift` or `Ctrl + Shift` and let go to switch. To change the layouts, edit `kb_layout` in `~/.config/hypr/conf/input.lua`.

**Night light.** hyprsunset turns the screen to 4500 K at 20:00 and back at 07:00; change the times in `~/.config/hypr/hyprsunset.conf`.

## 5.2. Restore your data from the backup

```bash
tar xzf /path/to/reinstall-backup.tar.gz -C ~
cd ~/reinstall-backup

cp -a ssh ~/.ssh && chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_*
cp -a gnupg ~/.gnupg 2>/dev/null && chmod 700 ~/.gnupg
cp gitconfig ~/.gitconfig 2>/dev/null
cp fish_history ~/.local/share/fish/ 2>/dev/null
cp --update=none images/* ~/Images/
```

PostgreSQL:

```bash
sudo -u postgres initdb -D /var/lib/postgres/data
sudo systemctl enable --now postgresql
sudo -u postgres psql -f ~/reinstall-backup/pg_dump.sql
```

## 5.3. Make sure everything works

- [ ] Waybar: weather, updates, audio, network, battery; Bluetooth in the tray
- [ ] `Super + Enter` — terminal with fish and the oh-my-posh prompt
- [ ] `Super + D` — Rofi
- [ ] `Super + L` — lock screen, `Super + X` — power menu
- [ ] `Super + S` / `Super + Shift + S` — screenshots
- [ ] Volume and brightness keys
- [ ] `notify-send test hello` — a notification with a sound; `Super + N` opens the control center
- [ ] `Alt + Shift` — the layout indicator in Waybar switches between us and ru
- [ ] `sudo ufw status` — firewall active; `zramctl` — zram swap
- [ ] Windows in the GRUB menu (if you have it)

All keybindings are in [usage/keybindings.md](../usage/keybindings.md).

## 5.4. Snapshot the clean system

```bash
sudo timeshift --create --comments "fresh install"
```

Something not working? See [troubleshooting](../reference/troubleshooting.md).

---

**Next:** [Keybindings →](../usage/keybindings.md)
