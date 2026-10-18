#!/usr/bin/env bats
# install.sh: help, flags and module selection. Selection runs against a copy of the kit
# with stub modules, so it needs neither Arch nor sudo.

load helpers

setup() {
    setup_sandbox
    make_fake_kit
}

# A copy of install.sh and lib/ next to stub modules that only say they ran
make_fake_kit() {
    local name

    FAKE_KIT="$BATS_TEST_TMPDIR/kit"
    mkdir -p "$FAKE_KIT/modules" "$FAKE_KIT/packages"
    cp "$REPO_DIR/install.sh" "$FAKE_KIT/"
    cp -r "$REPO_DIR/lib" "$FAKE_KIT/"
    echo "# nothing to bootstrap in tests" >"$FAKE_KIT/packages/bootstrap.txt"

    for name in 00-preflight 10-pacman 30-packages 80-dotfiles 90-services; do
        printf 'ok "%s ran"\n' "${name#*-}" >"$FAKE_KIT/modules/$name.sh"
    done
}

# --- Flags ---

@test "--help lists every module in run order" {
    local file names=()

    for file in "$REPO_DIR"/modules/*.sh; do
        file="$(basename "$file" .sh)"
        names+=("${file#*-}")
    done

    run "$REPO_DIR/install.sh" --help

    assert_success
    assert_output --partial "Usage: ./install.sh [options]"
    assert_line "Modules: ${names[*]}"
}

@test "--help prints usage without the banner" {
    run "$REPO_DIR/install.sh" --help

    assert_success
    refute_output --partial "Arch Install Kit"
    assert_line --index 0 "Usage: ./install.sh [options]"
}

@test "an unknown flag exits 1 with a hint" {
    run "$REPO_DIR/install.sh" --bogus

    assert_failure 1
    assert_output --partial "Unknown option: --bogus (see --help)"
}

# All argument tests run the fake kit with --dry-run: a parsing bug must never
# be able to start a real install on the developer's machine

@test "--only without a value fails" {
    run "$FAKE_KIT/install.sh" --dry-run --yes --only

    assert_failure
    assert_output --partial "--only needs a value"
    refute_output --partial "==> preflight"
}

@test "a list flag with only commas fails instead of meaning everything" {
    local flag

    for flag in --only --skip --groups; do
        run "$FAKE_KIT/install.sh" --dry-run --yes "$flag" ,

        assert_failure 1
        assert_output --partial "$flag needs at least one name"
        refute_output --partial "==> preflight"
    done
}

@test "a flag value can't swallow the next flag" {
    run "$FAKE_KIT/install.sh" --groups --dry-run

    assert_failure
    assert_output --partial "--groups needs a value"
}

@test "an unknown module name is rejected" {
    run "$FAKE_KIT/install.sh" --dry-run --yes --only dotfile

    assert_failure
    assert_output --partial "Unknown module: dotfile"
}

@test "an unknown group name is rejected" {
    run "$FAKE_KIT/install.sh" --dry-run --yes --groups bogus,dev

    assert_failure
    assert_output --partial "Unknown group: bogus"
}

# --- Module selection ---

@test "dry run without flags runs every module in order" {
    run "$FAKE_KIT/install.sh" --dry-run --yes

    assert_success
    assert_output --partial "Dry run: nothing will be changed"
    assert_line "==> preflight  1/5"
    assert_line "==> services  5/5"
    assert_line "  [ok] packages ran"
}

@test "--only runs just the listed modules" {
    run "$FAKE_KIT/install.sh" --dry-run --yes --only dotfiles,services

    assert_success
    assert_line "==> dotfiles  1/2"
    assert_line "==> services  2/2"
    refute_output --partial "preflight ran"
    refute_output --partial "packages ran"
}

@test "--skip drops the listed modules" {
    run "$FAKE_KIT/install.sh" --dry-run --yes --skip pacman,packages

    assert_success
    assert_line "==> preflight  1/3"
    assert_line "==> dotfiles  2/3"
    assert_line "==> services  3/3"
    refute_output --partial "pacman ran"
    refute_output --partial "packages ran"
}

@test "--only and --skip together: --skip removes from the --only list" {
    run "$FAKE_KIT/install.sh" --dry-run --yes --only pacman,dotfiles --skip pacman

    assert_success
    assert_line "==> dotfiles  1/1"
    refute_output --partial "pacman ran"
}

# --- Failures ---

@test "a failing module warns and the installer goes on" {
    echo 'false' >"$FAKE_KIT/modules/80-dotfiles.sh"

    run "$FAKE_KIT/install.sh" --dry-run --yes

    # Exit code 2: the run finished, but a module needs another try
    assert_failure 2
    assert_output --partial "Module 'dotfiles' failed, continuing"
    assert_line "  [ok] services ran"
    assert_output --regexp '\[x\] +dotfiles +[0-9]+s'
}

@test "a failing critical module stops the installer" {
    echo 'false' >"$FAKE_KIT/modules/10-pacman.sh"

    run "$FAKE_KIT/install.sh" --dry-run --yes

    assert_failure 1
    assert_output --partial "Module 'pacman' failed, cannot continue"
    refute_output --partial "packages ran"
}
