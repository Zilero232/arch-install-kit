# Quick Arch Linux Installation Using `archinstall` 🚀

This method offers a simpler way to install Arch Linux using the archinstall script. ✨

## Preparation in Windows 🖥️

1. **Creating Space for Arch Linux** 💾
   - Open "Disk Management" in Windows
   - Right-click on the main Windows partition → "Shrink Volume"
   - Allocate minimum 50 GB (100+ GB recommended)
   - Leave the space unallocated

2. **Disable Windows Fast Startup** ⚡
   - Control Panel → Power Options → Choose what the power buttons do
   - Disable "Fast Startup"

3. **Disable Secure Boot in BIOS/UEFI** 🔒
   - Restart your computer and enter BIOS/UEFI
   - Find Secure Boot setting and disable it
   - Save changes and exit

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

### 2. Launch archinstall 🎯

```bash
# Update system time
timedatectl set-ntp true

# Launch installer
archinstall
```

## Installation Parameters Setup ⚙️

In the archinstall interactive menu, select the following parameters:

1. **Keyboards and language** ⌨️
   - Choose your preferred keyboard layout(s)
   - Add additional layouts if needed

2. **Mirror region** 🌍
   - Select your region

3. **Disk configuration** 💽
   - Select the disk where Windows is installed
   - Choose `Manual partitioning`
   - Find the free space created earlier
   - Create partitions:
     ```
     /dev/sda1 - 1G - EFI (if not exists)
     /dev/sda2 - 100GB - / (root)
     /dev/sda3 - remaining space - /home
     /dev/sda4 - 5GB - swap
     ```
   Recommended partition sizes:
   - EFI: 1G
   - root (/): 50-100GB
   - home (/home): all remaining space
   - swap: equal to RAM size (for hibernation)

4. **Bootloader** 🥾
   - Select `GRUB`

5. **Swap** 💫
   - Recommended to enable

6. **Profile** 👤
   - Desktop environment: choose desired environment (e.g., GNOME, KDE, XFCE)
   - Audio: `pipewire`

7. **User account** 🔑
   - Create a user and set password
   - Enable sudo for the user

8. **Additional packages** 📦
   - Recommended packages: `iwd, vim`

9. **Network configuration** 🌐
   - Select `NetworkManager`

10. **Timezone** ⏰
    - Select your region and city

11. **Click `Install`** to begin installation 🚀

## Post Installation 🎉

```bash
# After installation is complete, reboot the system
reboot
```

### First Boot 🌟

1. Log in using the created user account
2. Check internet connection
3. Update the system:

```bash
sudo pacman -Syu
```

## Notes 📝

- archinstall significantly simplifies the installation process by automating many steps ✅
- All core components (bootloader, network, localization) are configured automatically 🔄
- If you need more detailed configuration, it's recommended to use the [manual installation method](./INSTALL_MANUALLY.md) 📖