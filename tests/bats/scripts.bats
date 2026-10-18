#!/usr/bin/env bats
# Scripts in dotfiles/bin and waybar/scripts, with hyprctl, wpctl and friends mocked.

load helpers

readonly BIN="$REPO_DIR/dotfiles/bin"
readonly CAVA="$REPO_DIR/dotfiles/.config/waybar/scripts/cava.sh"

setup() {
    setup_sandbox
}

# --- wallpaper.sh ---

@test "wallpaper.sh: an unknown mode prints usage to stderr and exits 1" {
    run --separate-stderr "$BIN/wallpaper.sh" bogus

    assert_failure 1
    assert_output ""
    assert [ "${stderr_lines[0]}" = "Usage: wallpaper.sh [random|pick|live]" ]
}

@test "wallpaper.sh: a fresh install starts with a static picture" {
    run in_script "$BIN/wallpaper.sh" 'saved_mode'

    assert_success
    assert_output static
}

@test "wallpaper.sh: the saved mode is remembered in XDG_STATE_HOME" {
    run in_script "$BIN/wallpaper.sh" 'save_mode live; saved_mode'

    assert_success
    assert_output live
    assert_equal "$(cat "$XDG_STATE_HOME/wallpaper-mode")" live
}

@test "wallpaper.sh: live without the Workshop scene falls back to the static picture" {
    mock_cmd notify-send
    mock_cmd pkill 'exit 1'
    mock_cmd pgrep
    mock_cmd waypaper

    run "$BIN/wallpaper.sh" live

    assert_success
    assert_equal "$(cat "$XDG_STATE_HOME/wallpaper-mode")" static
    run grep -c '^waypaper --restore$' "$MOCK_LOG"
    assert_output 1
}

# --- quick_toggle.sh ---

@test "quick_toggle.sh: an unknown target prints usage and exits 1" {
    run "$BIN/quick_toggle.sh" wifi

    assert_failure 1
    assert_output "Usage: quick_toggle.sh night|mic [status]"
}

@test "quick_toggle.sh: night status follows the hyprsunset temperature" {
    mock_cmd hyprctl 'echo 4500'
    run "$BIN/quick_toggle.sh" night status
    assert_output true

    mock_cmd hyprctl 'echo 6500'
    run "$BIN/quick_toggle.sh" night status
    assert_output false
}

@test "quick_toggle.sh: night status is off when hyprsunset is not running" {
    mock_cmd hyprctl 'exit 1'

    run "$BIN/quick_toggle.sh" night status

    assert_success
    assert_output false
}

@test "quick_toggle.sh: night on sets the warm temperature" {
    mock_cmd hyprctl

    SWAYNC_TOGGLE_STATE=true run "$BIN/quick_toggle.sh" night

    assert_success
    assert_equal "$(mock_calls)" "hyprctl hyprsunset temperature 4500"
}

@test "quick_toggle.sh: night off goes back to the neutral 6500 K" {
    mock_cmd hyprctl

    SWAYNC_TOGGLE_STATE=false run "$BIN/quick_toggle.sh" night

    assert_success
    assert_equal "$(mock_calls)" "hyprctl hyprsunset temperature 6500"
}

@test "quick_toggle.sh: mic status is true while the source is muted" {
    mock_cmd wpctl 'echo "Volume: 0.40 [MUTED]"'
    run "$BIN/quick_toggle.sh" mic status
    assert_output true

    mock_cmd wpctl 'echo "Volume: 0.40"'
    run "$BIN/quick_toggle.sh" mic status
    assert_output false
}

@test "quick_toggle.sh: mic set mutes and unmutes the default source" {
    mock_cmd wpctl

    SWAYNC_TOGGLE_STATE=true run "$BIN/quick_toggle.sh" mic
    assert_success
    SWAYNC_TOGGLE_STATE=false run "$BIN/quick_toggle.sh" mic
    assert_success

    assert_equal "$(mock_calls)" "$(printf '%s\n' \
        'wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1' \
        'wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0')"
}

# --- waybar/scripts/cava.sh ---

@test "cava.sh: the sed script maps 0-7 to bar glyphs and drops separators" {
    run in_script "$CAVA" 'echo "0;1;2;3;4;5;6;7;" | sed "$(build_sed_script)"'

    assert_success
    assert_output "▁▂▃▄▅▆▇█"
}

@test "cava.sh: frames pass through while a player is playing" {
    echo Playing >"$XDG_RUNTIME_DIR/waybar-cava-player"

    run in_script "$CAVA" 'printf "%s\n" ▁▂ ▃▄ ▅▆ | gate_on_player'

    assert_success
    assert_output "$(printf '%s\n' ▁▂ ▃▄ ▅▆)"
}

@test "cava.sh: a stopped player gives a single empty line, not one per frame" {
    echo Stopped >"$XDG_RUNTIME_DIR/waybar-cava-player"

    run in_script "$CAVA" 'printf "%s\n" ▁▂ ▃▄ ▅▆ | gate_on_player'

    assert_success
    assert_equal "${#lines[@]}" 0
    assert_equal "$output" ""
    run in_script "$CAVA" 'printf "%s\n" ▁▂ ▃▄ ▅▆ | gate_on_player | wc -l'
    assert_output 1
}
