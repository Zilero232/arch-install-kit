#!/usr/bin/env bats
# Modules run through run_module in dry-run mode, with mocks deciding what is "installed".
# Only modules whose checks read $HOME, the repo or mockable commands are covered here;
# the others grep fixed /etc paths, which the CI dry run of install.sh exercises instead.

load helpers

setup() {
    setup_sandbox
    mock_pacman
    export DRY_RUN=1
    export LINK_DOTFILES=0
}

# run_kit_module <file>: runs modules/<file> the way install.sh does, both streams captured
run_kit_module() {
    run kit "run_module \"\$KIT_DIR/modules/$1\" 1 1 2>&1"
}

# --- 80-dotfiles ---

@test "dotfiles: copy mode rsyncs into HOME with a dated backup dir" {
    run_kit_module 80-dotfiles.sh

    assert_success
    assert_output --regexp "\[dry\] rsync -a --backup --backup-dir=$HOME/.config-backup/[0-9-]+ $REPO_DIR/dotfiles/ $HOME/"
    assert_line "  [ok] Dotfiles deployed"
    refute_output --partial "stow"
    refute_output --partial "hypr-legacy"
}

@test "dotfiles: old hyprlang files are moved to the backup, the kept .conf files are not" {
    mkdir -p "$HOME/.config/hypr/conf"
    touch "$HOME/.config/hypr/hyprland.conf" \
        "$HOME/.config/hypr/conf/bindings.conf" \
        "$HOME/.config/hypr/hypridle.conf"

    run_kit_module 80-dotfiles.sh

    assert_success
    assert_output --regexp "\[dry\] mv $HOME/.config/hypr/hyprland.conf .+/hypr-legacy/"
    assert_output --regexp "\[dry\] mv $HOME/.config/hypr/conf/bindings.conf .+/hypr-legacy/"
    refute_output --partial "hypridle.conf"
}

@test "dotfiles: link mode uses stow and moves real files out of the way first" {
    mkdir -p "$HOME/.config/waybar"

    LINK_DOTFILES=1 run_kit_module 80-dotfiles.sh

    assert_success
    assert_output --regexp "\[dry\] mv $HOME/.config/waybar .+/.config/waybar"
    assert_line "  [dry] stow --restow -d $REPO_DIR -t $HOME dotfiles"
    refute_output --partial "rsync"
}

@test "dotfiles: papirus folders are recoloured only when papirus-folders is installed" {
    mock_cmd papirus-folders 'echo "  blue"'

    run_kit_module 80-dotfiles.sh
    refute_output --partial "papirus-folders -C"

    mock_pacman papirus-folders
    run_kit_module 80-dotfiles.sh
    assert_line "  [dry] sudo papirus-folders -C violet --theme Papirus-Dark"
}

# --- 90-services ---

@test "services: only units whose package is installed are enabled" {
    mock_pacman networkmanager mpd
    mock_cmd systemctl 'echo enabled'

    run_kit_module 90-services.sh

    assert_success
    assert_line "  [dry] sudo systemctl enable NetworkManager.service"
    assert_line "  [dry] systemctl --user enable mpd.socket"
    refute_output --partial "bluetooth.service"
    refute_output --partial "unmask"
}

@test "services: a masked rfkill socket is unmasked" {
    mock_cmd systemctl 'echo masked'

    run_kit_module 90-services.sh

    assert_success
    assert_line "  [dry] sudo systemctl unmask systemd-rfkill.service systemd-rfkill.socket"
}
