# Environment for every fish session (login, interactive and scripts).

set -gx TERM xterm-256color
set -gx EDITOR vim
set -gx VISUAL vim
set -gx BROWSER google-chrome-stable

# bun
set -gx BUN_INSTALL $HOME/.bun
fish_add_path $BUN_INSTALL/bin
