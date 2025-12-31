<div align="center">

# ⚙️ Hyprland Configuration Setup
### *Transfer dotfiles to a new system*

</div>

<br>

## 📋 Table of Contents

- [Requirements](#-requirements)
- [Clone Repository](#-clone-repository)
- [Install Packages](#-install-packages)
- [Transfer Configuration](#-transfer-configuration)
- [System Setup](#-system-setup)
- [Completion](#-completion)

---

## 🎯 Requirements

- ✅ Installed base Arch Linux ([Guide](./INSTALL_MANUALLY.md))
- ✅ Internet connection
- ✅ Configured `sudo`
- ✅ Installed `git` (`sudo pacman -S git`)

---

## 📥 Clone Repository

```bash
cd ~

git clone https://github.com/zilero232/arch-install-kit.git

cd arch-install-kit
```

---

## 📦 Install Packages

### 1. Enable multilib

```bash
sudo vim /etc/pacman.conf
# Uncomment:
# [multilib]
# Include = /etc/pacman.d/mirrorlist

sudo pacman -Sy
```

### 2. Base Components

```bash
# Wayland and Hyprland
sudo pacman -S wayland xorg-xwayland qt5-wayland qt6-wayland wl-clipboard
sudo pacman -S hyprland xdg-desktop-portal-hyprland

# Display Manager and boot splash
sudo pacman -S sddm plymouth

# Interface
sudo pacman -S waybar swaync wlogout nwg-look

# Terminal and shell
sudo pacman -S alacritty fish

# File managers
sudo pacman -S thunar thunar-archive-plugin ranger tree ueberzug

# Launcher and desktop utilities
sudo pacman -S rofi rofi-calc rofi-emoji
sudo pacman -S hyprpaper flameshot peek redshift gpick

# Audio system
sudo pacman -S pipewire pipewire-pulse pipewire-alsa pipewire-jack pipewire-bluetooth
sudo pacman -S wireplumber pavucontrol pamixer sound-theme-freedesktop

# Network
sudo pacman -S networkmanager network-manager-applet dhcpcd iwd openssh

# Bluetooth
sudo pacman -S bluez bluez-utils blueman bluez-hid2hci

# Base tools
sudo pacman -S git tmux lsd bat fastfetch base-devel

# System utilities
sudo pacman -S timeshift reflector pacman-contrib brightnessctl
```

### 3. Install yay

```bash
git clone https://aur.archlinux.org/yay.git

cd yay

makepkg -si --noconfirm

cd ~ && rm -rf yay
```

### 4. AUR Packages

```bash
yay -S neohtop plymouth-theme-deus-ex-git sddm-astronaut-theme s-tui fisher oh-my-posh
```

### 5. Graphics Drivers

**Intel:**
```bash
sudo pacman -S intel-ucode vulkan-intel xf86-video-intel
```

**NVIDIA:**
```bash
sudo pacman -S nvidia nvidia-utils nvidia-settings
```

**AMD:**
```bash
sudo pacman -S xf86-video-amdgpu vulkan-radeon amd-ucode
```

---

## 📁 Transfer Configuration

### 1. Create Directories

```bash
mkdir -p ~/Videos ~/Documents ~/Downloads ~/Music ~/Desktop ~/Projects ~/Screenshots ~/bin ~/Images
```

### 2. Copy Configs

```bash
cd ~/arch-install-kit

# Main configuration
cp -r dotfiles/.config/* ~/.config/

# GTK configuration
cp dotfiles/.gtkrc-2 ~/

# Scripts
cp -r bin ~/bin
chmod +x ~/bin/*.sh

# Wallpapers
cp -r assets/images ~/Images
```

### 3. System Configurations

```bash
# SDDM
sudo mkdir -p /etc/sddm.conf.d
sudo cp etc/sddm.conf.d/theme.conf /etc/sddm.conf.d/

# Plymouth (optional)
sudo mkdir -p /etc/systemd/system/plymouth-start.service.wants
sudo cp etc/systemd/system/plymouth-start.service.wants/plymouth-wait-for-animation.service \
  /etc/systemd/system/plymouth-start.service.wants/

# WireGuard sudoers (optional)
sudo cp etc/sudoers.d/wireguard /etc/sudoers.d/
sudo chmod 440 /etc/sudoers.d/wireguard
```

---

## ⚙️ System Setup

### 1. System Services

```bash
sudo systemctl enable sddm
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth
```

### 2. Fish Shell with Oh My Posh

```bash
chsh -s /usr/bin/fish
```

### 3. Themes and Wallpapers

```bash
# Plymouth boot splash
~/bin/plymouth_theme.sh set

# SDDM login screen
~/bin/sddm_theme.sh

# Desktop wallpapers
~/bin/random_wallpaper.sh
```

---

## ✅ Completion

```bash
# Reboot system
reboot
```

After reboot you will have a complete Hyprland setup with:
- Alacritty terminal with Fish shell and Oh My Posh
- Waybar panel
- SwayNC notifications
- Rofi launcher
- Hyprpaper for wallpapers
- Wlogout exit menu
- Custom scripts in `~/bin/`

---

## 📚 Documentation

- 🐟 [Fish Shell](./FISH_SHELL.md) - aliases and functions
- 🔧 [Shell Scripts](./SHELL_SCRIPTS.md) - scripts description
- 📦 [Software List](./ARCH_SOFTWARE.md) - all packages
- 🤖 [Automatic Install](./INSTALL_AUTO.md) - full system installation

---

<div align="center">

**🎉 Done! Enjoy Hyprland! 🚀**

[![Made with ❤️](https://img.shields.io/badge/Made%20with-❤️-red?style=for-the-badge)](https://github.com/zilero232/arch-install-kit)

</div>
