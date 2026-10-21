# 2. USB stick and BIOS

## 2.1. Download the image

1. ISO: <https://archlinux.org/download/> — pick any mirror in your country.
2. Verify the checksum: `sha256sum archlinux-*.iso` against `sha256sums.txt` from the download page.

## 2.2. Write the USB stick

### From Windows — Rufus

[Rufus](https://rufus.ie) settings:

| Field            | Value                                      |
| ---------------- | ------------------------------------------ |
| Device           | your USB stick (double-check the size!)    |
| Boot selection   | Disk or ISO image → pick `archlinux-*.iso` |
| Partition scheme | **GPT**                                    |
| Target system    | **UEFI (non CSM)**                         |
| File system      | FAT32 (default)                            |

**START** → when asked about the hybrid image, choose **"Write in DD Image mode"**.

> After a DD write, Windows will show the stick as a small "unreadable" drive and offer to format it — **say no**, that's expected.

Alternative: [Ventoy](https://www.ventoy.net) — install it on the stick once, then just copy ISOs onto it.

### From Linux

```bash
lsblk                                   # find the stick, e.g. sdb — NOT your system disk!
sudo dd if=archlinux-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

## 2.3. BIOS / UEFI

- **Secure Boot** — off.
- Boot mode — **UEFI** (no Legacy/CSM).
- Dual-booting Windows? Do this in Windows **before** you boot the stick:
  - Turn off **fast startup** (Control Panel → Power Options → Choose what the power buttons do → Turn on fast startup).
  - Free space for Arch: **Disk Management** → right-click `C:` → **Shrink Volume**, at least 60 GB. Leave the space unallocated; archinstall partitions it in [3.3](./03-archinstall.md).
  - If BitLocker or device encryption is on (Settings → Privacy & security → Device encryption), save the recovery key from [account.microsoft.com/devices/recoverykey](https://account.microsoft.com/devices/recoverykey). A new bootloader can make Windows ask for it once.
  - Make Windows keep the hardware clock in UTC, as Linux does, or the time jumps by your time zone every time you switch systems. In a terminal opened as administrator:

    ```powershell
    reg add "HKLM\System\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /d 1 /t REG_DWORD /f
    ```

- Arch already installed and Windows goes in second? See [Dual boot with Windows](../usage/dual-boot.md).
- Boot from the stick: usually F12, F8 or Esc at power-on.

## 2.4. USB boot menu

Pick the first entry — **Arch Linux install medium (x86_64, UEFI)**.

| Entry                           | What it is                                       |
| ------------------------------- | ------------------------------------------------ |
| _install medium_                | ✅ the regular installer                         |
| _…with speech_                  | installer with a screen reader (for blind users) |
| _Memtest86+_                    | memory test                                      |
| _UEFI Shell_ / _Firmware Setup_ | UEFI console / enter the BIOS                    |

---

**Next:** [3. Installing Arch →](./03-archinstall.md)
