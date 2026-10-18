#!/usr/bin/env bash
# Safe edits: system files are backed up once, user files go to a dated backup dir.

BACKUP_DIR="$HOME/.config-backup/$(date +%F-%H%M%S)"
# Copy mode renders this file instead of rsyncing it (see swaync_config_render)
SWAYNC_CONFIG=.config/swaync/config.json
BACKLIGHT_DIR="${KIT_BACKLIGHT_DIR:-/sys/class/backlight}"

# --- System files ---

# /etc/foo.conf -> /etc/foo.conf.kit.bak (only before the first change)
backup_once() {
    local file="$1"

    if [[ -f "$file" ]] && [[ ! -f "$file.kit.bak" ]]; then
        run sudo cp -a "$file" "$file.kit.bak"
    fi

    return 0
}

# --- Dotfiles ---

# Copy mode: rsync moves every file it replaces into BACKUP_DIR.
# The swaync config is left out: the dotfiles module writes it with this machine's backlight.
dotfiles_copy() {
    run rsync -a --backup --backup-dir="$BACKUP_DIR" \
        --exclude="/$SWAYNC_CONFIG" \
        "$KIT_DIR/dotfiles/" "$HOME/"
}

# The repo's swaync config with this machine's backlight device (amdgpu_bl1, intel_backlight…)
# for the brightness slider; the repo's device stays when there is none (a desktop)
# The backlight that actually works: a raw driver (amdgpu_bl1, intel_backlight) beats a platform
# one, which beats acpi_video* (firmware); empty when the machine has none
preferred_backlight() {
    local kind
    local device

    for kind in raw platform firmware; do
        for device in "$BACKLIGHT_DIR"/*; do
            if [[ -f "$device/type" ]] && [[ "$(<"$device/type")" == "$kind" ]]; then
                basename "$device"
                return 0
            fi
        done
    done
}

swaync_config_render() {
    local filter=.
    local device

    device="$(preferred_backlight)"
    if [[ -n "$device" ]]; then
        # shellcheck disable=SC2016 # $device is a jq variable, not a shell one
        filter='."widget-config".backlight.device = $device'
    fi

    jq --tab --arg device "$device" "$filter" "$KIT_DIR/dotfiles/$SWAYNC_CONFIG"
}

# update_home_file <path under $HOME>: writes stdin there unless the file already holds it,
# so re-runs don't back up an unchanged file; a different old file goes to BACKUP_DIR first
update_home_file() {
    local target="$1"
    local dest="$HOME/$target"
    local status=0
    local content tmp

    content="$(cat)"
    if [[ -f "$dest" ]] && [[ "$(<"$dest")" == "$content" ]]; then
        return 0
    fi

    if [[ -e "$dest" ]] || [[ -L "$dest" ]]; then
        run mkdir -p "$(dirname "$BACKUP_DIR/$target")"
        run mv "$dest" "$BACKUP_DIR/$target"
    fi

    # Through a temp file, not `printf | run tee`: a dry run would leave printf writing to
    # a closed pipe (SIGPIPE under pipefail)
    tmp="$(mktemp)"
    printf '%s\n' "$content" >"$tmp"
    run install -Dm644 "$tmp" "$dest" || status=$?
    rm -f "$tmp"

    return "$status"
}

# Paths that stow turns into symlinks: ~/.config/<app>, ~/bin, ~/.gtkrc-2.0 ...
# ~/.local holds app data and state, so only its individual files are linked
dotfiles_targets() {
    find "$KIT_DIR/dotfiles" -mindepth 1 -maxdepth 1 \
        ! -name .config \
        ! -name .local \
        -printf '%P\n'
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
