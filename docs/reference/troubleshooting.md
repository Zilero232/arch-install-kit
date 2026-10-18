# Troubleshooting

## Installation

| Symptom                         | What to do                                                                                                        |
| ------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| `install.sh` failed on a module | check the log `~/.local/state/arch-install-kit/install-*.log`, fix the issue, then `./install.sh --only <module>` |
| A package didn't install        | you'll get a list at the end; find the current name with `yay -Ss <keyword>` and fix it in `packages/*.txt`       |
| pacman signature errors         | `sudo pacman -Sy archlinux-keyring && sudo pacman -Su`                                                            |
| `pacman is locked`              | make sure pacman isn't running anywhere, then `sudo rm /var/lib/pacman/db.lck`                                    |

## Graphics and login

| Symptom                          | What to do                                                                                                                                                    |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Black screen after SDDM          | `Ctrl+Alt+F2` → log in → start `Hyprland` by hand and read the error; log: `~/.local/share/hyprland/hyprland.log` (or `$XDG_RUNTIME_DIR/hypr/*/hyprland.log`) |
| SDDM won't start                 | `journalctl -b -u sddm`                                                                                                                                       |
| Red Hyprland error bar           | it names the file and line; the syntax sometimes changes between updates — see [wiki.hypr.land](https://wiki.hypr.land)                                       |
| NVIDIA: flickering, black screen | check `cat /sys/module/nvidia_drm/parameters/modeset` → `Y`; cards older than GTX 16xx need `nvidia-580xx-dkms` from the AUR instead of `nvidia-open-dkms`    |

## Bar and apps

| Symptom                                               | What to do                                                                                                                                                                                                                                                                                                                                                                                  |
| ----------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| No icons in Waybar                                    | no Nerd Font installed: `yay -S ttf-jetbrains-mono-nerd && fc-cache -fv`                                                                                                                                                                                                                                                                                                                    |
| A Waybar module is empty                              | run its command by hand, e.g. `waybar-weather` or `waybar-module-pacman-updates`                                                                                                                                                                                                                                                                                                            |
| Weather doesn't show or shows another city            | run `waybar-weather` in a terminal to see its log; set your city in `~/.config/waybar-weather/cityname` (`City,Country`) and restart Waybar                                                                                                                                                                                                                                                 |
| No sound                                              | `systemctl --user status pipewire wireplumber`, `wpctl status`                                                                                                                                                                                                                                                                                                                              |
| Control-center night light or mic button does nothing | systemd user services read `~/.config/environment.d/` only at login, so `~/bin` isn't on their `PATH` yet: log out and back in, or run `systemctl --user restart swaync`                                                                                                                                                                                                                    |
| No notification sound                                 | Do Not Disturb mutes it: check `swaync-client --get-dnd`; test the sound with `pw-play /usr/share/sounds/freedesktop/stereo/message-new-instant.oga`                                                                                                                                                                                                                                        |
| AnyDesk windows are tiny, glitchy or wrongly scaled   | AnyDesk supports X11 only; the kit's launcher override ([`anydesk.desktop`](https://github.com/Zilero232/arch-install-kit/blob/master/dotfiles/.local/share/applications/anydesk.desktop)) runs it on XWayland with `GDK_SCALE=2 GDK_DPI_SCALE=0.8` for a 1.6-scale screen: on scale 1 drop both, on scale 2 keep only `GDK_SCALE=2`. Its prompts and settings float, the main window tiles |
| Nobody can control this machine through AnyDesk       | AnyDesk can't capture or control a Wayland session, only outgoing connections work; to be controlled, use [RustDesk](https://rustdesk.com) (`yay -S rustdesk-bin`), which supports Wayland through the screen-cast portal                                                                                                                                                                   |
| Layout switches after `Ctrl + Shift` + click          | a range select with the mouse (`Ctrl + Shift` or `Alt + Shift` + click) still switches the layout on release: Hyprland's Lua API has no mouse-button event, so the switch can't tell a click happened. Press the keys again to switch back                                                                                                                                                  |
| INCY asks for a password                              | the polkit rule is installed only when `incy-bin` is, and it allows only users in `wheel` on an active local session; check that `/etc/polkit-1/rules.d/50-incy.rules` exists and read `journalctl -b -u polkit`                                                                                                                                                                            |

## System

| Symptom                                             | What to do                                                                                                                                                                                                                                                              |
| --------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Snapshots fail or fill the disk                     | `sudo timeshift --list` shows the target; the installer uses `/home` only when it's a separate, bigger partition, otherwise `/`. Pick another disk in `timeshift-gtk`: the installer leaves a target other than `/` alone                                               |
| Every `pacman -Syu` aborts on the snapshot          | timeshift-autosnap stops the upgrade when its snapshot fails. Upgrade once with `sudo SKIP_AUTOSNAP=1 pacman -Syu`, then fix the target (`sudo timeshift --list`, `timeshift-gtk`), or turn the hook off with `skipAutosnap=true` in `/etc/timeshift-autosnap.conf`     |
| Video or OpenGL misbehave on a hybrid NVIDIA laptop | Older versions of the kit wrote `LIBVA_DRIVER_NAME=nvidia` and `__GLX_VENDOR_LIBRARY_NAME=nvidia` to `/etc/environment` on every NVIDIA machine; now that happens only when NVIDIA is the only GPU. Remove both lines with `sudoedit /etc/environment` and log in again |
| Wi-Fi gone after suspend (Qualcomm ath11k)          | check that `/usr/lib/systemd/system-sleep/ath11k` exists; if not, run `./install.sh --only system`                                                                                                                                                                      |
| A service on your LAN is unreachable                | ufw denies incoming connections: `sudo ufw allow <port>`, or use `gufw`                                                                                                                                                                                                 |

## Boot

| Symptom                                 | What to do                                                                                          |
| --------------------------------------- | --------------------------------------------------------------------------------------------------- |
| Windows missing from GRUB               | `sudo grub-mkconfig -o /boot/grub/grub.cfg` and look for "Found Windows Boot Manager" in the output |
| GRUB is gone, boots straight to Windows | boot from the USB stick, then see below                                                             |

Restoring GRUB from the USB stick:

```bash
lsblk -f                               # find root and EFI
mount /dev/nvme0n1pX /mnt              # root
mount /dev/nvme0n1pY /mnt/boot         # EFI
arch-chroot /mnt
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
exit && reboot
```

## Rolling back

- System files edited by install.sh are kept next to the originals with a `.kit.bak` suffix (`/etc/pacman.conf.kit.bak` and so on).
- Your old user configs are in `~/.config-backup/<date>/`.
- Timeshift snapshots: `sudo timeshift --list`, `sudo timeshift --restore`.
