#!/usr/bin/env bash
# Safe edits: system files are backed up once, user files go to a dated backup dir.

BACKUP_DIR="$HOME/.config-backup/$(date +%F-%H%M%S)"

# /etc/foo.conf -> /etc/foo.conf.kit.bak (only before the first change)
backup_once() {
    local file="$1"
    if [[ -f "$file" ]] && [[ ! -f "$file.kit.bak" ]]; then
        run sudo cp -a "$file" "$file.kit.bak"
    fi
    return 0
}

# Copy mode: rsync moves every file it replaces into BACKUP_DIR
dotfiles_copy() {
    run rsync -a --backup --backup-dir="$BACKUP_DIR" "$KIT_DIR/dotfiles/" "$HOME/"
}

# Paths that stow turns into symlinks: ~/.config/<app>, ~/bin, ~/.gtkrc-2.0 ...
# ~/.local holds app data and state, so only its individual files are linked
dotfiles_targets() {
    find "$KIT_DIR/dotfiles" -mindepth 1 -maxdepth 1 ! -name .config ! -name .local -printf '%P\n'
    find "$KIT_DIR/dotfiles/.config" -mindepth 1 -maxdepth 1 -printf '.config/%P\n'
    find "$KIT_DIR/dotfiles/.local" -type f -printf '.local/%P\n'
}

# Link mode: GNU stow symlinks dotfiles/ into $HOME; real files in the way are moved aside first
dotfiles_link() {
    local target
    while read -r target; do
        if [[ -e "$HOME/$target" ]] && [[ ! -L "$HOME/$target" ]]; then
            run mkdir -p "$BACKUP_DIR/$(dirname "$target")"
            run mv "$HOME/$target" "$BACKUP_DIR/$target"
        fi
    done < <(dotfiles_targets)

    # A real directory here stops stow from folding it into a symlink into the repo
    run mkdir -p "$HOME/.local/share/applications"
    run stow --restow -d "$KIT_DIR" -t "$HOME" dotfiles
}
