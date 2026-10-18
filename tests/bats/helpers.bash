#!/usr/bin/env bash
# Shared setup for the bats tests: assertions, repo paths, a sandbox per test and PATH-based mocks.
# Load it first in every .bats file: load helpers

REPO_DIR="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
export KIT_DIR="$REPO_DIR"

bats_require_minimum_version 1.5.0

load "$REPO_DIR/node_modules/bats-support/load"
load "$REPO_DIR/node_modules/bats-assert/load"

# --- Sandbox ---

# Own HOME, runtime dir and mock bin dir (first in PATH) per test, so nothing touches the
# real home or calls the real hyprctl, pacman, yay... Call it from each file's setup().
setup_sandbox() {
    export HOME="$BATS_TEST_TMPDIR/home"
    export XDG_STATE_HOME="$HOME/.local/state"
    export XDG_RUNTIME_DIR="$BATS_TEST_TMPDIR/run"
    export MOCK_BIN="$BATS_TEST_TMPDIR/bin"
    export MOCK_LOG="$BATS_TEST_TMPDIR/calls.log"
    export INSTALLED_FILE="$BATS_TEST_TMPDIR/installed"
    export NO_COLOR=1
    # The session's UTF-8 locale, so bash counts the bar glyphs (cava.sh) as characters
    export LC_ALL=C.UTF-8
    export PATH="$MOCK_BIN:$PATH"

    mkdir -p "$HOME" "$XDG_RUNTIME_DIR" "$MOCK_BIN"
    : >"$MOCK_LOG"
    : >"$INSTALLED_FILE"
}

# --- Mocks ---

# mock_cmd <name> [body]: a fake command that logs "name args" to MOCK_LOG, then runs body
mock_cmd() {
    local name="$1"
    local body="${2:-exit 0}"

    cat >"$MOCK_BIN/$name" <<EOF
#!/usr/bin/env bash
printf '%s\n' "$name \$*" >>"\$MOCK_LOG"
$body
EOF
    chmod +x "$MOCK_BIN/$name"
}

# mock_pacman <pkg...>: `pacman -Qq <pkg>` (is_installed) succeeds only for these packages
mock_pacman() {
    printf '%s\n' "$@" >"$INSTALLED_FILE"
    mock_cmd pacman 'if [[ "$1" == -Qq ]]; then grep -qx -- "$2" "$INSTALLED_FILE"; fi'
}

# Calls recorded by the mocks, one per line
mock_calls() {
    cat "$MOCK_LOG"
}

# --- Running code under test ---

# kit <code>: runs bash code in a fresh shell with lib/ loaded the way install.sh loads it.
# A separate shell because lib/run.sh defines its own run(), which would shadow bats' run.
kit() {
    bash -c "for lib in \"\$KIT_DIR\"/lib/*.sh; do source \"\$lib\"; done; $1"
}

# in_script <file> <code>: sources a standalone script and runs code in a fresh shell.
# $0 must differ from the file, or the script's "executed, not sourced" guard runs main.
in_script() {
    bash -c "source \"\$1\"; $2" in_script "$1"
}
