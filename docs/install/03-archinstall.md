# 3. Installing Arch

The goal here is a minimal system with a user, networking and a bootloader. [install.sh](./04-run-installer.md) takes care of everything else.

## 3.1. Console prep

```bash
setfont ter-132b      # bigger font on 2K/4K screens (optional)
```

**Wi-Fi** (wired works out of the box):

```bash
iwctl
```

```text
device list                        # adapter name, usually wlan0
station wlan0 scan
station wlan0 get-networks
station wlan0 connect "NetworkName" # asks for the password
exit
```

```bash
ping -c 3 archlinux.org          # you should get replies
timedatectl set-ntp true
pacman -Sy archlinux-keyring     # fresh keys, otherwise signature errors
```

**Survey your disks** — snap a photo of the output with your phone:

```bash
lsblk -f
```

| What you see                   | What it is                |
| ------------------------------ | ------------------------- |
| `nvme0n1` / `sda` without `├─` | the whole disk            |
| `vfat`, 100 MB – 1 GB          | EFI — the bootloader      |
| `ext4` / `btrfs`               | old Linux (`/`, `/home`)  |
| `ntfs`                         | Windows — **don't touch** |
| `swap`                         | swap partition            |
| ~8–64 GB stick                 | the installer, ignore it  |

> See `ntfs` and want to keep Windows? Use [option C](#option-c-next-to-windows-dual-boot) below. Option A erases the whole disk, Windows included, and nothing brings it back: on an SSD the format also wipes the old blocks (TRIM).

## 3.2. archinstall menu

```bash
archinstall
```

Controls: arrow keys, `Enter` to select, `/` to search, `Space` to toggle, `Esc` to go back.

| Option                   | Value                                                                 |
| ------------------------ | --------------------------------------------------------------------- |
| Archinstall language     | English                                                               |
| Locales                  | Keyboard `us`, Language `en_US.UTF-8` (install.sh adds `ru_RU.UTF-8`) |
| Mirrors and repositories | region — your country; Optional repositories — **multilib**           |
| Disk configuration       | see 3.3 below                                                         |
| Swap                     | **True** (zram)                                                       |
| Bootloader               | **Grub** (can show Windows)                                           |
| Unified kernel images    | False                                                                 |
| Hostname                 | anything, e.g. `arch`                                                 |
| Authentication           | root password; a user (e.g. `zilero`), superuser **Yes**              |
| Profile                  | **Minimal**                                                           |
| Applications             | Bluetooth **Yes**, Audio **Pipewire**                                 |
| Kernels                  | `linux`                                                               |
| Network configuration    | **NetworkManager**                                                    |
| Additional packages      | `git vim`                                                             |
| Timezone                 | `Europe/Moscow` (or yours)                                            |
| Automatic time sync      | True                                                                  |

> The username can be anything — the configs aren't tied to it. But if you're **keeping your old `/home`**, it must match the old one, or the old folder will belong to someone else.

## 3.3. Disk partitioning

| You have                                | Option                                            |
| --------------------------------------- | ------------------------------------------------- |
| an empty disk, or nothing on it to keep | [A](#option-a-whole-disk-for-arch)                |
| Arch already, reinstalling it           | [B](#option-b-reinstall-over-existing-partitions) |
| Windows you want to keep                | [C](#option-c-next-to-windows-dual-boot)          |

### Option A: whole disk for Arch

**Use a best-effort default partition layout** → disk → **ext4** → separate `/home`: **No**.

> **Everything on the disk is wiped, Windows included.** Keeping Windows? Stop here and use option C.

Without a separate `/home`, Timeshift snapshots share the `/` partition with the system; to keep them elsewhere, pick another disk in `timeshift-gtk`.

### Option B: reinstall over existing partitions

**Manual Partitioning** → disk. For each partition:

| Partition         | Mountpoint | Format                              | FS    | Flags                                     |
| ----------------- | ---------- | ----------------------------------- | ----- | ----------------------------------------- |
| EFI (vfat, ~1 GB) | `/boot`    | yes if **no Windows**; otherwise no | fat32 | `boot, esp` — already set, **leave them** |
| old root          | `/`        | **yes**                             | ext4  | —                                         |
| old `/home`       | `/home`    | **no** — keeps your files           | ext4  | —                                         |
| ntfs (Windows)    | —          | **no, don't touch**                 | —     | —                                         |

You don't need the **xbootldr** flag (that's for systemd-boot).

Before **Confirm and exit**, check the _Status_ column: `/` should say `format`/`modify`, and the `/home` you're keeping should say `existing`.

**No "Mark to be formatted" option?** Delete the partition (**Delete partition**) → select the resulting **free space** → **Create new partition** → default size → FS and mountpoint as in the table. For a new EFI partition, mark it **bootable** and **ESP** after creating it.

### Option C: next to Windows, dual boot

You need the unallocated space you freed in Windows ([2.3](./02-usb-and-bios.md)). **Manual Partitioning** → disk, then:

| Partition                          | What to do                                                                                                               |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| Windows EFI (vfat)                 | at least 500 MB: mountpoint `/boot`, format **no**. Windows' default 100 MB is too small for the kernels: leave it alone |
| **free space**                     | **Create new partition**: 1 GB fat32 for `/boot`, marked **bootable** and **ESP**, only if the Windows EFI is too small  |
| **free space** (the rest)          | **Create new partition**: ext4, mountpoint `/`, format **yes**                                                           |
| ntfs, Microsoft reserved, recovery | **don't touch**: no mountpoint, no format                                                                                |

Before **Confirm and exit**, check the _Status_ column: every Windows partition must say `existing`. If one says `delete` or `format`, press **Esc** and start over.

After the install GRUB lists Windows: install.sh turns on os-prober ([4.1](./04-run-installer.md)).

## 3.4. Install

**Install** → confirm → 5–15 minutes → answer **No** when asked about chroot.

```bash
reboot      # pull the stick out once the screen goes dark
```

## 3.5. First login

Pick Arch in GRUB and log in as your user:

```bash
nmtui                 # Activate a connection → network → password
sudo pacman -Syu
```

---

**Next:** [4. Running install.sh →](./04-run-installer.md)
