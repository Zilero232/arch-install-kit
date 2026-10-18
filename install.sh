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

# --- Helpers ---

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

Before the first question, missing installer tools (gum, jq, rsync, stow…) are installed
with sudo pacman -Syu, which updates the system first.

Modules: $(module_names | paste -sd ' ')
EOF
}

# modules/25-gpu.sh -> gpu
module_name() {
    local file="$1"
    local name

    name="$(basename "$file" .sh)"
    echo "${name#*-}"
}

# Module names without the NN- prefix, in run order
module_names() {
    local file

    for file in "$KIT_DIR"/modules/*.sh; do
        module_name "$file"
    done
}

# "a,b,,c" -> one item per line, empty items dropped
split_csv() {
    tr ',' '\n' <<<"$1" | sed '/^$/d'
}

# contains <needle> <items...>: succeeds when needle is one of the items
contains() {
    local needle="$1"
    local item

    shift
    for item in "$@"; do
        if [[ "$item" == "$needle" ]]; then
            return 0
        fi
    done

    return 1
}

# --- Arguments ---

# require_value <flag> <value>: a missing value must not swallow the next flag
# (`--groups --dry-run` would otherwise drop --dry-run and start a real install)
require_value() {
    local flag="$1"
    local value="${2:-}"

    if [[ -z "$value" ]] || [[ "$value" == -* ]]; then
        die "$flag needs a value (see --help)"
    fi
}

# require_items <flag> <count>: `--only ,` splits into nothing, which would mean "everything"
require_items() {
    local flag="$1"
    local count="$2"

    if ((count == 0)); then
        die "$flag needs at least one name (see --help)"
    fi
}

# require_known <what> <item> <known...>: rejects typos like `--only dotfile`
require_known() {
    local what="$1"
    local item="$2"

    shift 2
    if ! contains "$item" "$@"; then
        die "Unknown $what: $item (one of: $*)"
    fi
}

parse_args() {
    local extra=()
    local modules=()
    local item

    mapfile -t modules < <(module_names)

    while (($#)); do
        case "$1" in
            --minimal)
                PKG_GROUPS=("${CORE_GROUPS[@]}")
                GROUPS_FROM_FLAGS=1
                ;;
            --groups)
                require_value "$1" "${2:-}"
                mapfile -t extra < <(split_csv "$2")
                require_items "$1" "${#extra[@]}"
                for item in "${extra[@]}"; do
                    require_known group "$item" "${OPTIONAL_GROUPS[@]}"
                done
                PKG_GROUPS=("${CORE_GROUPS[@]}" "${extra[@]}")
                GROUPS_FROM_FLAGS=1
                shift
                ;;
            --only)
                require_value "$1" "${2:-}"
                mapfile -t ONLY < <(split_csv "$2")
                require_items "$1" "${#ONLY[@]}"
                for item in "${ONLY[@]}"; do
                    require_known module "$item" "${modules[@]}"
                done
                shift
                ;;
            --skip)
                require_value "$1" "${2:-}"
                mapfile -t SKIP < <(split_csv "$2")
                require_items "$1" "${#SKIP[@]}"
                for item in "${SKIP[@]}"; do
                    require_known module "$item" "${modules[@]}"
                done
                shift
                ;;
            --link)
                LINK_DOTFILES=1
                ;;
            --no-plymouth)
                WITH_PLYMOUTH=0
                ;;
            --dry-run)
                DRY_RUN=1
                ;;
            -y | --yes)
                ASSUME_YES=1
                ;;
            -h | --help)
                usage
                exit 0
                ;;
            *)
                die "Unknown option: $1 (see --help)"
                ;;
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

# --- Run ---

load_libs() {
    local lib

    for lib in "$KIT_DIR"/lib/*.sh; do
        # shellcheck source=/dev/null
        source "$lib"
    done
}

# Module files that pass --only/--skip, in run order
selected_modules() {
    local file

    for file in "$KIT_DIR"/modules/*.sh; do
        if should_run "$(module_name "$file")"; then
            echo "$file"
        fi
    done
}

# A critical module stops the installer; any other failure only warns
# Runs the selected modules; returns 2 when a non-critical module failed
run_modules() {
    local modules=()
    local index=0
    local failed=0
    local file name

    mapfile -t modules < <(selected_modules)

    for file in "${modules[@]}"; do
        index=$((index + 1))
        name="$(module_name "$file")"

        if run_module "$file" "$index" "${#modules[@]}"; then
            continue
        fi

        if contains "$name" "${CRITICAL_MODULES[@]}"; then
            print_summary
            die "Module '$name' failed, cannot continue. Log: $LOG_FILE"
        fi
        warn "Module '$name' failed, continuing. Re-run later: ./install.sh --only $name"
        failed=$((failed + 1))
    done

    if ((failed > 0)); then
        return 2
    fi
}

main() {
    load_libs
    # Arguments first: --help and argument errors print without the banner
    parse_args "$@"
    banner

    require_not_root
    if ((!DRY_RUN)); then
        sudo_keepalive
    fi
    pkg_bootstrap

    # Questions come before logging starts: gum needs the real terminal
    if is_interactive; then
        if ((!GROUPS_FROM_FLAGS)); then
            choose_groups
        fi
        confirm_plan
    fi

    setup_log
    if ((DRY_RUN)); then
        warn "Dry run: nothing will be changed"
    fi

    local status=0

    run_modules || status=$?
    print_summary

    # Non-zero when a module failed, so scripts and CI notice
    exit "$status"
}

main "$@"
