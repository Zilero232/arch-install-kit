# Packages

The lists live in [`installer/packages/`](https://github.com/Zilero232/arch-install-kit/tree/master/installer/packages), one file per group. They're the single source of truth: install.sh reads them directly.

## Groups

| Group                                                                                                   | What's inside                                                                                                                            | Installed  |
| ------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| [`base`](https://github.com/Zilero232/arch-install-kit/blob/master/installer/packages/base.txt)         | networking, Bluetooth, firewall, keyring, power profiles, battery alerts, zram, firmware updates, backups, disk health and VA-API checks | always     |
| [`hyprland`](https://github.com/Zilero232/arch-install-kit/blob/master/installer/packages/hyprland.txt) | Hyprland and its ecosystem, portals, clipboard, screenshots + satty, OSD, OCR, SDDM, Plymouth, Wallpaper Engine                          | always     |
| [`desktop`](https://github.com/Zilero232/arch-install-kit/blob/master/installer/packages/desktop.txt)   | Waybar, Rofi, swaync, terminal, fish and CLI tools (fzf, zoxide…), file managers, calcurse, browsers, Telegram, GStreamer codecs         | always     |
| [`audio`](https://github.com/Zilero232/arch-install-kit/blob/master/installer/packages/audio.txt)       | PipeWire, pavucontrol, media player control, cava visualizer, notification sounds                                                        | always     |
| [`fonts`](https://github.com/Zilero232/arch-install-kit/blob/master/installer/packages/fonts.txt)       | JetBrainsMono Nerd Font, Fira Code, Noto (with emoji and CJK)                                                                            | always     |
| [`themes`](https://github.com/Zilero232/arch-install-kit/blob/master/installer/packages/themes.txt)     | Kanagawa GTK theme, Papirus icons (violet folders), Hackneyed cursor, gowall                                                             | always     |
| [`apps`](https://github.com/Zilero232/arch-install-kit/blob/master/installer/packages/apps.txt)         | INCY VPN, KeePassXC, VeraCrypt, firewall GUI, disk tools, calculator, clocks, torrents, Discord, Zoom, AnyDesk                           | by default |
| [`dev`](https://github.com/Zilero232/arch-install-kit/blob/master/installer/packages/dev.txt)           | IDEs, Docker, languages, database clients (DBeaver, TablePlus), SSH client (Tabby), VirtualBox                                           | by default |
| [`media`](https://github.com/Zilero232/arch-install-kit/blob/master/installer/packages/media.txt)       | players, music, graphics, OBS                                                                                                            | by default |
| [`office`](https://github.com/Zilero232/arch-install-kit/blob/master/installer/packages/office.txt)     | LibreOffice, PDF, Obsidian, spell checking (en, ru)                                                                                      | by default |
| [`gaming`](https://github.com/Zilero232/arch-install-kit/blob/master/installer/packages/gaming.txt)     | Steam, Proton-GE (ProtonUp-Qt), Heroic, Lutris, Wine, GameMode, MangoHud, gamescope, controller udev rules                               | by default |
| [`printing`](https://github.com/Zilero232/arch-install-kit/blob/master/installer/packages/printing.txt) | CUPS, driverless network and USB printers, scanning (sane-airscan, Simple Scan), mDNS discovery                                          | by default |

`--minimal` installs only the "always" groups; `--groups dev,media` installs those plus the ones you list.

[`conflicts.txt`](https://github.com/Zilero232/arch-install-kit/blob/master/installer/packages/conflicts.txt) lists packages that get removed **before** installation (PulseAudio, other notification daemons, TLP).

## Format

```text
# a comment
package1 package2 package3
package4            # this works too
```

- Official repo and AUR packages can be mixed freely: `yay` sorts it out.
- Drivers and microcode are **not** in the lists — the `gpu` module picks them based on your hardware.

Why `.txt` and not JSON/YAML: the file is read by plain bash on a freshly installed system that doesn't have `jq`/`yq` yet, it supports comments, and git diffs are line-based. [Omarchy](https://github.com/basecamp/omarchy) (`.packages`) and plenty of dotfiles repos do the same.

## Adding a package

1. Check the name: `yay -Ss <keyword>` or [archlinux.org/packages](https://archlinux.org/packages/) / [aur.archlinux.org](https://aur.archlinux.org).
2. Add it to the matching group.
3. Install it: `./install.sh --only packages`.

## Why these packages

This is a Wayland setup, so X11 tools are swapped for native ones:

| Before                       | After                          | Why                                  |
| ---------------------------- | ------------------------------ | ------------------------------------ |
| flameshot                    | hyprshot + satty               | native screenshots with annotation   |
| redshift                     | hyprsunset                     | night light on Wayland               |
| gpick                        | hyprpicker                     | color picker                         |
| peek                         | wf-recorder                    | screen recording                     |
| xdotool                      | `hyprctl dispatch 'hl.dsp.…'`  | cursor/window control                |
| polkit-gnome                 | hyprpolkitagent                | password prompt dialog               |
| ueberzug                     | ueberzugpp                     | image previews in ranger             |
| p7zip                        | 7zip                           | p7zip was dropped from the repos     |
| virtualbox-host-modules-arch | virtualbox-host-dkms + headers | modules are now DKMS-only            |
| neohtop                      | neohtop-bin                    | the original AUR package is orphaned |
| tlp                          | power-profiles-daemon          | profiles in Waybar, amd/intel pstate |
| network-manager-applet       | nm-connection-editor           | only the editor was used             |

`xorg-server` stays: the SDDM theme runs on X11.
