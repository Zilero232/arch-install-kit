---
layout: home

hero:
  name: Arch Install Kit
  text: Hyprland on Arch, one command away
  tagline: A modular installer, curated packages and Kanagawa-themed dotfiles. From a blank USB stick to a finished desktop.
  image:
    src: /hyrpland_preview.png
    alt: Hyprland desktop
  actions:
    - theme: brand
      text: Get started
      link: /install/01-backup
    - theme: alt
      text: Already on Arch?
      link: /install/04-run-installer
    - theme: alt
      text: GitHub
      link: https://github.com/Zilero232/arch-install-kit

features:
  - icon: ⚡
    title: One command
    details: ./install.sh installs packages, drivers, configs, boot splash and services. Re-run it any time, nothing breaks.
  - icon: 🧩
    title: Modular
    details: Every step is a small script in modules/. Run one with --only, skip one with --skip, preview all with --dry-run.
  - icon: 🖥️
    title: Detects your hardware
    details: Intel, AMD or NVIDIA drivers and CPU microcode are picked automatically. Windows shows up in GRUB.
  - icon: 🌊
    title: Wayland-native
    details: Hyprland with hyprlock, hypridle, hyprshot, hyprsunset and cliphist. No X11 leftovers.
  - icon: 🎨
    title: Kanagawa everywhere
    details: One palette across GTK, icons, Waybar, Rofi, Alacritty and the login screen.
  - icon: 🛟
    title: Safe by default
    details: System files are backed up before the first edit, replaced configs go to ~/.config-backup.
---

## Quick start

On a fresh Arch install (archinstall, **Minimal** profile), as your user:

```bash
sudo pacman -S --needed git
git clone https://github.com/Zilero232/arch-install-kit.git ~/arch-install-kit
cd ~/arch-install-kit
./install.sh
```

Reboot, pick **Hyprland** in SDDM — done.

## Screenshots

|                                       |                                       |
| ------------------------------------- | ------------------------------------- |
| ![Waybar](/waybar_preview.png)        | ![Rofi](/application_manager.png)     |
| ![Terminals](/several_terminals.png)  | ![Files](/file_explorer.png)          |
| ![Ranger](/file_manager_cli.png)      | ![Calendar](/calendar_calculator.png) |
| ![Fastfetch](/system_information.png) | ![Wlogout](/wlogout_preview.png)      |
