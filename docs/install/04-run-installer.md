# 4. Running install.sh

One command installs packages, drivers and configs, and sets up boot and services.

```bash
sudo pacman -S --needed git
git clone https://github.com/Zilero232/arch-install-kit.git ~/arch-install-kit
cd ~/arch-install-kit
./install.sh
```

The script asks for your sudo password once and then runs on its own: 20–60 minutes, depending on your connection and how many AUR packages it builds.

> Run it **as your regular user**, not with `sudo` — the script calls sudo itself where needed.

## What happens, step by step

| Module       | What it does                                                                                                   |
| ------------ | -------------------------------------------------------------------------------------------------------------- |
| `preflight`  | checks that this is Arch, you're online, pacman isn't locked, and there's enough space                         |
| `pacman`     | enables multilib, colors, parallel downloads; updates the system                                               |
| `aur-helper` | installs `yay`                                                                                                 |
| `packages`   | removes conflicting packages and installs the selected [groups](../reference/packages.md)                      |
| `gpu`        | CPU microcode and Intel / AMD / NVIDIA drivers based on your hardware                                          |
| `system`     | `ru_RU` locale, user groups                                                                                    |
| `login`      | SDDM theme and Plymouth splash                                                                                 |
| `boot`       | rebuilds the initramfs, adds Windows to the GRUB menu                                                          |
| `dotfiles`   | deploys `dotfiles/` into your home folder                                                                      |
| `shell`      | fish as the default shell, fisher plugins, bun                                                                 |
| `services`   | enables services from [`services.txt`](https://github.com/Zilero232/arch-install-kit/blob/master/services.txt) |
| `finish`     | shows what failed to install and what to do next                                                               |

## Options

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

Examples:

```bash
./install.sh --dry-run                 # preview the plan
./install.sh --minimal --link          # desktop only, configs as symlinks
./install.sh --only dotfiles           # update configs after git pull
./install.sh --only packages --groups gaming   # add Steam later
```

## Re-running

You can run the script as many times as you like:

- packages are installed with `--needed`, so anything already installed is skipped;
- system files are copied to `*.kit.bak` before their first edit;
- replaced configs go to `~/.config-backup/<date>/`.

If a module fails, the rest keep going, and at the end you'll get a hint like `./install.sh --only <module>`.

**Log:** `~/.local/state/arch-install-kit/install-<date>.log`

---

**Next:** [5. After installation →](./05-after-install.md)
