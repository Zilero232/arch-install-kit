# Repository layout

```text
arch-install-kit/
├── install.sh            # entry point: flags, module order
├── lib/                  # shared functions used by the modules
│   ├── log.sh            #   output and log file
│   ├── run.sh            #   run (with --dry-run), module runner
│   ├── sudo.sh           #   refuse root, sudo handling
│   ├── ui.sh             #   gum prompts: group picker, confirmation
│   ├── pkg.sh            #   reading lists, installing via yay
│   ├── hw.sh             #   CPU, GPU, bootloader, kernels
│   └── fs.sh             #   backups, deploying dotfiles
├── modules/              # install steps, run in numeric order
├── packages/             # package lists per group
├── services.txt          # which systemd units to enable
├── dotfiles/             # mirror of $HOME: .config/, bin/, .gtkrc-2.0
├── etc/                  # system files (SDDM, Plymouth, reflector, polkit rules)
├── assets/               # wallpapers and screenshots
└── docs/                 # documentation
```

## How install.sh works

1. Sources every `lib/*.sh`.
2. Parses the flags (`--minimal`, `--only`, `--dry-run`…).
3. Installs its own dependencies from `packages/bootstrap.txt` (`pkg_bootstrap`).
4. Unless `--yes` is given or there's no terminal, lets you pick optional groups and confirm the plan (`lib/ui.sh`, gum).
5. Runs `modules/NN-name.sh` one by one. Each module runs in its own subshell in strict mode (`set -Eeuo pipefail`), so an error only stops that module.
6. If a critical module fails (`preflight`, `pacman`, `aur-helper`), the install aborts. Anything else can be re-run with `--only`.

## Module rules

- **One module, one job.** File name is `NN-name.sh`; the number sets the order.
- **Anything that changes the system goes through `run`.** That's what makes `--dry-run` work.
- **Idempotency.** Before changing something, check whether it's already done (`grep -q`, `is_installed`) so re-runs don't break anything.
- **Edit system files only after `backup_once`.** When possible, write a drop-in instead (`/etc/modprobe.d/`, `/etc/mkinitcpio.conf.d/`) with `write_root_file`.
- **Finish with `ok "…"`.** That way the output shows the step completed.

### Adding a module

```bash
cat > modules/55-example.sh <<'EOF'
#!/usr/bin/env bash
# One line: what this module does.

if ! is_installed example; then
    pkg_install example
fi
ok "Example configured"
EOF
```

It shows up in `./install.sh --help` right away and is available as `--only example`.

## Dotfiles

`dotfiles/` mirrors your home folder:

| In the repo              | Ends up in        |
| ------------------------ | ----------------- |
| `dotfiles/.config/hypr/` | `~/.config/hypr/` |
| `dotfiles/bin/`          | `~/bin/`          |
| `dotfiles/.gtkrc-2.0`    | `~/.gtkrc-2.0`    |

The `dotfiles` module deploys them in one of two ways:

- **copy** (default) — `rsync --backup`: replaced files go to `~/.config-backup/<date>/`;
- **symlinks** (`--link`) — [GNU Stow](https://www.gnu.org/software/stow/): `~/.config/hypr` points into the repo, so edits show up in `git status` right away.

No secrets live in the repo, and none are needed: the weather module works without an API key.

## Services

[`services.txt`](https://github.com/Zilero232/arch-install-kit/blob/master/services.txt): unit, `system`/`user`, package. A unit is enabled only if its package is installed:

```text
docker.service   system   docker
```
