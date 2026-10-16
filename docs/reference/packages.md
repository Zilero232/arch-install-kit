# Packages

The lists live in [`packages/`](https://github.com/Zilero232/arch-install-kit/tree/master/packages), one file per group. They're the single source of truth: install.sh reads them directly.

## Groups

| Group                                                                                         | What's inside                                                                  | Installed  |
| --------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ | ---------- |
| [`base`](https://github.com/Zilero232/arch-install-kit/blob/master/packages/base.txt)         | networking, Bluetooth, power (TLP), archivers, backups, build tools            | always     |
| [`hyprland`](https://github.com/Zilero232/arch-install-kit/blob/master/packages/hyprland.txt) | Hyprland and its ecosystem, portals, clipboard, screenshots, SDDM, Plymouth    | always     |
| [`desktop`](https://github.com/Zilero232/arch-install-kit/blob/master/packages/desktop.txt)   | Waybar, Rofi, notifications, terminal, fish, file managers, browsers, Telegram | always     |
| [`audio`](https://github.com/Zilero232/arch-install-kit/blob/master/packages/audio.txt)       | PipeWire, mixers, media player control, visualizer                             | always     |
| [`fonts`](https://github.com/Zilero232/arch-install-kit/blob/master/packages/fonts.txt)       | Nerd Fonts, Noto, emoji                                                        | always     |
| [`themes`](https://github.com/Zilero232/arch-install-kit/blob/master/packages/themes.txt)     | Kanagawa GTK theme and icons, Hackneyed cursor, gowall                         | always     |
| [`apps`](https://github.com/Zilero232/arch-install-kit/blob/master/packages/apps.txt)         | password manager, Incy proxy client, disks, calendar, messengers               | by default |
| [`dev`](https://github.com/Zilero232/arch-install-kit/blob/master/packages/dev.txt)           | IDEs, Docker, languages, databases, VirtualBox                                 | by default |
| [`media`](https://github.com/Zilero232/arch-install-kit/blob/master/packages/media.txt)       | players, music, graphics, OBS                                                  | by default |
| [`office`](https://github.com/Zilero232/arch-install-kit/blob/master/packages/office.txt)     | LibreOffice, PDF, Obsidian                                                     | by default |
| [`gaming`](https://github.com/Zilero232/arch-install-kit/blob/master/packages/gaming.txt)     | Steam                                                                          | by default |

`--minimal` installs only the "always" groups; `--groups dev,media` installs those plus the ones you list.

[`conflicts.txt`](https://github.com/Zilero232/arch-install-kit/blob/master/packages/conflicts.txt) lists packages that get removed **before** installation (PulseAudio, other notification daemons).

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

| Before                       | After                                | Why                                  |
| ---------------------------- | ------------------------------------ | ------------------------------------ |
| flameshot                    | hyprshot + grim + slurp              | native Hyprland screenshots          |
| redshift                     | hyprsunset                           | night light on Wayland               |
| gpick                        | hyprpicker                           | color picker                         |
| peek                         | wf-recorder                          | screen recording                     |
| xdotool                      | `hyprctl dispatch`                   | cursor/window control                |
| polkit-gnome                 | hyprpolkitagent                      | password prompt dialog               |
| ueberzug                     | ueberzugpp                           | image previews in ranger             |
| p7zip                        | 7zip                                 | p7zip was dropped from the repos     |
| ttf-font-awesome             | woff2-font-awesome                   | renamed in the repos                 |
| virtualbox-host-modules-arch | virtualbox-host-dkms + linux-headers | modules are now DKMS-only            |
| neohtop                      | neohtop-bin                          | the original AUR package is orphaned |

`xorg-server` stays: the SDDM theme runs on X11.
