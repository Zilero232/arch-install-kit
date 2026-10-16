# Fish shell

Config: [`dotfiles/.config/fish`](https://github.com/Zilero232/arch-install-kit/tree/master/dotfiles/.config/fish). The prompt is [Oh My Posh](https://ohmyposh.dev) with the theme in `~/.config/ohmyposh/config.json`; plugins come from `fish_plugins` via [fisher](https://github.com/jorgebucaran/fisher).

## Shortcuts

| Type | Expands to |
| ---- | ---------- |
| `n`  | `npm`      |
| `y`  | `yarn`     |
| `p`  | `pnpm`     |
| `b`  | `bun`      |
| `c`  | `composer` |
| `m`  | `make`     |
| `t`  | `tmux`     |
| `g`  | `git`      |
| `h`  | `history`  |

## System

| Command                                             | What it does                         |
| --------------------------------------------------- | ------------------------------------ |
| `syslog`                                            | kernel errors and warnings (`dmesg`) |
| `journal`                                           | follow the systemd journal           |
| `vacuum`                                            | shrink the journal to 100 MB         |
| `myip`                                              | your public IP                       |
| `ports`                                             | listening ports (`ss -tulpn`)        |
| `plymouth_theme_list` / `plymouth_theme_set <name>` | boot splash themes                   |
| `sddm_theme_list` / `sddm_theme_set <variant>`      | SDDM Astronaut variants              |

## Functions

| Function     | What it does                           |
| ------------ | -------------------------------------- |
| `mkcd <dir>` | create a directory and `cd` into it    |
| `f <name>`   | find files by name in the current tree |
| `pack <dir>` | archive a directory to `<dir>.tar.gz`  |

## Environment

`EDITOR`/`VISUAL` = nvim, `BROWSER` = google-chrome-stable, `~/.bun/bin` is on `PATH`. Tool versions (node, bun, python…) are managed by [mise](https://mise.jdx.dev): `mise use -g node@lts`, or a `mise.toml` per project.
