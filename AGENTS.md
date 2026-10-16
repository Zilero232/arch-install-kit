# AGENTS.md

Guidance for AI coding agents (Claude Code, Codex, Cursor…) working in this repo.

## What this is

Personal Arch Linux + Hyprland setup: a modular bash installer (`install.sh`, `lib/`, `modules/`), package lists (`packages/*.txt`) and dotfiles (`dotfiles/`, a mirror of `$HOME`). Everything — docs (`docs/`), code, comments, commits — is in English.

Read first: [docs/reference/structure.md](docs/reference/structure.md).

## Rules

- **Readability over cleverness.** Short functions, clear names, comments that say _why_. No dense one-liners.
- **A script is the last resort.** If a package or a built-in feature does the job (waybar signals, systemd timers, Hyprland rules), use it.
- **Prefer existing tools** (yay, rsync, stow, hyprctl, systemd drop-ins) over custom code.
- **Every system change goes through `run`** (dry-run) and is idempotent; back up with `backup_once` before editing `/etc` files, prefer drop-in files.
- **Packages:** add to the right `packages/<group>.txt`; verify the name exists (archlinux.org/packages, AUR RPC). Wayland-native tools only — no X11 utilities (xdotool, redshift, flameshot…). Drivers/microcode belong to `modules/40-gpu.sh`, not the lists.
- **Dotfiles:** Hyprland 0.56+ Lua config (`hyprland.lua` + `conf/*.lua`; check https://wiki.hypr.land and `/usr/share/hypr/stubs/hl.meta.lua`; verify with `Hyprland --verify-config -c ~/.config/hypr/hyprland.lua`). hyprlock, hypridle, hyprpaper and hyprsunset keep their hyprlang `.conf` files; no absolute `/home/<user>` paths — use `~` or `$HOME`; no secrets in the repo.
- **Docs:** when behaviour, flags, packages or keybindings change, update the matching page in `docs/` (keybindings → `docs/usage/keybindings.md`).

## House style

Everything should read as if one careful person wrote it. Based on the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html), trimmed to what this repo uses.

**Bash**

- Shebang `#!/usr/bin/env bash`, then a one-line `# Purpose.` comment, then `# Usage: …` lines if the script takes arguments.
- Standalone scripts (`install.sh`, `dotfiles/bin/`, `waybar/scripts/`): header, blank line, `set -euo pipefail`, `readonly` UPPER_SNAKE constants, functions, `main()` last, file ends with `main "$@"`. `install.sh` drops `-e` on purpose: it handles module failures itself.
- `lib/` and `modules/` are sourced: no `set` line and no `main`. Globals are UPPER_SNAKE at the top of the file (not `readonly`, so a file can be sourced again). Modules run under `set -Eeuo pipefail` (`run_module`), so the last line of a function is `if …; then …; fi`, never `cond && action`.
- 4-space indent, `snake_case` names, `local` for every function variable (assign `$(…)` on a separate line), `[[ ]]` for tests, `(( ))` for numbers, `$(…)` never backticks, quote every expansion, no space after redirects (`>/dev/null`, `<<EOF`).
- Function comment: one line above the function, only when the name doesn't tell the whole story (arguments, side effects, why).

**Configs** (`dotfiles/`, `etc/`)

- First line says what the file is, with an upstream docs link where one exists.
- Sections: `# --- Name ---` (`/* --- Name --- */` in CSS/rasi, `// --- Name ---` in JSONC), sentence case, no blank line after the divider.
- No comments that restate the line; keep the ones that explain a value or a workaround. Plain JSON has no comments. Vendored upstream files (`ranger/rc.conf`, `ranger/scope.sh`) keep their upstream comments.

**Lists:** each `packages/*.txt` starts with one `# What this group is for` line; sub-groups are separated by a blank line and their own comment. `services.txt` keeps its columns aligned.

**Docs:** second person, plain verbs, sentence-case headings. Emoji headings only in `README.md`. Install pages number their sections (`## 4.1.`) and end with `---` and `**Next:** [… →](…)`. Every code block names its language (`bash`, `text`, `ini`…); prettier formats tables.

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
