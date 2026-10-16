# Contributing

Thanks for your interest in the project! Here's everything you need for a smooth contribution.

## Setup

```bash
git clone https://github.com/Zilero232/arch-install-kit.git
cd arch-install-kit
bun install        # commitlint, husky (git hooks), shellcheck, prettier
```

The hooks enable themselves: before each commit the scripts are checked and Markdown/JSON/YAML gets formatted, and commitlint validates the commit message.

## Before you write code

- Read [how the repo is laid out](./docs/reference/structure.md) — it has the rules for modules and dotfiles.
- Need a new package? Add it to the matching [`packages/<group>.txt`](./docs/reference/packages.md) and double-check the name with `yay -Ss`.
- Look for an existing solution first (a package, a tool, a drop-in file) before writing your own.

## Style

Write so that the whole repo reads as if one careful person wrote it. The full house style is in [AGENTS.md](./AGENTS.md#house-style); the short version:

- **Readability beats brevity.** Short functions, clear names, comments explain _why_, never restate the line.
- **Bash** ([Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html), trimmed): `#!/usr/bin/env bash`, a one-line purpose comment (plus `# Usage:` if it takes arguments), 4-space indent, `snake_case`, `local` variables, `[[ ]]`, quoted expansions. Standalone scripts use `set -euo pipefail`, `readonly` constants and end with `main "$@"`; `lib/` and `modules/` are sourced and have neither.
- Anything that changes the system goes through `run`, so `--dry-run` keeps working.
- **Configs:** first line says what the file is (plus an upstream docs link), sections look like `# --- Name ---` (`/* --- Name --- */` in CSS/rasi).
- **Docs:** second person, sentence-case headings, a language on every code block; install pages end with a **Next:** link.
- No absolute `/home/<user>` paths and no secrets in configs.

Checks:

```bash
bun run lint              # shellcheck
./install.sh --dry-run    # on Arch: what would change
```

## Commits

Format: gitmoji + conventional commits:

```text
<emoji> <type>(<scope>): <what changed, lowercase>
```

```text
✨ feat(hypr): add clipboard history on Super+V
🐛 fix(installer): skip plymouth when not installed
📝 docs: describe --link mode
📦️ build(packages): replace redshift with hyprsunset
```

| Type     | Emoji | When                            |
| -------- | ----- | ------------------------------- |
| feat     | ✨    | new feature                     |
| fix      | 🐛    | bug fix                         |
| docs     | 📝    | documentation                   |
| style    | 💄    | look and feel, themes           |
| refactor | ♻️    | rework without behavior changes |
| perf     | ⚡️    | performance                     |
| build    | 📦️    | packages and dependencies       |
| chore    | 🔧    | configs, small stuff            |

Scopes: `installer`, `packages`, `hypr`, `waybar`, `rofi`, `shell`, `dotfiles`, `scripts`, `login`, `docs`, `tooling`, `deps`.

Don't feel like remembering the format? `bun run commit` walks you through it.

## Pull requests

1. Branch off `master`: `git checkout -b feat/clipboard-history`.
2. One logical change per PR.
3. Changed flags, packages or keybindings? Update the [docs](./docs).
4. In the description: what and why, and how you tested it.

## Bugs and ideas

[Issues](https://github.com/Zilero232/arch-install-kit/issues): what you did, what you expected, what you got, the log `~/.local/state/arch-install-kit/install-*.log`, and the output of `hyprctl version`.
