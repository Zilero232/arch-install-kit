# Dual boot with Windows

Windows and Arch on one disk, picked in the GRUB menu at power-on.

- **Windows is already on the disk:** install Arch next to it. Free space in Windows ([2.3](../install/02-usb-and-bios.md)), then partition with [option C](../install/03-archinstall.md#option-c-next-to-windows-dual-boot).
- **Arch is already installed:** this page adds Windows 11 to it, with or without a USB stick.
- **Only a few Windows apps?** A virtual machine is simpler: VirtualBox comes with the `dev` group.

The `base` group has every tool used here:

| Package      | What it does here                                                                        |
| ------------ | ---------------------------------------------------------------------------------------- |
| `os-prober`  | finds Windows so `grub-mkconfig` adds it to the menu                                     |
| `ntfs-3g`    | lets os-prober read the Windows (NTFS) partition                                         |
| `efibootmgr` | lists the firmware boot entries and sets their order                                     |
| `dosfstools` | `mkfs.fat` formats the FAT32 partition or stick UEFI boots the installer from            |
| `wimlib`     | `wimlib-imagex split` cuts the Windows image into parts that fit FAT32's 4 GB file limit |
| `parted`     | moves partition boundaries and creates partitions (part of Arch's base install)          |
| `e2fsprogs`  | `e2fsck` checks and `resize2fs` resizes ext4 (part of Arch's base install)               |

## Before you start

- Back up `/home`: resizing a partition can lose data.
- Pick a size for Windows: 64 GB is its minimum, 150–250 GB leaves room for apps and games.
- Windows 11 needs UEFI and TPM 2.0 (fTPM or PTT in the BIOS). Secure Boot can stay off.
- Download the ISO from [microsoft.com/software-download/windows11](https://www.microsoft.com/software-download/windows11).

## Free space for Windows

The kit's layout puts `/home` last on the disk (EFI, `/`, `/home`), so Windows gets space cut from the end of `/home`. ext4 only shrinks while unmounted, and your session keeps `/home` busy: log out, switch to a console with `Ctrl + Alt + F3` and log in as `root`. No root password yet? Set one first with `sudo passwd root`.

```bash
lsblk                                  # which partition is /home, here nvme0n1p3
parted /dev/nvme0n1 unit MiB print     # the "Disk /dev/nvme0n1:" line is the disk size
```

The new end of `/home` is the disk size minus the Windows size, minus 10240 MiB more if you have no USB stick (the [installer partition](#no-stick-an-installer-partition) goes there). For a 2 TB disk (1953514 MiB), 200 GiB for Windows (204800 MiB) and no stick: 1953514 − 204800 − 10240 = **1738474 MiB**.

```bash
loginctl terminate-user <your-user>         # ends your processes, which keep files in /home open
umount /home                                # resize2fs can't shrink a mounted ext4
e2fsck -f /dev/nvme0n1p3                    # resize2fs refuses to shrink without a fresh check
resize2fs /dev/nvme0n1p3 1600G              # shrink the filesystem below the new partition size
parted /dev/nvme0n1 resizepart 3 1738474MiB # move the end of /home; answer Yes
resize2fs /dev/nvme0n1p3                    # grow the filesystem back to fill the partition
reboot
```

The filesystem shrinks first, to a size between what `/home` uses (`df -h /home`) and the new partition size, so cutting the partition can't cut off its end; the last `resize2fs` takes the margin back.

`/` is the last partition (no separate `/home`)? It can't be unmounted from the running system: run the same steps from a live USB stick (the Arch ISO or [GParted Live](https://gparted.org/livecd.php)).

## Installer media

### USB stick

A stick of 16 GB or more: the Windows 11 ISO is about 9 GB. On a Windows PC, [Rufus](https://rufus.ie) writes the ISO; [Ventoy](https://www.ventoy.net) takes it as a copied file. From Linux, give the stick a FAT32 partition, the only filesystem UEFI is sure to boot from:

```bash
lsblk                                                   # find the stick, e.g. sda: NOT your system disk
sudo parted /dev/sdX mklabel gpt mkpart WIN11 fat32 1MiB 100%   # wipes the stick: new GPT, one partition
sudo mkfs.fat -F32 -n WIN11 /dev/sdX1                   # FAT32 with the label WIN11
```

Then [copy the installer files](#copy-the-installer-files) to `/dev/sdX1`.

### No stick: an installer partition

A 10 GiB FAT32 partition goes right after `/home`, in front of the Windows space; GRUB starts the installer from it. It holds the whole ISO (about 9 GB, check yours with `ls -lh ~/Downloads/*.iso`), and even one edition of Windows doesn't fit in 8 GiB. Creating it doesn't need the console, the disk can stay mounted:

```bash
sudo parted /dev/nvme0n1 mkpart WININSTALL fat32 1738474MiB 1748714MiB   # 10 GiB right after /home
sudo mkfs.fat -F32 -n WININSTALL /dev/nvme0n1p4                          # FAT32 with the label GRUB looks for
```

Add a GRUB entry for it: `sudoedit /etc/grub.d/40_custom` and append

```text
menuentry "Windows 11 installer" {
    insmod fat
    insmod chainloader
    search --no-floppy --label WININSTALL --set=root
    chainloader /efi/boot/bootx64.efi
}
```

`insmod` loads GRUB's FAT reader and its chainloader, `search` finds the partition by its label, and `chainloader` hands the boot over to the Windows installer's EFI loader on it. Rebuild the menu (`-o` is where it's written):

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

This is GRUB only: systemd-boot can't start a loader from another partition.

### Copy the installer files

The Windows image, `sources/install.wim`, is bigger than 4 GB and doesn't fit FAT32 in one piece. Everything else is copied as is, and wimlib cuts the image into `install.swm`, `install2.swm`… of 3800 MB, which the installer reads as one:

```bash
sudo mkdir -p /mnt/iso /mnt/win
sudo mount -o loop,ro ~/Downloads/Win*.iso /mnt/iso         # the ISO as a read-only disk
sudo mount /dev/nvme0n1p4 /mnt/win                           # the installer partition, or the stick
sudo rsync -r --exclude=/sources/install.wim /mnt/iso/ /mnt/win/
sudo wimlib-imagex split /mnt/iso/sources/install.wim /mnt/win/sources/install.swm 3800
sudo umount /mnt/iso /mnt/win                                # flushes everything to the disk
```

The trailing `/` in `/mnt/iso/` makes rsync copy the folder's contents, not the folder.

## Install Windows

1. Boot the stick (F12, F8 or Esc at power-on) or pick **Windows 11 installer** in GRUB.
2. Choose the custom install, select **Unallocated space**, **Next**.
3. Leave every other partition alone (EFI, Linux, WININSTALL): no Delete, no Format.

Windows puts its boot files on the existing EFI partition and often makes itself the first boot entry. If the PC now starts Windows directly, fix the order [below](#back-to-grub).

## In Windows

In a terminal opened as administrator:

```powershell
powercfg /h off
reg add "HKLM\System\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /d 1 /t REG_DWORD /f
```

- `powercfg /h off` turns off hibernation and fast startup with it. With fast startup Windows doesn't shut down but hibernates, and leaves its partition locked.
- `RealTimeIsUniversal` makes Windows keep the hardware clock in UTC, as Linux does. Without it the clock jumps by your time zone every time you switch systems. `/v` is the value name, `/d 1` its data, `/t REG_DWORD` a number, `/f` skips the confirmation.
- Device encryption or BitLocker on (Settings → Privacy & security → Device encryption)? Save the recovery key from [account.microsoft.com/devices/recoverykey](https://account.microsoft.com/devices/recoverykey): started from GRUB, Windows may ask for it once.

## Back to GRUB

Press F12, F8 or Esc at power-on and pick GRUB (the entry may be called `GRUB` or `arch`). In Arch:

```bash
sudo efibootmgr                    # entries (Boot0000 GRUB, Boot0001 Windows Boot Manager…) and BootOrder
sudo efibootmgr -o 0000,0001       # -o sets the order: your GRUB number first, Windows Boot Manager next
sudoedit /etc/grub.d/40_custom     # remove the "Windows 11 installer" entry, if you added it
./install.sh --only boot           # rebuilds the GRUB menu; look for "Found Windows Boot Manager"
```

`./install.sh --only boot` runs `grub-mkconfig` with os-prober turned on; `sudo grub-mkconfig -o /boot/grub/grub.cfg` does the same. A big Windows update can put Windows Boot Manager first again: the same `efibootmgr -o` fixes it.

## Give the installer partition back to `/home`

Once Windows works, the 10 GiB go back to `/home`. ext4 grows while mounted, so this runs from your normal session:

```bash
lsblk                                                # the WININSTALL partition, here nvme0n1p4
sudo parted /dev/nvme0n1 rm 4                        # delete it
sudo parted /dev/nvme0n1 unit MiB print free         # the "Free Space" line right after /home: note its End
sudo parted /dev/nvme0n1 resizepart 3 1748714MiB     # /home ends where that free space ends; answer Yes
sudo resize2fs /dev/nvme0n1p3                        # grow the filesystem into it
```

parted refuses an end that runs into the next partition, so a wrong number fails instead of touching Windows.

## Secure Boot

The kit runs with Secure Boot off, and Windows 11 installs that way. Some games' anti-cheat (Valorant, Battlefield 6, recent Call of Duty) won't start without it. Turning it on means signing GRUB and the kernel with your own keys ([sbctl](https://wiki.archlinux.org/title/Unified_Extensible_Firmware_Interface/Secure_Boot#Assisted_process_with_sbctl)), which the kit doesn't do.
