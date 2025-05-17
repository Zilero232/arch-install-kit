# Arch Linux System Software

## 1. System Components

### Graphics System

- `xorg-server` - X Window System server
- `xorg-xinit` - X-server initialization
- `xorg-xbacklight` - Brightness control
- `arandr` - Monitor configuration GUI
- `picom` - Composite manager

### Display Manager

- `plymouth` - Boot splash screen
- `plymouth-theme-deus-ex-git` - Plymouth theme [AUR]

- `sddm` - Login manager
- `sddm-astronaut-theme` - SDDM theme [AUR]

### Window Manager

- `bspwm` - Tiling window manager
- `sxhkd` - Hotkey daemon
- `polybar` - Status bar
- `dunst` - Notification system
- `i3lock-color` - Screen locker [AUR]
- `betterlockscreen` - Screen locker [AUR]
- `wlogout` - Logout menu [AUR]

### Audio System

- `pipewire` - Modern audio server
- `pipewire-pulse` - PulseAudio replacement
- `pipewire-alsa` - ALSA integration
- `pipewire-jack` - JACK integration
- `wireplumber` - Session manager for PipeWire
- `pavucontrol` - Audio mixer
- `pamixer` - CLI audio control
- `sound-theme-freedesktop` - Standard system sounds

### Network System

- `networkmanager` - Network management
- `network-manager-applet` - Network GUI
- `dhcpcd` - DHCP client
- `iwd` - WiFi daemon
- `openssh` - SSH server/client
- `wireshark-qt` - Network analysis
- `net-tools` - Classic network utilities (netstat, ifconfig)
- `wireguard-tools` - WireGuard VPN client/server tools

### Bluetooth

- `bluez` - Bluetooth stack
- `bluez-utils` - Bluetooth utilities
- `blueman` - GUI manager
- `bluez-hid2hci` - HID support

## 2. System Management

### System Utilities

- `xfce4-settings` - System settings
- `timeshift` - System backups
- `bleachbit` - System cleaner
- `gnome-disk-utility` - Disk management
- `reflector` - Mirror management
- `pacman-contrib` - Pacman utilities

### System Monitoring

- `htop` - Process viewer
- `btop` - Resource monitor
- `cpupower` - CPU frequency control
- `s-tui` - CPU stress test and monitoring [AUR]

### Power Management

- `brightnessctl` - Brightness control
- `tlp` - Power saving
- `tlp-rdw` - Radio devices
- `xfce4-power-manager` - Power management

## 3. User Environment

### Virtualization

- `virtualbox` - VirtualBox main package

### Terminals

- `xterm` - Basic terminal
- `alacritty` - Modern terminal

### Command Line

- `fish` - Shell
- `fisher` - Fish plugin manager
- `tmux` - Terminal multiplexer
- `lsd` - Enhanced ls
- `bat` - Enhanced cat

### File Managers

- `thunar` - GUI manager
- `thunar-archive-plugin` - Archives in Thunar
- `ranger` - CLI manager
- `tree` - Directory viewer
- `ueberzug` - Image preview
- `xclip` - Clipboard manager

### Application Launchers

- `rofi` - Launcher
- `rofi-calc` - Calculator
- `rofi-emoji` - Emoji picker

### Desktop

- `nitrogen` - Wallpaper manager
- `flameshot` - Screenshots
- `peek` - GIF recorder
- `redshift` - Color temperature
- `gpick` - Color picker
- `cheese` - Webcam
- `gnome-calculator` - Calculator
- `gnome-clocks` - Clocks
- `obs-studio` - Screen recording

## 4. Development

### Editors

- `code` - VS Code
- `neovim` - Vim editor
- `cursor-bin` - AI IDE [AUR]
- `phpstorm` - PHP IDE [AUR] [VPN]
- `phpstorm-jre` - Java Runtime for PhpStorm [AUR] [VPN]

### Development Tools

- `git` - Version control
- `github-cli` - GitHub CLI
- `docker` - Containers
- `docker-compose` - Container management
- `postman-bin` - API testing [AUR]
- `shellcheck` - Script checker
- `cloc` - Code counter
- `fakeroot` - Root simulation
- `filezilla` - FTP client
- `jq` - JSON utility
- `meson` - Build system
- `composer` - PHP dependencies
- `meld` - Visual diff and merge tool

### Programming Languages

- Python:
  - `python` - Interpreter
  - `python-pip` - Package manager
  - `bpython` - REPL
  - `ipython` - Shell
- Node.js:
  - `nodejs` - Runtime
  - `npm` - Package manager
  - `npm-check-updates` - Check for npm package updates
  - `nvm` - Version manager [AUR]

## 5. Applications

### Internet

- `firefox` - Browser
- `google-chrome-stable` - Browser [AUR]
- `anydesk` - Remote desktop software [AUR]

### Communication

- `telegram-desktop` - Telegram
- `discord` - Discord
- `slack-desktop` - Slack [AUR]
- `zoom` - Video conferencing platform [AUR]
- `whatsapp-for-linux` - WhatsApp desktop client [AUR] [VPN]

### Multimedia

- Video/Audio:
  - `vlc` - Media player
  - `mpv` - Lightweight media player
  - `mpd` - Music server
  - `ncmpcpp` - MPD client
  - `spotify` - Spotify [AUR] [VPN]
  - `cava` - Visualizer [AUR]
- Graphics:
  - `pinta` - Editor [AUR]
  - `gthumb` - Viewer
  - `figma-linux` - Figma [AUR]

### Office

- `libreoffice-fresh` - Office suite
- `evince` - PDF viewer
- `zathura` - PDF viewer
- `obsidian` - Notes [AUR]

### Utilities

- Archiving:
  - `xarchiver` - GUI archiver
  - `zip`, `unzip` - ZIP archives
  - `p7zip` - 7z archives
  - `tar`, `gzip`, `bzip2` - Basic archivers
- Downloads:
  - `transmission-gtk` - Torrent client

### Security

- `keepassxc` - Password manager
- `gufw` - Firewall
- `veracrypt` - Encryption

## 6. Theming

### Themes

- `dracula-gtk-theme` - GTK theme [AUR]
- `dracula-icons-git` - Icons [AUR]
- `dracula-cursors-git` - Cursors [AUR]

### Fonts

- `ttf-jetbrains-mono` - JetBrains Mono
- `ttf-jetbrains-mono-nerd` - With icons
- `ttf-fira-code` - Fira Code
- `ttf-iosevka-nerd` - Iosevka
- `ttf-font-awesome` - Font Awesome icons
- `ttf-material-design-icons-git` - Google Material Design icons [AUR]
- `ttf-material-icons-git` - Material Icons [AUR]
