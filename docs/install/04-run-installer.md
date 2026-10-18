# 4. Running install.sh

One command installs packages, drivers and configs, and sets up boot and services.

```bash
sudo pacman -S --needed git
git clone https://github.com/Zilero232/arch-install-kit.git ~/arch-install-kit
cd ~/arch-install-kit
./install.sh
```

What you'll see:

1. **sudo password** — asked once, kept alive for the whole run.
2. **Installer dependencies** — `git`, `rsync`, `stow`, `jq`, [`gum`](https://github.com/charmbracelet/gum) and a few more from [`packages/bootstrap.txt`](https://github.com/Zilero232/arch-install-kit/blob/master/packages/bootstrap.txt). Missing ones are installed with `sudo pacman -Syu`, so this step **updates the whole system** before any question is asked (installing on a stale package database would be a partial upgrade).
3. **Pick optional groups** — a checklist (space toggles, enter confirms); everything is ticked by default.
4. **Plan and confirmation** — a summary box and _Start?_

After that it runs on its own: 20–60 minutes, depending on your connection and how many AUR packages it builds.

> Run it **as your regular user**, not with `sudo` — the script calls sudo itself where needed.

> Some defaults are the author's: the Wi-Fi region (`WIFI_COUNTRY="RU"` in [`modules/50-system.sh`](https://github.com/Zilero232/arch-install-kit/blob/master/modules/50-system.sh)), the `ru_RU` locale (same file) and the reflector mirror countries (`--country` in [`etc/xdg/reflector/reflector.conf`](https://github.com/Zilero232/arch-install-kit/blob/master/etc/xdg/reflector/reflector.conf)). Change them before the first run if you live elsewhere.

## 4.1. What happens, step by step

| Module       | What it does                                                                                                                                                         |
| ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `preflight`  | checks that this is Arch, you're online, pacman isn't locked, and there's enough space                                                                               |
| `pacman`     | enables multilib, colors, parallel downloads, no AUR debug packages; updates the system                                                                              |
| `aur-helper` | installs `yay`                                                                                                                                                       |
| `gpu`        | CPU microcode and Intel / AMD / NVIDIA drivers based on your hardware                                                                                                |
| `packages`   | removes conflicting packages and installs the selected [groups](../reference/packages.md)                                                                            |
| `system`     | `ru_RU` locale, reflector, Wi-Fi region, zram, Timeshift target, ufw firewall, INCY polkit rule, ath11k sleep hook, user groups                                      |
| `login`      | SDDM Astronaut theme and the Plymouth Arch logo splash                                                                                                               |
| `boot`       | rebuilds the initramfs, adds Windows to the GRUB menu                                                                                                                |
| `dotfiles`   | deploys `dotfiles/` into your home folder, copies the wallpapers to `~/Images`, colors Papirus folders violet, sets the swaync backlight device and the weather city |
| `shell`      | fish as the default shell                                                                                                                                            |
| `services`   | enables services from [`services.txt`](https://github.com/Zilero232/arch-install-kit/blob/master/services.txt), stops boot from waiting for the network              |
| `finish`     | shows what failed to install and what to do next                                                                                                                     |

## 4.2. Options

```bash
./install.sh --help
```

| Option               | What for                                                                          |
| -------------------- | --------------------------------------------------------------------------------- |
| `--minimal`          | desktop only: no dev, office, media, gaming or other apps                         |
| `--groups dev,media` | desktop + the chosen groups                                                       |
| `--only dotfiles`    | run only the listed modules (comma-separated)                                     |
| `--skip gpu,login`   | skip modules                                                                      |
| `--link`             | symlinks to the repo instead of copies — edits show up in `git status` right away |
| `--no-plymouth`      | no boot splash                                                                    |
| `--dry-run`          | show what would be done without changing anything                                 |
| `-y`, `--yes`        | no questions (for unattended runs): all groups unless `--minimal` / `--groups`    |

Examples:

```bash
./install.sh --dry-run                 # preview the plan
./install.sh --yes                     # everything, no questions
./install.sh --minimal --link          # desktop only, configs as symlinks
./install.sh --only dotfiles           # update configs after git pull
./install.sh --only packages --groups gaming   # add Steam later
```

## 4.3. Re-running

You can run the script as many times as you like:

- packages are installed with `--needed`, so anything already installed is skipped;
- system files are copied to `*.kit.bak` before their first edit;
- replaced configs go to `~/.config-backup/<date>/`.

If a module fails, the rest keep going, and at the end you'll get a hint like `./install.sh --only <module>`; the installer then exits with code `2`, so a script or CI notices. The exceptions are `preflight`, `pacman` and `aur-helper`: everything after them depends on them, so a failure there stops the run (exit code `1`).

**Log:** `~/.local/state/arch-install-kit/install-<date>.log`

## 4.4. Backlight device in swaync

The brightness slider in the swaync control center needs your backlight device (`amdgpu_bl1`, `intel_backlight`…). In copy mode the `dotfiles` module writes `~/.config/swaync/config.json` from the repo copy with the device it finds in `/sys/class/backlight`, and only when the result differs from what is there, so re-runs don't fill `~/.config-backup/` with copies of it.

With `--link` the file is a symlink into the repo and keeps the repo's device, `amdgpu_bl1`. On other hardware, put your device (`ls /sys/class/backlight`) into `"widget-config"` → `"backlight"` → `"device"` in `dotfiles/.config/swaync/config.json` and run `swaync-client --reload-config`.

---

**Next:** [5. After installation →](./05-after-install.md)
