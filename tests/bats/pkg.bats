#!/usr/bin/env bats
# lib/pkg.sh: reading package lists, installing with yay and recording what failed.

load helpers

setup() {
    setup_sandbox
}

# --- read_pkgs ---

@test "read_pkgs: skips comments and blank lines, splits several names per line" {
    local list="$BATS_TEST_TMPDIR/list.txt"

    cat >"$list" <<'EOF'
# A group comment
git base-devel	curl

  rsync   # inline comment
	# indented comment
stow
EOF

    run kit "read_pkgs '$list'"

    assert_success
    assert_output "$(printf '%s\n' git base-devel curl rsync stow)"
}

@test "read_pkgs: a list with only comments gives no output" {
    local list="$BATS_TEST_TMPDIR/list.txt"

    printf '# nothing here\n\n' >"$list"

    run kit "read_pkgs '$list'"

    assert_success
    assert_output ""
}

# --- pkg_record_missing ---

@test "pkg_record_missing: a dry run records nothing" {
    mock_pacman

    DRY_RUN=1 run kit 'mkdir -p "$STATE_DIR"; pkg_record_missing foo bar'

    assert_success
    assert_output ""
    assert_equal "$(mock_calls)" ""
    assert [ ! -e "$XDG_STATE_HOME/arch-install-kit/failed-packages" ]
}

@test "pkg_record_missing: records the packages pacman does not know" {
    mock_pacman foo

    run kit 'mkdir -p "$STATE_DIR"; pkg_record_missing foo bar baz 2>/dev/null; cat "$FAILED_FILE"'

    assert_success
    assert_output "$(printf '%s\n' bar baz)"
}

# --- pkg_install ---

@test "pkg_install: no packages, no yay call" {
    mock_cmd yay

    run kit 'pkg_install'

    assert_success
    assert_equal "$(mock_calls)" ""
}

@test "pkg_install: a failed batch is retried one package at a time" {
    local yay_s="yay -S --needed --noconfirm --answerdiff None --answerclean None --removemake --sudoflags --preserve-env=SKIP_AUTOSNAP"

    # The batch with both packages fails, like a transaction one bad package breaks
    mock_cmd yay 'if [[ "$*" == *" foo bar" ]]; then exit 1; fi'
    mock_pacman foo bar

    run kit 'mkdir -p "$STATE_DIR"; pkg_install foo bar'

    assert_success
    assert_output --partial "Batch install failed, retrying one by one"
    assert_equal "$(grep -c '^yay -S' "$MOCK_LOG")" 3
    assert_equal "$(sed -n 1p "$MOCK_LOG")" "$yay_s foo bar"
    assert_equal "$(sed -n 2p "$MOCK_LOG")" "$yay_s foo"
    assert_equal "$(sed -n 3p "$MOCK_LOG")" "$yay_s bar"
}

@test "pkg_install: a package that is still missing afterwards is recorded" {
    mock_cmd yay
    mock_pacman foo

    run kit 'mkdir -p "$STATE_DIR"; pkg_install foo bar 2>&1; cat "$FAILED_FILE"'

    assert_success
    assert_line "  [!] failed: bar"
    assert_line "bar"
    refute_line "foo"
    assert_equal "$(grep -c '^yay -S' "$MOCK_LOG")" 1
}

@test "pkg_install: yay runs with SKIP_AUTOSNAP kept through sudo" {
    mock_cmd yay 'echo "SKIP_AUTOSNAP=${SKIP_AUTOSNAP:-unset}" >>"$MOCK_LOG"'
    mock_pacman foo

    run kit 'mkdir -p "$STATE_DIR"; pkg_install foo'

    assert_success
    assert_equal "$(grep -c '^SKIP_AUTOSNAP=1$' "$MOCK_LOG")" 1
}

@test "pkg_install: a dry run prints the yay command and runs nothing" {
    mock_cmd yay

    DRY_RUN=1 run kit 'pkg_install foo bar'

    assert_success
    assert_output --partial "[dry] env SKIP_AUTOSNAP=1 yay -S --needed --noconfirm"
    assert_equal "$(mock_calls)" ""
}

@test "pkg_install_list: --no-plymouth leaves the splash packages out" {
    mock_cmd yay
    mkdir -p "$BATS_TEST_TMPDIR/lists"
    printf '# Test list\nsddm plymouth plymouth-theme-arch-logo\n' >"$BATS_TEST_TMPDIR/lists/login.txt"

    WITH_PLYMOUTH=0 run kit "PACKAGES_DIR='$BATS_TEST_TMPDIR/lists'; DRY_RUN=1; pkg_install_list login"

    assert_success
    assert_output --partial "login: 1 packages"
    refute_output --partial "plymouth"
}

# --- pkg_remove_conflicts ---

@test "pkg_remove_conflicts: removes a listed package, keeps a -git build that only provides its name" {
    # waybar-git provides waybar, so `pacman -Qq waybar` answers with the -git name
    mock_cmd pacman 'case "$2" in
    waybar) echo waybar-git ;;
    jack2) echo jack2 ;;
    *) exit 1 ;;
esac'
    mock_cmd sudo

    run kit 'pkg_remove_conflicts'

    assert_success
    run grep '^sudo ' "$MOCK_LOG"
    assert_output "sudo pacman -Rdd --noconfirm jack2"
}
