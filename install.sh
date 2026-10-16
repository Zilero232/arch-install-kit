#!/usr/bin/env bash
# Arch Install Kit: restores the Hyprland setup on a fresh Arch (archinstall, Minimal profile).
# Usage: ./install.sh [options]   (run as your user from the repo folder; see --help)

# No -e here: a failing module is handled below, each module runs strict in its own subshell
set -uo pipefail

KIT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
readonly KIT_DIR

readonly CORE_GROUPS=(base hyprland desktop audio fonts themes)
readonly OPTIONAL_GROUPS=(apps dev media office gaming)
readonly CRITICAL_MODULES=(preflight pacman aur-helper)

DRY_RUN=0
ASSUME_YES=0
GROUPS_FROM_FLAGS=0
WITH_PLYMOUTH=1
LINK_DOTFILES=0
ONLY=()
SKIP=()
PKG_GROUPS=("${CORE_GROUPS[@]}" "${OPTIONAL_GROUPS[@]}")

usage() {
    cat <<EOF
Usage: ./install.sh [options]

  --minimal           core groups only (${CORE_GROUPS[*]})
  --groups a,b        core groups + the listed optional ones (${OPTIONAL_GROUPS[*]})
                      without either flag you pick the optional groups interactively
  --only m1,m2        run only these modules (e.g. --only dotfiles,services)
  --skip m1,m2        skip these modules
  --link              symlink dotfiles to the repo instead of copying
  --no-plymouth       no boot splash
  --dry-run           print what would change, change nothing
  -y, --yes           no questions: all groups unless --minimal/--groups
  -h, --help          this help

Modules: $(module_names | paste -sd ' ')
EOF
}

# Module names without the NN- prefix, in run order
module_names() {
    local file name
    for file in "$KIT_DIR"/modules/*.sh; do
        name="$(basename "$file" .sh)"
        echo "${name#*-}"
    done
}

# "a,b,,c" -> one item per line, empty items dropped
split_csv() {
    tr ',' '\n' <<<"$1" | sed '/^$/d'
}

# contains <needle> <items...>: succeeds when needle is one of the items
contains() {
    local needle="$1" item
    shift
    for item in "$@"; do
        [[ "$item" == "$needle" ]] && return 0
    done
    return 1
}

parse_args() {
    local extra=()
    while (($#)); do
        case "$1" in
            --minimal)
                PKG_GROUPS=("${CORE_GROUPS[@]}")
                GROUPS_FROM_FLAGS=1
                ;;
            --groups)
                mapfile -t extra < <(split_csv "${2:?--groups needs a value}")
                PKG_GROUPS=("${CORE_GROUPS[@]}" "${extra[@]}")
                GROUPS_FROM_FLAGS=1
                shift
                ;;
            --only) mapfile -t ONLY < <(split_csv "${2:?--only needs a value}"); shift ;;
            --skip) mapfile -t SKIP < <(split_csv "${2:?--skip needs a value}"); shift ;;
            --link) LINK_DOTFILES=1 ;;
            --no-plymouth) WITH_PLYMOUTH=0 ;;
            --dry-run) DRY_RUN=1 ;;
            -y | --yes) ASSUME_YES=1 ;;
            -h | --help) usage; exit 0 ;;
            *) echo "Unknown option: $1 (see --help)"; exit 1 ;;
        esac
        shift
    done
}

# --only wins over everything; --skip removes from what is left
should_run() {
    local name="$1"
    if ((${#ONLY[@]})) && ! contains "$name" "${ONLY[@]}"; then
        return 1
    fi
    ! contains "$name" "${SKIP[@]}"
}

main() {
    for lib in "$KIT_DIR"/lib/*.sh; do
        # shellcheck source=/dev/null
        source "$lib"
    done

    parse_args "$@"
    require_not_root
    if ((!DRY_RUN)); then
        sudo_keepalive
    fi
    pkg_bootstrap

    # Questions come before logging starts: gum needs the real terminal
    if is_interactive; then
        ((GROUPS_FROM_FLAGS)) || choose_groups
        confirm_plan
    fi

    setup_log
    if ((DRY_RUN)); then
        warn "Dry run: nothing will be changed"
    fi

    local file name
    for file in "$KIT_DIR"/modules/*.sh; do
        name="$(basename "$file" .sh)"
        name="${name#*-}"
        should_run "$name" || continue

        if ! run_module "$file"; then
            if contains "$name" "${CRITICAL_MODULES[@]}"; then
                die "Module '$name' failed, cannot continue. Log: $LOG_FILE"
            fi
            warn "Module '$name' failed, continuing. Re-run later: ./install.sh --only $name"
        fi
    done
}

main "$@"
