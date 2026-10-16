# When something goes wrong

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

| Symptom                  | What to do                                                                |
| ------------------------ | ------------------------------------------------------------------------- |
| No icons in Waybar       | no Nerd Font installed: `yay -S ttf-jetbrains-mono-nerd && fc-cache -fv`  |
| A Waybar module is empty | run its command by hand, e.g. `wttrbar` or `waybar-module-pacman-updates` |
| Weather doesn't show     | wttr.in may be rate-limiting; try `curl wttr.in` and wait a bit           |
| No sound                 | `systemctl --user status pipewire wireplumber`, `wpctl status`            |

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
