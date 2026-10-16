# AGENTS.md

Guidance for AI coding agents (Claude Code, Codex, Cursor…) working in this repo.

## What this is

Personal Arch Linux + Hyprland setup: a modular bash installer (`install.sh`, `lib/`, `modules/`), package lists (`packages/*.txt`) and dotfiles (`dotfiles/`, a mirror of `$HOME`). Everything — docs (`docs/`), code, comments, commits — is in English.

Read first: [docs/reference/structure.md](docs/reference/structure.md).

## Rules

- **Readability over cleverness.** Short functions, clear names, one-line comments that say _why_. No dense one-liners.
- **Prefer existing tools** (yay, rsync, stow, hyprctl, systemd drop-ins) over custom code.
- **Bash style:** `#!/bin/bash`, 4-space indent, `"$quoted"` vars, `[ ]`/`(( ))`, functions `snake_case`. Modules run under `set -Eeuo pipefail`: write `if …; then` instead of `cond && action` as the last line of a function.
- **Every system change goes through `run`** (dry-run) and is idempotent; back up with `backup_once` before editing `/etc` files, prefer drop-in files.
- **Packages:** add to the right `packages/<group>.txt`; verify the name exists (archlinux.org/packages, AUR RPC). Wayland-native tools only — no X11 utilities (xdotool, redshift, flameshot…). Drivers/microcode belong to `modules/40-gpu.sh`, not the lists.
- **Dotfiles:** Hyprland 0.5x hyprlang `.conf` syntax (check https://wiki.hypr.land); no absolute `/home/<user>` paths — use `~` or `$HOME`; no secrets in the repo.
- **Docs:** when behaviour, flags, packages or keybindings change, update the matching page in `docs/` (keybindings → `docs/usage/keybindings.md`).

## Checks

```bash
mise install         # once: bun version from mise.toml
bun install          # once: commitlint, husky, shellcheck, prettier, vitepress
bun run lint         # shellcheck for all scripts
./install.sh --dry-run   # on Arch: see what would change
```

There are no unit tests; never run `install.sh` without `--dry-run` on a machine you don't intend to configure.

## Commits

Gitmoji + conventional, enforced by commitlint (`commitlint.config.mjs`):

```text
✨ feat(hypr): add clipboard history on Super+V
🐛 fix(installer): skip plymouth when not installed
📝 docs: describe --link mode
```

Scopes: installer, packages, hypr, waybar, rofi, shell, dotfiles, scripts, login, docs, tooling, deps. Interactive helper: `bun run commit`.
