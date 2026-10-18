# fzf key bindings: Ctrl+R history, Ctrl+T file under the cursor, Alt+C cd into a folder

status is-interactive; or return
type -q fzf; or return

set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --exclude .git'
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
# Kanagawa: sumiInk4, fujiWhite, oniViolet, sakuraPink, crystalBlue, sumiInk6 (~/.config/theme/kanagawa.css)
set -gx FZF_DEFAULT_OPTS '--height 40% --layout reverse --border rounded --color bg+:#2a2a37,fg+:#dcd7ba,hl:#957fb8,hl+:#d27e99,pointer:#d27e99,prompt:#7e9cd8,border:#54546d'
fzf --fish | source
