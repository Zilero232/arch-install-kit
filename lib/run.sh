#!/bin/bash
# Dry-run aware command execution and module runner.

DRY_RUN="${DRY_RUN:-0}"

# Every command that changes the system goes through `run`
run() {
    if ((DRY_RUN)); then
        printf '\033[2m[dry] %s\033[0m\n' "$*"
        return 0
    fi
    "$@"
}

# Writes stdin to a root-owned file
write_root_file() {
    local dest="$1" mode="${2:-644}" tmp
    tmp="$(mktemp)"
    cat >"$tmp"
    run sudo install -Dm"$mode" "$tmp" "$dest"
    rm -f "$tmp"
}

# Each module runs in its own strict subshell; a failure stops only that module
run_module() {
    local file="$1" name
    name="$(basename "$file" .sh)"

    step "$name"
    (
        set -Eeuo pipefail
        trap 'err "$name: line $LINENO: $BASH_COMMAND"' ERR
        # shellcheck source=/dev/null
        source "$file"
    )
}
