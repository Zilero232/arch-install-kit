#!/usr/bin/env bats
# lib/run.sh: dry-run aware commands, root files and the module runner.

load helpers

setup() {
    setup_sandbox
}

# write_module <name> <body>: a module file in the sandbox, returns its path on stdout
write_module() {
    local file="$BATS_TEST_TMPDIR/modules/$1.sh"

    mkdir -p "$(dirname "$file")"
    printf '%s\n' "$2" >"$file"
    echo "$file"
}

# --- run ---

@test "run: a dry run prints the command to stderr and does not execute it" {
    local marker="$BATS_TEST_TMPDIR/created"

    DRY_RUN=1 run kit "run touch '$marker' 2>&1 >/dev/null"

    assert_success
    assert_output "  [dry] touch $marker"
    assert [ ! -e "$marker" ]
}

@test "run: without a dry run the command runs and its status is kept" {
    local marker="$BATS_TEST_TMPDIR/created"

    run kit "run touch '$marker'"
    assert_success
    assert [ -e "$marker" ]

    run kit 'run false'
    assert_failure
}

# --- write_root_file ---

@test "write_root_file: a dry run shows the sudo install and leaves no temp file behind" {
    export TMPDIR="$BATS_TEST_TMPDIR/tmp"
    mkdir -p "$TMPDIR"
    mock_cmd sudo

    DRY_RUN=1 run kit 'echo hello | write_root_file /etc/kit-test.conf 600'

    assert_success
    assert_output --regexp '^  \[dry\] sudo install -Dm600 .+ /etc/kit-test.conf$'
    assert_equal "$(mock_calls)" ""
    assert_equal "$(ls -A "$TMPDIR")" ""
}

@test "write_root_file: passes stdin and the default mode 644 to sudo install" {
    local copy="$BATS_TEST_TMPDIR/written"

    # sudo copies the temp file it gets ("install -Dm644 <tmp> <dest>") so the test can read it
    mock_cmd sudo "cp \"\$3\" '$copy'"

    run kit 'echo hello | write_root_file /etc/kit-test.conf'

    assert_success
    assert_equal "$(cat "$copy")" hello
    assert_output ""
    run grep -c '^sudo install -Dm644 .* /etc/kit-test.conf$' "$MOCK_LOG"
    assert_output 1
}

# --- run_module ---

@test "run_module: a module that succeeds is recorded as ok with its duration" {
    local module

    module="$(write_module 10-hello "sleep 1; ok 'hello done'")"

    run kit "run_module '$module' 1 2; printf '%s\n' \"\${MODULE_RESULTS[@]}\""

    assert_success
    assert_line "==> hello  1/2"
    assert_line "  [ok] hello done"
    assert_line --regexp '^hello\|ok\|[12]$'
}

@test "run_module: a failing module stops at the error, returns non-zero and is recorded as failed" {
    local module

    module="$(write_module 20-broken "echo before; false; echo after")"

    run kit "run_module '$module' 2 2 2>&1; echo \"status=\$?\"; printf '%s\n' \"\${MODULE_RESULTS[@]}\""

    assert_success
    assert_line before
    refute_line after
    assert_line --partial "broken: line 1: false"
    assert_line "status=1"
    assert_line --regexp '^broken\|failed\|[0-9]+$'
}

@test "run_module: a module runs in a subshell, so its variables do not leak" {
    local module

    module="$(write_module 30-leak "LEAKED=yes")"

    run kit "run_module '$module' 1 1 >/dev/null; echo \"leaked=\${LEAKED:-no}\""

    assert_success
    assert_output "leaked=no"
}
