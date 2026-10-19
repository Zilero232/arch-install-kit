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
- **Packages:** add to the right `packages/<group>.txt`; verify the name exists (archlinux.org/packages, AUR RPC). Wayland-native tools only — no X11 utilities (xdotool, redshift, flameshot…). Drivers/microcode belong to `modules/25-gpu.sh` (it runs before the package lists so Steam and co. pick the right Vulkan driver), not the lists.
- **Dotfiles:** Hyprland 0.56+ Lua config (`hyprland.lua` + `conf/*.lua`; check <https://wiki.hypr.land> and `/usr/share/hypr/stubs/hl.meta.lua`; verify with `Hyprland --verify-config -c ~/.config/hypr/hyprland.lua`). hyprlock, hypridle, hyprpaper and hyprsunset keep their hyprlang `.conf` files; no absolute `/home/<user>` paths — use `~` or `$HOME`; no secrets in the repo.
- **Theming:** one Kanagawa palette in `dotfiles/.config/theme/kanagawa.css` — the official [kanagawa.nvim](https://github.com/rebelot/kanagawa.nvim/blob/master/lua/kanagawa/colors.lua) names plus roles (`bg`, `surface`, `text`, `accent`, `frame`, `seal`, `ok`/`warn`/`error`…). Waybar, SwayNC, wlogout and `gtk-3.0/gtk.css` `@import` it; use a role for structure and state, a palette name for a module's own hue, never a raw hex. Change an accent by re-pointing its role there. Files that can't import CSS carry copies of the values — update them by hand: `rofi/colors.rasi`, `alacritty/themes/kanagawa_wave.toml`, `hypr/theme.lua`, `hypr/hyprlock.conf`, `fish/conf.d/fzf.fish`, `waybar/modules.jsonc` (clock and calendar), `MangoHud/MangoHud.conf`, `gowall/config.yml` (see [docs/usage/theming.md](docs/usage/theming.md)). Big stylesheets are plain CSS split into `style/*.css` and imported in order from `style.css` — no SCSS, no build step.
- **Docs:** when behavior, flags, packages or keybindings change, update the matching page in `docs/` (keybindings → `docs/usage/keybindings.md`, colors and themes → `docs/usage/theming.md`).

## House style

Everything should read as if one careful person wrote it. Based on the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html), trimmed to what this repo uses.

**Bash**

- Shebang `#!/usr/bin/env bash`, then a one-line `# Purpose.` comment, then `# Usage: …` lines if the script takes arguments.
- Standalone scripts (`install.sh`, `dotfiles/bin/`, `waybar/scripts/`): header, blank line, `set -euo pipefail`, `readonly` UPPER_SNAKE constants, functions, `main()` last. Scripts in `dotfiles/bin/` and `waybar/scripts/` end with `if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi` (written over three lines) so tests can source them; `install.sh` ends with `main "$@"` and drops `-e` on purpose: it handles module failures itself.
- `lib/` and `modules/` are sourced: no `set` line and no `main`. Globals are UPPER_SNAKE at the top of the file (not `readonly`, so a file can be sourced again). Modules run under `set -Eeuo pipefail` (`run_module`), so the last line of a function is `if …; then …; fi`, never `cond && action`.
- 4-space indent, `snake_case` names, `local` for every function variable (assign `$(…)` on a separate line), `[[ ]]` for tests, `(( ))` for numbers, `$(…)` never backticks, quote every expansion, no space after redirects (`>/dev/null`, `<<EOF`).
- Function comment: one line above the function, only when the name doesn't tell the whole story (arguments, side effects, why).

**Bash layout** (airy, not cramped; `lib/log.sh` is the reference)

- Locals first, one per line (uninitialized loop variables may share one: `local entry name status`), then a blank line, then the body.
- A blank line between logical steps (checks / work / output), and before the final `return` or result line in a function longer than ~5 lines.
- One command per line: no `a=1 b=2` chains, no `cond && action` or `cond || die` one-liners, no one-line `f() { …; }` bodies.
- `if`/`for`/`while`/`case` arms are never one-liners; `then`/`do` stay on the condition line.
- Lines over ~100 characters break with `\`, one option group per line, continuation indented 4 spaces.
- Files with several functions group them under `# --- Name ---` dividers (sentence case).
- Module top-level code is split into blocks separated by one blank line; a block starts with a one-line `# why` comment when the intent isn't obvious.
- Functions stay short (aim for ≤ ~25 lines); split one only when it reads better.

**Bash checklist** (details and examples: [docs/reference/style-guide.md](docs/reference/style-guide.md))

- Output: data to stdout, messages to stderr (`>&2`; `warn`/`err`/`die` already do). `printf '%s\n' "$var"` for arbitrary data, `echo` for fixed text. Usage errors print usage to stderr and `exit 1`.
- Reading: `while read -r …; do …; done < <(cmd)`, never `cmd | while` (the loop runs in a subshell and loses its variables); `mapfile -t arr < <(cmd)`, never `arr=($(cmd))`. Globs, not `ls`; guard a glob that may match nothing with `[[ -e ]]`.
- Commands: argument lists live in arrays (`"${args[@]}"`), never in a string; no `eval`. `command -v tool >/dev/null` to check a tool, not `which`.
- `set -e` is off inside `if`, `while`, `&&`/`||` and in a `$(…)` used as an argument, so check those failures yourself. `|| true` only for a failure that is expected and harmless.
- Under `pipefail`, `big_output | grep -q` can fail with SIGPIPE; prefer a direct test (`[[ -d /sys/module/x ]]`, `is_installed`, `grep -q pat file`).
- Root files: `write_root_file <<<"$text"` or `run sudo tee file >/dev/null <<<"$text"`, never `sudo cmd >/etc/file` (the redirect runs as you) and never `printf … | run …` (in a dry run nothing reads the pipe, so the writer can die of SIGPIPE).
- Dry-run: only changes go through `run`; read-only checks (`grep`, `pacman -Q`, `systemctl is-enabled`) run directly so the dry run sees real state.
- Temp files: `mktemp`, removed by `trap 'rm -rf "$tmp"' EXIT` (a module's trap fires when its subshell ends) or on every path out of the function.
- Traps: a trap on `INT`/`TERM` must `exit` (`trap 'exit 130' INT TERM`), or Ctrl+C is swallowed. Clean up on `EXIT`.
- Processes: `pkill -x name`; `pkill -f pattern` also matches any command line that contains the pattern, the caller's own included. `pkill -P` reaches direct children only, not the commands inside a backgrounded pipeline. Detach daemons with `cmd >/dev/null 2>&1 &` + `disown`.
- ShellCheck: `bun run lint` stays clean. Disable a check on the one line that needs it, with a reason; repo-wide exceptions live in `.shellcheckrc`. Hooks that systemd calls with `/bin/sh` (`etc/systemd/system-sleep/`) may stay POSIX `sh`.

**Configs** (`dotfiles/`, `etc/`)

- First line says what the file is, with an upstream docs link where one exists.
- Sections: `# --- Name ---` (`/* --- Name --- */` in CSS/rasi, `// --- Name ---` in JSONC), sentence case, no blank line after the divider.
- No comments that restate the line; keep the ones that explain a value or a workaround. Plain JSON has no comments. Vendored upstream files (`ranger/rc.conf`, `ranger/scope.sh`) keep their upstream comments.

**Lists:** each `packages/*.txt` starts with one `# What this group is for` line; sub-groups are separated by a blank line and their own comment. `services.txt` keeps its columns aligned.

**Docs:** second person, plain verbs, sentence-case headings. Emoji headings only in `README.md`. Install pages number their sections (`## 4.1.`) and end with `---` and `**Next:** [… →](…)`. Every code block names its language (`bash`, `text`, `ini`…); prettier formats tables.

- Where a change goes: tests and mocks → `docs/reference/testing.md`, keybindings → `docs/usage/keybindings.md`, `~/bin` scripts and built-in replacements → `docs/usage/scripts.md`, fish → `docs/usage/fish.md`, packages and groups → `docs/reference/packages.md`, flags → `docs/install/04-run-installer.md`, layout and module rules → `docs/reference/structure.md`, known problems → `docs/reference/troubleshooting.md`.
- A new page goes into the sidebar (`website/.vitepress/config.mts`) and the index (`docs/README.md`).
- Links: relative `.md` links between docs pages; files outside `docs/` as full GitHub URLs (`https://github.com/Zilero232/arch-install-kit/blob/master/…`), since the site only builds `docs/`. Keys are written `Super + X`.
- Run `bunx prettier --write <files>` on changed Markdown.

## Checks

```bash
mise install         # once: bun and shellcheck versions from mise.toml
bun install          # once: commitlint, husky, prettier, bats, vitepress
bun run lint         # shellcheck for all scripts and tests
bun run test         # offline suite: config checks (bun test), bats, Lua (~10 s)
bun run test:packages    # every listed package exists (network, synced pacman db)
bun run spell        # cspell for the docs (American English)
./install.sh --dry-run   # on Arch: see what would change
```

Tests live in `tests/` ([docs/reference/testing.md](docs/reference/testing.md)); a change to `lib/`, `modules/`, a script or a config gets a test there, and a failing test means fixing the code, not the test. Never run `install.sh` without `--dry-run` on a machine you don't intend to configure.

## Commits

Gitmoji + conventional, enforced by commitlint (`commitlint.config.mjs`):

```text
✨ feat(hypr): add clipboard history on Super+V
🐛 fix(installer): skip plymouth when not installed
📝 docs: describe --link mode
```

Scopes: installer, packages, hypr, waybar, rofi, shell, dotfiles, scripts, login, docs, tooling, deps, tests, theme, system, ci. Interactive helper: `bun run commit`.
