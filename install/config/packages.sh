#!/bin/bash

# Package configuration file
# Defines arrays of packages to be installed, grouped by category
# 
# Note: [AUR] tag indicates package from the Arch User Repository
# Note: [VPN] tag indicates package might need VPN for installation

# Base system packages
BASE_PACKAGES=(
    "base-devel"       
    "git"           
    "sudo"           
    "reflector"  
    "pacman-contrib"
)

# X.org display server packages
XORG_PACKAGES=(
    "xorg-server"       
    "xorg-xinit"        
    "xorg-xbacklight"   
    "arandr"           
    "picom"            
)

# Display Manager packages
DM_PACKAGES=(
    "sddm"            
    "plymouth"         
)

# Window Manager packages
WM_PACKAGES=(
    "bspwm"           
    "sxhkd"            
    "polybar"         
    "dunst"            
    "i3lock-color"     
    "nitrogen"         
)

# Audio system packages
AUDIO_PACKAGES=(
    "pipewire"         
    "pipewire-pulse"   
    "pipewire-alsa"    
    "pipewire-jack"    
    "wireplumber"      
    "pavucontrol"      
    "pamixer"          
    "sound-theme-freedesktop"  
)

# Network packages
NETWORK_PACKAGES=(
    "networkmanager"    
    "network-manager-applet"  
    "openssh"           
    "dhcpcd"            
    "iwd"               
    "wireshark-qt"      
    "net-tools"         
)

# Bluetooth packages
BLUETOOTH_PACKAGES=(
    "bluez"            
    "bluez-utils"      
    "blueman"          
    "bluez-hid2hci"    
)

# Power management packages
POWER_PACKAGES=(
    "tlp"              
    "tlp-rdw"          
    "cpupower"         
    "brightnessctl"    
    "xfce4-power-manager"  
)

# System monitoring packages
MONITOR_PACKAGES=(
    "htop"             
    "btop"             
)

# Terminal and shell packages
TERMINAL_PACKAGES=(
    "alacritty"        
    "fish"             
    "tmux"             
    "ranger"           
    "lsd"              
    "bat"              
    "ueberzug"         
)

# File management packages
FILE_PACKAGES=(
    "thunar"           
    "thunar-archive-plugin"  
    "xarchiver"       
    "zip"              
    "unzip"            
    "p7zip"            
    "xclip"           
)

# Application launcher packages
LAUNCHER_PACKAGES=(
    "rofi"             
    "rofi-calc"        
    "rofi-emoji"       
)

# Development packages
DEV_PACKAGES=(
    "code"             
    "neovim"           
    "git"              
    "github-cli"       
    "docker"           
    "docker-compose"    
    "meson"            
    "python"           
    "python-pip"       
    "nodejs"           
    "npm"              
)

# Desktop utilities
DESKTOP_PACKAGES=(
    "flameshot"        
    "peek"             
    "redshift"         
    "gpick"            
    "cheese"           
    "gnome-calculator" 
    "gnome-clocks"     
    "virtualbox"       
    "obs-studio"
)

# Font packages
FONT_PACKAGES=(
    "ttf-jetbrains-mono"         
    "ttf-jetbrains-mono-nerd"     
    "ttf-fira-code"               
    "ttf-iosevka-nerd"            
    "noto-fonts"                  
)

# Security packages
SECURITY_PACKAGES=(
    "keepassxc"        
    "gufw"             
    "veracrypt"        
)

# Internet and Communication packages
INTERNET_PACKAGES=(
    "firefox"          
    "google-chrome"     
    "anydesk"           
    "telegram-desktop"  
    "discord"           
)

# Multimedia packages
MULTIMEDIA_PACKAGES=(
    # Video/Audio
    "vlc"              
    "mpv"             
    "mpd"              
    "ncmpcpp"          
    "cava"          

    # Graphics
    "pinta"            
    "gthumb"           
)

# Office packages
OFFICE_PACKAGES=(
    "libreoffice-fresh"  
    "evince"             
    "zathura"            
)

# Development IDEs and Tools
DEV_IDE_PACKAGES=(
    "code"             
    "neovim"          
    "meld"             
    "filezilla"        
    "shellcheck"       
    "cloc"           
)

# Development Languages and Tools
DEV_LANG_PACKAGES=(
    "python"          
    "python-pip"      
    "bpython"          
    "ipython"          
    "nodejs"           
    "npm"              
    "php"              
    "composer"         
)

# AUR packages
AUR_PACKAGES=(
    "s-tui"    
    "postman-bin"              
    "nvm"                      
    "google-chrome"           
    "anydesk"                 
    "cava"                     
    "figma-linux"             
    "slack-desktop"           
    "zoom"      
    "obsidian"               
    "sddm-astronaut-theme"       
    "plymouth-theme-deus-ex-git"
    "dracula-gtk-theme"  
    "dracula-icons-git"   
    "dracula-cursors-git"         
)

# VPN Required packages [All require VPN for installation]
VPN_PACKAGES=(
    "phpstorm"           
    "phpstorm-jre"        
    "spotify"     
    "whatsapp-for-linux"
)

# All official packages combined
ALL_OFFICIAL_PACKAGES=(
    "${BASE_PACKAGES[@]}"
    "${XORG_PACKAGES[@]}"
    "${DM_PACKAGES[@]}"
    "${WM_PACKAGES[@]}"
    "${AUDIO_PACKAGES[@]}"
    "${NETWORK_PACKAGES[@]}"
    "${BLUETOOTH_PACKAGES[@]}"
    "${POWER_PACKAGES[@]}"
    "${MONITOR_PACKAGES[@]}"
    "${TERMINAL_PACKAGES[@]}"
    "${FILE_PACKAGES[@]}"
    "${LAUNCHER_PACKAGES[@]}"
    "${DEV_PACKAGES[@]}"
    "${DEV_IDE_PACKAGES[@]}"
    "${DEV_LANG_PACKAGES[@]}"
    "${DESKTOP_PACKAGES[@]}"
    "${INTERNET_PACKAGES[@]}"
    "${MULTIMEDIA_PACKAGES[@]}"
    "${OFFICE_PACKAGES[@]}"
    "${FONT_PACKAGES[@]}"
    "${SECURITY_PACKAGES[@]}"
)