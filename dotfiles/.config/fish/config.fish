# =================
# BASIC SETTINGS
# =================
set -U fish_greeting          # Disable greeting
set -gx TERM xterm-256color   # 256 colors support
set -gx EDITOR micro          # Default editor
set -gx VISUAL micro          # Visual editor
set -gx BROWSER firefox       # Default browser

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

# ===========
# PATH
# ===========
if test -d ~/.local/bin
    set -gx PATH ~/.local/bin $PATH
end

# =======
# ALIASES
# =======

# Basic
alias cls="clear"
alias g="git"
alias n="nvim"
alias m="micro"

# System management
alias syslog="sudo dmesg --level=err,warn"
alias journal="journalctl -xef"
alias vacuum="journalctl --vacuum-size=100M"
alias update="sudo pacman -Syu"

# Network
alias myip="curl ifconfig.me"
alias ports="netstat -tulanp"

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

# Show weather
function weather
    if test -n "$argv[1]"
        curl -s "wttr.in/$argv[1]?format=3"
    else
        curl -s "wttr.in/?format=3"
    end
end