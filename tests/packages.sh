#!/usr/bin/env bash
# Checks that every package in packages/*.txt exists in the synced repos or in the AUR.
# Needs network and a synced pacman database (pacman -Sy); not part of `bun run test`.
# Usage: tests/packages.sh   (or: bun run test:packages)

set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly KIT_DIR
readonly AUR_RPC="https://aur.archlinux.org/rpc/v5/info"

# --- Helpers ---

require() {
    local cmd

    for cmd in "$@"; do
        if ! command -v "$cmd" >/dev/null; then
            echo "Error: $cmd is not installed" >&2
            exit 1
        fi
    done
}

# Every package name from every list, once
all_packages() {
    local file

    for file in "$KIT_DIR"/installer/packages/*.txt; do
        read_pkgs "$file"
    done | sort -u
}

# --- Lookups ---

# Names from the input that no synced repo has
not_in_repos() {
    comm -23 - <(pacman -Slq | sort -u)
}

# Names from the input that the AUR does not know either (one RPC request for all of them)
not_in_aur() {
    local name
    local names=()
    local args=()
    local found

    mapfile -t names
    if ((${#names[@]} == 0)); then
        return 0
    fi

    for name in "${names[@]}"; do
        args+=(--data-urlencode "arg[]=$name")
    done

    # Fetched first, so a failed request stops the script instead of listing everything
    found="$(curl -fsSG "${args[@]}" "$AUR_RPC" | jq -r '.results[].Name' | sort -u)"
    comm -23 <(printf '%s\n' "${names[@]}") <(printf '%s\n' "$found")
}

# --- Main ---

main() {
    local total
    local missing
    local pkg

    require pacman curl jq
    # shellcheck source=../lib/pkg.sh
    source "$KIT_DIR/installer/lib/pkg.sh"

    total="$(all_packages | wc -l)"
    missing="$(all_packages | not_in_repos | not_in_aur)"

    if [[ -n "$missing" ]]; then
        echo "Not in the repos or the AUR:" >&2
        while read -r pkg; do
            echo "  $pkg" >&2
        done <<<"$missing"
        exit 1
    fi

    echo "All $total packages exist (repos or AUR)"
}

main "$@"
