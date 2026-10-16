# 5. After installation

```bash
reboot
```

SDDM → **Hyprland** session → log in.

## 5.1. Tune it for your hardware

**Monitors.** The config targets an `eDP-1 2560x1600@120` laptop panel plus an external `DP-1`. Check yours:

```bash
hyprctl monitors all
```

Then adjust `~/.config/hypr/conf/monitor.conf` and `~/.config/hypr/scripts/monitor-auto.sh`.

**Waybar weather.** Grab a free key at [openweathermap.org](https://home.openweathermap.org/api_keys) and add it:

```bash
nano ~/.config/waybar/weather.env
# OPENWEATHER_API_KEY=your_key
# OPENWEATHER_CITY_ID=468902    # city ID from openweathermap.org
```

**Live wallpapers.** You need Steam and a purchased copy of Wallpaper Engine. Without it, static wallpapers from `~/Images` are used automatically via hyprpaper.

1. Steam → install **Wallpaper Engine**.
2. Subscribe to wallpapers in the Workshop and put their IDs at the top of `~/bin/wallpaperengine.sh`.

**Themes.** Open `nwg-look` and check the `Kanagawa` GTK theme, icons and the `Hackneyed` cursor.

## 5.2. Restore your data from the backup

```bash
tar xzf /path/to/reinstall-backup.tar.gz -C ~
cd ~/reinstall-backup

cp -a ssh ~/.ssh && chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_*
cp -a gnupg ~/.gnupg 2>/dev/null && chmod 700 ~/.gnupg
cp gitconfig ~/.gitconfig 2>/dev/null
cp weather.env ~/.config/waybar/ 2>/dev/null
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

- [ ] Waybar: weather, updates, audio, network, Bluetooth
- [ ] `Super+Enter` — terminal with fish and the oh-my-posh prompt
- [ ] `Super+D` — Rofi
- [ ] `Super+L` — lock screen, `Super+X` — power menu
- [ ] `Super+S` / `Super+Shift+S` — screenshots
- [ ] Volume and brightness keys
- [ ] `notify-send test hello` — a notification
- [ ] Windows in the GRUB menu (if you have it)

All keybindings are in [usage/keybindings.md](../usage/keybindings.md).

## 5.4. Snapshot the clean system

```bash
sudo timeshift --create --comments "fresh install"
```

Something not working? See [troubleshooting](../reference/troubleshooting.md).
