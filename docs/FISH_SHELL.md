# 🐟 Fish Shell Configuration

## 🎨 Basic Settings

**📂 Location:** `~/.config/fish/config.fish`

**Features:**
- Disabled greeting message
- 256 colors terminal support
- Micro as default editor
- Google Chrome as default browser
- Oh My Posh prompt customization

## 🌈 Color Scheme

Custom color scheme for better readability:
- Normal text: Default color
- Commands: Blue
- Parameters: Cyan
- Redirections: Yellow
- Quotes: Green
- Errors: Red
- End tokens: Yellow
- Comments: Bright black
- Selection: Bright black background
- Search matches: Bright black background
- Operators: Cyan
- Escape sequences: Magenta
- Autosuggestions: Bright black
- Valid paths: Underlined

## 🔧 Package Management Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `n` | `npm` | Node.js package manager |
| `y` | `yarn` | Alternative Node.js package manager |
| `p` | `pnpm` | Performance Node.js package manager |
| `c` | `composer` | PHP package manager |
| `m` | `make` | Build automation tool |
| `t` | `tmux` | Terminal multiplexer |
| `g` | `git` | Version control |
| `h` | `history` | Command history |

## ⚙️ System Management Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `syslog` | `sudo dmesg --level=err,warn` | View system error logs |
| `journal` | `journalctl -xef` | Follow system journal |
| `vacuum` | `journalctl --vacuum-size=100M` | Clean journal files |

## 🌐 Network Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `myip` | `curl ifconfig.me` | Show public IP address |
| `ports` | `netstat -tulanp` | List open ports |

## 🎨 Theme Management

| Alias | Command | Description |
|-------|---------|-------------|
| `plymouth_theme_list` | `~/bin/plymouth_theme.sh list` | List Plymouth themes |
| `plymouth_theme_set` | `~/bin/plymouth_theme.sh set` | Set Plymouth theme |
| `sddm_theme` | `~/bin/sddm_theme.sh` | Manage SDDM themes |

## 🛠️ Custom Functions

### 📁 mkcd
Create directory and navigate into it
```fish
mkcd directory_name
```

### 🔍 f
Quick file search in current directory
```fish
f search_term
```

### 📦 pack
Create tar.gz archive from directory
```fish
pack directory_name
```

## 🎨 Prompt Customization

Using Oh My Posh for custom prompt with configuration:
```fish
oh-my-posh init fish --config $HOME/.config/ohmyposh/config.json | source
```

## 🌟 Environment Variables

| Variable | Value | Description |
|----------|-------|-------------|
| `TERM` | `xterm-256color` | Terminal type with color support |
| `EDITOR` | `vim` | Default text editor |
| `VISUAL` | `vim` | Visual editor |
| `BROWSER` | `google-chrome-stable` | Default web browser |
| `BUN_INSTALL` | `$HOME/.bun` | Bun installation directory |

## 🎯 Tips & Tricks

1. Use Tab for command completion
2. Use Alt+← and Alt+→ for word navigation
3. Use Ctrl+R for history search
4. Custom prompt provides Git status and environment info
5. System aliases help with common maintenance tasks
6. Package manager aliases speed up development workflow