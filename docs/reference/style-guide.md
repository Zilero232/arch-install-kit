# Style guide

Write so that the whole repo reads as if one careful person wrote it. This page explains the rules with short examples; [AGENTS.md](https://github.com/Zilero232/arch-install-kit/blob/master/AGENTS.md#house-style) keeps the same rules as a checklist.

The shell rules follow the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html), trimmed to what this repo uses, plus the traps listed in [Bash Pitfalls](https://mywiki.wooledge.org/BashPitfalls) and the [ShellCheck wiki](https://www.shellcheck.net/wiki/).

## Before you write a script

Look for a package, a systemd timer, a drop-in file or a built-in feature first (Waybar signals, Hyprland rules). A script is the last resort, and every script is code you have to keep working.

## Script layout

There are two kinds of shell files, and they look different on purpose.

**Standalone scripts** (`install.sh`, `dotfiles/bin/`, `waybar/scripts/`) run on their own:

```bash
#!/usr/bin/env bash
# Opens wlogout with margins sized to the focused monitor.
# Usage: power_menu.sh

set -euo pipefail

readonly BUTTONS_PER_ROW=5

vertical_margin() {
    …
}

main() {
    …
}

# Sourcing the file (tests) loads the functions without running main
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
```

Scripts in `dotfiles/bin/` and `waybar/scripts/` end with that guard, so a test can `source` them and call one function. `install.sh` and `tests/packages.sh` only ever run whole and end with a plain `main "$@"`.

**Sourced files** (`lib/`, `modules/`) are read by `install.sh`. They have no `set` line and no `main`; globals are `UPPER_SNAKE` at the top and not `readonly`, so a file can be sourced again. Each module runs in its own subshell under `set -Eeuo pipefail`, so an error stops only that module.

Hooks that systemd calls with `/bin/sh` (`etc/systemd/system-sleep/`) may stay POSIX `sh`.

## Formatting and names

- 4-space indent, `snake_case` for functions and variables, `UPPER_SNAKE` for constants and globals.
- `local` for every function variable. Assign command output on its own line, because `local` hides the command's exit status:

```bash
# Bad: local always succeeds, so a failing hyprctl goes unnoticed
local name="$(hyprctl -j activewindow | jq -r .class)"

# Good
local name
name="$(hyprctl -j activewindow | jq -r .class)"
```

- `[[ ]]` for tests, `(( ))` for numbers, `$(…)` instead of backticks, no space after redirects (`>/dev/null`).
- Quote every expansion: `"$file"`, `"${args[@]}"`, `"$(cmd)"`.
- A function comment is one line above the function, and only when the name doesn't tell the whole story.

## Layout

Give the code room to breathe. [`lib/log.sh`](https://github.com/Zilero232/arch-install-kit/blob/master/lib/log.sh) is the reference:

- Declare locals first, one per line, then leave a blank line before the body. Uninitialized loop variables may share one line: `local entry name status`.
- Separate logical steps (checks, work, output) with one blank line, and leave one before the final `return` or result line of a longer function.
- Write one command per line: no `a=1 b=2` chains, no `cond && action` or `cond || die` one-liners, no one-line `f() { …; }` bodies.
- Never squeeze an `if`, `for`, `while` or `case` arm onto one line; keep `then` and `do` on the condition line.
- Break lines longer than about 100 characters with `\`, one option group per line, continuation indented 4 spaces.
- Group the functions of a file under `# --- Name ---` dividers in sentence case.
- In modules, split top-level code into blocks with one blank line between them; start a block with a one-line comment that says why, when that isn't obvious.
- Keep functions short (about 25 lines at most); split one only when that reads better.

```bash
# Bad
pkg_install_list() {
    local file="$PACKAGES_DIR/$1.txt" pkgs
    [[ -f "$file" ]] || die "No package list: $file"
    mapfile -t pkgs < <(read_pkgs "$file"); pkg_install "${pkgs[@]}"
}

# Good
pkg_install_list() {
    local group="$1"
    local file="$PACKAGES_DIR/$group.txt"
    local pkgs=()

    if [[ ! -f "$file" ]]; then
        die "No package list: $file"
    fi

    mapfile -t pkgs < <(read_pkgs "$file")
    info "$group: ${#pkgs[@]} packages"
    pkg_install "${pkgs[@]}"
}
```

## Output and exit codes

Data goes to stdout, messages go to stderr. In the installer, `warn`, `err` and `die` from `lib/log.sh` already write to stderr, and the log file gets both streams.

```bash
# Bad
echo "Variant '$1' not found"
exit 1

# Good
echo "Variant '$1' not found" >&2
exit 1
```

Use `printf '%s\n' "$var"` for data you don't control; `echo` misreads values such as `-n`. Exit with `0` on success and `1` on failure; a usage error prints the usage to stderr.

## Reading input and lists

Read line by line with `read -r` and process substitution. A pipe into `while` runs the loop in a subshell, so anything it sets is lost:

```bash
# Bad: pkgs is empty after the loop
read_pkgs "$file" | while read -r pkg; do pkgs+=("$pkg"); done

# Good
while read -r pkg; do
    pkgs+=("$pkg")
done < <(read_pkgs "$file")

# Simpler when you only need the lines
mapfile -t pkgs < <(read_pkgs "$file")
```

Use globs, never the output of `ls`. A glob that matches nothing stays literal, so check before you use it:

```bash
for file in "$HOME"/.config/hypr/conf/*.conf; do
    if [[ -f "$file" ]]; then
        …
    fi
done
```

## Commands and arguments

Keep argument lists in arrays, never in a string, and don't use `eval`:

```bash
# Bad: breaks on spaces, needs word splitting
flags="--needed --noconfirm"
yay -S $flags "$pkg"

# Good
YAY_FLAGS=(--needed --noconfirm)
yay -S "${YAY_FLAGS[@]}" "$pkg"
```

Check for a tool with `command -v tool >/dev/null`, not `which`.

## Errors and `set -e`

`set -e` does not fire everywhere. It is off inside `if` and `while` conditions, on either side of `&&` and `||`, and for a `$(…)` that is an argument to another command. Check those failures yourself:

```bash
# Bad: if settings.ini is missing, gsettings gets an empty value and the script carries on
gsettings set "$SCHEMA" gtk-theme "$(ini_value gtk-theme-name)"

# Good: fail early with a clear message
if [[ ! -f "$SETTINGS" ]]; then
    echo "Error: $SETTINGS not found" >&2
    exit 1
fi
```

In modules, the last line of a function is `if …; then …; fi`, never `cond && action`: when `cond` is false the function returns non-zero and the module stops.

This reaches into subshells too: `if ! ( set -e; … ); then` runs the whole subshell with `set -e` off, however it is set inside. Run the subshell as a plain statement and read `$?` afterwards, as `run_module` in `lib/run.sh` does.

Add `|| true` only for a failure that is expected and harmless, such as `pkill` finding nothing.

With `pipefail`, `big_output | grep -q pattern` can fail: `grep` exits on the first match and the writer dies of SIGPIPE. Prefer a direct test (`[[ -d /sys/module/ath11k_pci ]]`, `is_installed pkg`, `grep -q pattern file`).

## System changes and dry run

Every command that changes the system goes through `run`, so `--dry-run` prints it instead. Read-only checks run directly, so the dry run sees the real state and prints what a real run would do.

```bash
if ! grep -q '^GRUB_DISABLE_OS_PROBER=false' /etc/default/grub; then
    backup_once /etc/default/grub
    echo 'GRUB_DISABLE_OS_PROBER=false' | run sudo tee -a /etc/default/grub >/dev/null
fi
```

- **Idempotent:** check first, change second, so a re-run changes nothing.
- **Back up** with `backup_once` before editing a file in `/etc`; better, write a drop-in with `write_root_file`.
- **Root files:** `sudo cmd >/etc/file` fails, because the redirect runs as you. Use `write_root_file` or `| run sudo tee file >/dev/null`.

## Temp files, traps and processes

Create temp files with `mktemp` and remove them on every way out. A module runs in its own subshell, so an `EXIT` trap fires when the module ends, even after an error:

```bash
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
```

A trap on `INT` or `TERM` must exit, or Ctrl+C runs the trap and the script carries on:

```bash
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null' EXIT
trap 'exit 130' INT TERM
```

When you stop processes:

- `pkill -x name` matches the exact process name. `pkill -f pattern` matches any command line that contains the pattern, including the shell that runs `pkill`.
- `pkill -P "$$"` reaches direct children only. A backgrounded pipeline (`cmd | while …; done &`) leaves its commands running as grandchildren.
- Start daemons with `cmd >/dev/null 2>&1 &` followed by `disown`.

## ShellCheck

`bun run lint` runs ShellCheck on every tracked `.sh` file, and the pre-commit hook runs it on staged ones. Keep it clean. When a warning is wrong, disable it on that one line and say why:

```bash
# shellcheck source=/dev/null
source "$file"
```

Repo-wide exceptions live in [`.shellcheckrc`](https://github.com/Zilero232/arch-install-kit/blob/master/.shellcheckrc).

## Configs

- The first line says what the file is, with a link to the upstream docs where one exists.
- Sections look like `# --- Name ---` (`/* --- Name --- */` in CSS and rasi, `// --- Name ---` in JSONC), in sentence case, with no blank line after the divider.
- Comments explain a value or a workaround; they never restate the line.
- No absolute `/home/<user>` paths (use `~` or `$HOME`) and no secrets.

## Docs

- Write in the second person with plain verbs: "Run `./install.sh --dry-run`", not "The user should run…".
- Headings are in sentence case. Emoji headings only in `README.md`.
- Every code block names its language: `bash`, `text`, `ini`, `lua`…
- Link other docs pages with relative `.md` links (`./packages.md`). Link files outside `docs/` with full GitHub URLs, because the site only builds `docs/`.
- Write keys as `Super + X`.
- Install pages number their sections (`## 4.1.`) and end with `---` and a **Next:** link.
- A new page goes into the sidebar in [`website/.vitepress/config.mts`](https://github.com/Zilero232/arch-install-kit/blob/master/website/.vitepress/config.mts) and into [`docs/README.md`](https://github.com/Zilero232/arch-install-kit/blob/master/docs/README.md).
- Format changed Markdown with `bunx prettier --write <files>`; prettier also lines up tables.

When behavior changes, update the matching page:

| What changed                                | Page                                                    |
| ------------------------------------------- | ------------------------------------------------------- |
| Keybindings                                 | [Keybindings](../usage/keybindings.md)                  |
| Scripts in `~/bin`, built-in features       | [Scripts](../usage/scripts.md)                          |
| Fish abbreviations and functions            | [Fish](../usage/fish.md)                                |
| Colors, GTK theme, wallpapers, login screen | [Theming](../usage/theming.md)                          |
| Gaming packages and tweaks                  | [Gaming](../usage/gaming.md)                            |
| Packages and groups                         | [Packages](./packages.md)                               |
| `install.sh` flags                          | [4. Running install.sh](../install/04-run-installer.md) |
| Repo layout, module rules                   | [Repository structure](./structure.md)                  |
| A known problem and its fix                 | [Troubleshooting](./troubleshooting.md)                 |
| Tests and how to run them                   | [Testing](./testing.md)                                 |
