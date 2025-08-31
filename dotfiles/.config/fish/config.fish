# =================
# BASIC SETTINGS
# =================
set -U fish_greeting                      # Disable greeting
set -gx TERM xterm-256color               # 256 colors support
set -gx EDITOR vim                        # Default editor
set -gx VISUAL vim                        # Visual editor
set -gx BROWSER google-chrome-stable      # Browser

# ================
# COLOR SETTINGS
# ================
set fish_color_normal normal
set fish_color_command blue
set fish_color_param cyan
set fish_color_redirection yellow
set fish_color_quote green
set fish_color_error red
set fish_color_end yellow
set fish_color_comment brblack
set fish_color_selection --background=brblack
set fish_color_search_match --background=brblack
set fish_color_operator cyan
set fish_color_escape magenta
set fish_color_autosuggestion brblack
set fish_color_valid_path --underline

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# =======
# ALIASES
# =======

# Packages management
alias n="npm"
alias y="yarn"
alias p="pnpm"
alias c="composer"
alias m="make"
alias t="tmux"
alias g="git"
alias h="history"

# System management
alias syslog="sudo dmesg --level=err,warn"
alias journal="journalctl -xef"
alias vacuum="journalctl --vacuum-size=100M"

# Network
alias myip="curl ifconfig.me"
alias ports="netstat -tulanp"

# Plymouth theme management
alias plymouth_theme_list="~/bin/plymouth_theme.sh list"
alias plymouth_theme_set="~/bin/plymouth_theme.sh set"

# SDDM theme management
alias sddm_theme="~/bin/sddm_theme.sh"

# =========
# FUNCTIONS
# =========

# Create directory and cd into it
function mkcd
    mkdir -p $argv[1] && cd $argv[1]
end

# Quick file search
function f
    find . -name "*$argv[1]*"
end

# Archive files
function pack
    if test (count $argv) = 1
        tar -czf $argv[1].tar.gz $argv[1]
    else
        echo "Usage: pack <directory>"
    end
end

# oh-my-posh custom prompt
oh-my-posh init fish --config $HOME/.config/ohmyposh/config.json | source