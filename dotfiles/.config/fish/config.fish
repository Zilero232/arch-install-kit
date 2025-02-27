# =================
# BASIC SETTINGS
# =================
set -U fish_greeting                      # Disable greeting
set -gx TERM xterm-256color               # 256 colors support
set -gx EDITOR micro                      # Default editor
set -gx VISUAL micro                      # Visual editor
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

# Plymouth theme management
function list-themes
    if command -v plymouth-set-default-theme >/dev/null
        plymouth-set-default-theme -l
    else
        echo "Plymouth is not installed. Please install plymouth first."
    end
end

function set-theme
    if test (count $argv) = 1
        if command -v plymouth-set-default-theme >/dev/null
            # Check if theme exists in the list
            if plymouth-set-default-theme -l | string match -q -- $argv[1]
                sudo plymouth-set-default-theme -R $argv[1]

                echo "Theme '$argv[1]' has been set successfully."
            else
                echo "Theme '$argv[1]' not found. Use 'list-themes' to see available themes."
            end
        else
            echo "Plymouth is not installed. Please install plymouth first."
        end
    else
        echo "Usage: set-theme <theme-name>"
        echo "Use 'list-themes' to see available themes."
    end
end

# SDDM theme setup
function set-sddm-theme
    if test -f /usr/share/sddm/themes/sddm-astronaut-theme/setup.sh
        sudo sh /usr/share/sddm/themes/sddm-astronaut-theme/setup.sh

        echo "SDDM Astronaut theme has been set successfully."
    else
        echo "SDDM Astronaut theme is not installed. Please install it first."
    end
end