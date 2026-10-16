# Abbreviations: typed shortcut expands in place, so history shows the real command.

status is-interactive; or return

# --- Dev tools ---
abbr -a n npm
abbr -a y yarn
abbr -a p pnpm
abbr -a b bun
abbr -a c composer
abbr -a m make
abbr -a t tmux
abbr -a g git
abbr -a h history

# --- System ---
abbr -a syslog sudo dmesg --level=err,warn
abbr -a journal journalctl -xef
abbr -a vacuum journalctl --vacuum-size=100M

# --- Network ---
abbr -a myip curl ifconfig.me
abbr -a ports ss -tulpn

# --- Boot and login themes (scripts in ~/bin) ---
abbr -a plymouth_theme_list ~/bin/plymouth_theme.sh list
abbr -a plymouth_theme_set ~/bin/plymouth_theme.sh set
abbr -a sddm_theme_list ~/bin/sddm_theme.sh list
abbr -a sddm_theme_set ~/bin/sddm_theme.sh set
