# Manual Arch install (without archinstall)

An alternative to [step 3](../install/03-archinstall.md) if you want control over every command. Same result: a minimal system, ready for [install.sh](../install/04-run-installer.md).

> The examples use `/dev/nvme0n1`. Yours may be named differently (`sda`, `vda`) — check `lsblk`.

## 1. Network and time

```bash
iwctl                              # station wlan0 connect "NetworkName", exit
ping -c 3 archlinux.org
timedatectl set-ntp true
pacman -Sy archlinux-keyring
```

## 2. Partitioning (UEFI / GPT)

```bash
cfdisk /dev/nvme0n1
```

| Partition   | Size      | Type                       |
| ----------- | --------- | -------------------------- |
| `nvme0n1p1` | 1 GB      | EFI System                 |
| `nvme0n1p2` | 50–100 GB | Linux filesystem (`/`)     |
| `nvme0n1p3` | the rest  | Linux filesystem (`/home`) |

No swap partition needed — we'll enable zram below.

## 3. Format and mount

```bash
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.ext4 /dev/nvme0n1p2
mkfs.ext4 /dev/nvme0n1p3            # skip if you're keeping your old /home

mount /dev/nvme0n1p2 /mnt
mount --mkdir /dev/nvme0n1p1 /mnt/boot
mount --mkdir /dev/nvme0n1p3 /mnt/home
```

## 4. Base system

```bash
pacstrap -K /mnt base base-devel linux linux-firmware linux-headers \
    networkmanager zram-generator grub efibootmgr os-prober git vim sudo
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
```

## 5. System configuration

```bash
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime   # or your timezone
hwclock --systohc

sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "arch" > /etc/hostname

# zram instead of a swap partition
printf '[zram0]\nzram-size = ram / 2\n' > /etc/systemd/zram-generator.conf

systemctl enable NetworkManager
```

## 6. User

```bash
passwd                                   # root password
useradd -m -G wheel -s /bin/bash zilero
passwd zilero
echo '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/wheel
```

## 7. Bootloader

```bash
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```

install.sh adds Windows to the GRUB menu (the `boot` module).

## 8. Reboot

```bash
exit
umount -R /mnt
reboot
```

After logging in: `nmtui` → connect to a network → [run install.sh](../install/04-run-installer.md).
