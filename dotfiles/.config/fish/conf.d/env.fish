# Environment for every fish session (login, interactive and scripts).
# TERM is left to the terminal (alacritty sets its own).

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx BROWSER google-chrome-stable

# bun: global packages (`bun add -g`) land in ~/.bun/bin
set -gx BUN_INSTALL $HOME/.bun
fish_add_path --global $BUN_INSTALL/bin
