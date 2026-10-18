#!/usr/bin/env bash
# Dry-run aware command execution and module runner.

DRY_RUN="${DRY_RUN:-0}"

# --- Commands ---

# Every command that changes the system goes through `run`.
# The dry-run line goes to stderr, so `run sudo tee file >/dev/null <<<"$text"` still shows it.
# Feed input with a here-string, not a pipe: in a dry run nothing reads the pipe, and the
# writer can die of SIGPIPE under pipefail.
run() {
    if ((DRY_RUN)); then
        dry "$*" >&2
        return 0
    fi

    "$@"
}

# write_root_file <dest> [mode]: writes stdin to a root-owned file (default mode 644)
write_root_file() {
    local dest="$1"
    local mode="${2:-644}"
    local status=0
    local tmp

    tmp="$(mktemp)"
    cat >"$tmp"

    # Keep the status instead of letting set -e exit, so the temp file is always removed
    run sudo install -Dm"$mode" "$tmp" "$dest" || status=$?
    rm -f "$tmp"

    return "$status"
}

# --- Modules ---

# Each module runs in its own strict subshell; a failure stops only that module
# run_module <file> <index> <total>: runs one module and records its status and duration
run_module() {
    local file="$1"
    local index="$2"
    local total="$3"
    local status=ok
    local name started exit_code

    name="$(basename "$file" .sh)"
    name="${name#*-}"

    step "$name" "$index" "$total"
    started=$SECONDS

    # A plain statement, not `if ! ( … )`: bash ignores set -e in a subshell that is part
    # of a condition, so the module would run on past its first error
    (
        set -Eeuo pipefail
        # A module that returns non-zero on purpose already said why; skip the generic line
        trap 'if [[ "$BASH_COMMAND" != source* ]]; then err "$name: line $LINENO: $BASH_COMMAND"; fi' ERR
        # shellcheck source=/dev/null
        source "$file"
    )
    exit_code=$?

    if ((exit_code != 0)); then
        status=failed
    fi

    record_result "$name" "$status" "$((SECONDS - started))"
    [[ "$status" == ok ]]
}
