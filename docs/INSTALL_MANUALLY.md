# Arch Linux Installation 🐧

This file contains the sequence of commands for installing Arch Linux.

## Installation Preparation 🛠️

### 1. Connecting to Wi-Fi 📡

```bash
# Launch Wi-Fi manager
iwctl

# View devices
device list

# Scan and connect
station device scan
station device get-networks
station device connect SSID

# Exit the service
exit

# Check connection
ping google.org
```

### 2. Disk Partitioning (UEFI/GPT) 💾

```bash
# View current partitions
lsblk

# Launch cfdisk
# Warning: /dev/sda is used as an example!
# You might have a different disk name (e.g., /dev/nvme0n1, /dev/vda or /dev/sdb)
# Use lsblk command to determine your correct disk name
cfdisk /dev/sda

# In the interactive menu create partitions:
1. Select GPT
2. Create partitions:
- /dev/sda1 - (from 50 GB), Linux filesystem (root)
- /dev/sda2 - (remaining space), Linux filesystem (home)
- /dev/sda3 - (from 500 MB - 1 GB), EFI System
- /dev/sda4 - (from 5 GB), Linux swap
3. Write (save changes)
4. Quit
```
### 3. Formatting Partitions 📝

```bash
# Root partition
mkfs.ext4 /dev/sda1

# Home partition
mkfs.ext4 /dev/sda2

# EFI partition
mkfs.fat -F32 /dev/sda3

# Swap partition
mkswap /dev/sda4
```
### 4. Activating Swap and Mounting Partitions 🔄
```bash
# Activate swap
swapon /dev/sda4

# Mount partitions
mount /dev/sda1 /mnt

mkdir -p /mnt/{boot/EFI,home}

mount /dev/sda2 /mnt/home
mount /dev/sda3 /mnt/boot/EFI
```

### 5. Installing Base System ⚙️
```bash
# Install base software
pacstrap -K /mnt base base-devel linux linux-firmware iwd dhcpcd networkmanager vim

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Check file fstab
cat /mnt/etc/fstab

# Change root to new system
arch-chroot /mnt
```

### 6. User Configuration 👥
```bash
# Set root password
passwd

# Create user
useradd -m -G wheel,users,video,audio,optical,storage,power,network -s /bin/bash (USER_NAME)
passwd (USER_NAME)

# Configure sudo
EDITOR=vim visudo
# Uncomment %wheel ALL=(ALL:ALL) ALL
```

### 7. System Configuration 🖥️

```bash
# Edit locale.gen
vim /etc/locale.gen
# Uncomment your preferred locales (e.g., en_US.UTF-8)

# Generate locales
locale-gen

# Set default language
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Configure time
ln -sf /usr/share/zoneinfo/Your/Zone /etc/localtime
hwclock --systohc

# Configure network
vim /etc/hostname

# Configure hosts
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1 localhost" >> /etc/hosts
echo "127.0.1.1 archlinux.localdomain archlinux" >> /etc/hosts
```

### 8. Bootloader Installation 🥾

```bash
# Install required packages
pacman -S grub efibootmgr os-prober

# Edit grub
vim /etc/default/grub
# Uncomment "GRUB_DISABLE_OS_PROBER=false"

# Install GRUB
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --efi-directory=/boot/EFI --recheck

# Create config
grub-mkconfig -o /boot/grub/grub.cfg

# Exit and reboot
exit
umount -R /mnt
reboot
```

## System Configuration After First Boot 🌟

```bash
# Enable and start NetworkManager
systemctl enable NetworkManager
systemctl start NetworkManager

# Connect to Wi-Fi using NetworkManager
nmcli device wifi list
nmcli device wifi connect SSID password PASSWORD

# Install Xorg and necessary components
pacman -S xorg xorg-xinit xterm

# Install video drivers (choose appropriate for your graphics card)

# For Intel:
pacman -S xf86-video-intel
# For NVIDIA:
pacman -S nvidia nvidia-utils
# For AMD:
pacman -S xf86-video-amdgpu

# Create xinit configuration file
cp /etc/X11/xinit/xinitrc ~/.xinitrc

# Test X server
startx
```

## Additional Information 📚
Detailed guide for system configuration after installation can be found in [SYSTEM_SETTINGS.md](./SYSTEM_SETTINGS.md)