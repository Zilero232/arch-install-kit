# Fish shell

Config: [`dotfiles/.config/fish`](https://github.com/Zilero232/arch-install-kit/tree/master/dotfiles/.config/fish). The prompt is [Oh My Posh](https://ohmyposh.dev) with the theme in `~/.config/ohmyposh/config.json`.

## Shortcuts

| Type | Expands to |
| ---- | ---------- |
| `n`  | `npm`      |
| `b`  | `bun`      |
| `c`  | `composer` |
| `m`  | `make`     |
| `t`  | `tmux`     |
| `g`  | `git`      |
| `h`  | `history`  |

## System

| Command                                             | What it does                                    |
| --------------------------------------------------- | ----------------------------------------------- |
| `syslog`                                            | kernel errors and warnings (`sudo dmesg`)       |
| `journal`                                           | follow the systemd journal                      |
| `vacuum`                                            | shrink the journal to 100 MB                    |
| `myip`                                              | your public IP                                  |
| `ports`                                             | listening ports (`ss -tulpn`)                   |
| `plymouth_theme_list` / `plymouth_theme_set <name>` | boot splash themes (set rebuilds the initramfs) |
| `sddm_theme_list` / `sddm_theme_set <variant>`      | SDDM Astronaut variants                         |

## Search and navigation

| Keys / command | What it does                                       |
| -------------- | -------------------------------------------------- |
| `Ctrl + R`     | search the history with fzf                        |
| `Ctrl + T`     | insert a file path picked with fzf                 |
| `Alt + C`      | `cd` into a folder picked with fzf                 |
| `z <part>`     | jump to the most used folder that matches (zoxide) |
| `zi`           | pick a folder from zoxide's list with fzf          |

fzf lists files with `fd`, hidden ones included, `.git` skipped ([`conf.d/fzf.fish`](https://github.com/Zilero232/arch-install-kit/blob/master/dotfiles/.config/fish/conf.d/fzf.fish), [`conf.d/zoxide.fish`](https://github.com/Zilero232/arch-install-kit/blob/master/dotfiles/.config/fish/conf.d/zoxide.fish)).

## Functions

| Function     | What it does                           |
| ------------ | -------------------------------------- |
| `mkcd <dir>` | create a directory and `cd` into it    |
| `f <name>`   | find files by name in the current tree |
| `pack <dir>` | archive a directory to `<dir>.tar.gz`  |

## Environment

`EDITOR`/`VISUAL` = nvim, `BROWSER` = google-chrome-stable, `~/.bun/bin` is on `PATH`. Tool versions (node, bun, python…) are managed by [mise](https://mise.jdx.dev): `mise use -g node@lts`, or a `mise.toml` per project.
