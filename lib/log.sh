#!/usr/bin/env bash
# Terminal output in the Kanagawa palette; the log file gets the same text without ANSI codes.
# The Linux console (TTY), NO_COLOR and pipes get plain ASCII instead of colours and symbols.

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/arch-install-kit"
LOG_FILE="$STATE_DIR/install-$(date +%F-%H%M%S).log"
FAILED_FILE="$STATE_DIR/failed-packages"

# Module results for the closing summary, one "name|status|seconds" per module
MODULE_RESULTS=()

# --- Style ---

# True for a real terminal that can show truecolor and Unicode symbols
can_style() {
    if [[ ! -t 1 ]] || [[ -n "${NO_COLOR:-}" ]]; then
        return 1
    fi

    [[ "${TERM:-dumb}" != linux ]] && [[ "${TERM:-dumb}" != dumb ]]
}

# Decided once at load time, before setup_log turns stdout into a pipe
if can_style; then
    C_RESET=$'\e[0m'
    C_BOLD=$'\e[1m'
    C_DIM=$'\e[2m'
    C_VIOLET=$'\e[38;2;149;127;184m' # oniViolet
    C_BLUE=$'\e[38;2;126;156;216m'   # crystalBlue
    C_GREEN=$'\e[38;2;152;187;108m'  # springGreen
    C_YELLOW=$'\e[38;2;230;195;132m' # carpYellow
    C_RED=$'\e[38;2;232;36;36m'      # samuraiRed
    C_GREY=$'\e[38;2;114;113;105m'   # fujiGray

    ICON_STEP="◆"
    ICON_OK="✔"
    ICON_WARN="⚠"
    ICON_ERR="✖"
    ICON_INFO="›"
    ICON_DRY="◇"
    RULE_CHAR="─"
else
    C_RESET=""
    C_BOLD=""
    C_DIM=""
    C_VIOLET=""
    C_BLUE=""
    C_GREEN=""
    C_YELLOW=""
    C_RED=""
    C_GREY=""

    ICON_STEP="==>"
    ICON_OK="[ok]"
    ICON_WARN="[!]"
    ICON_ERR="[x]"
    ICON_INFO="-"
    ICON_DRY="[dry]"
    RULE_CHAR="-"
fi

# --- Log file ---

# From here on all output also goes to LOG_FILE, with colour codes stripped
setup_log() {
    mkdir -p "$STATE_DIR"

    # A dry run keeps the list from the last real run
    if ((!DRY_RUN)); then
        : >"$FAILED_FILE"
    fi

    exec > >(tee >(sed -u 's/\x1b\[[0-9;]*m//g' >>"$LOG_FILE")) 2>&1
}

# --- Messages ---

# A horizontal line of the given width (at most 60 characters)
rule() {
    local width="$1"
    local line

    if ((width > 60)); then
        width=60
    fi

    printf -v line '%*s' "$width" ''
    printf '%s' "${line// /$RULE_CHAR}"
}

banner() {
    local title="Arch Install Kit"
    local subtitle="Hyprland · Kanagawa"

    if [[ -z "$C_RESET" ]]; then
        printf '\n== %s (Hyprland, Kanagawa) ==\n' "$title"
        return 0
    fi

    printf '\n%s╭%s╮\n' "$C_VIOLET" "$(rule 34)"
    banner_line "$C_BOLD" "$title"
    banner_line "$C_GREY" "$subtitle"
    printf '╰%s╯%s\n' "$(rule 34)" "$C_RESET"
}

# One row of the banner box; pads by characters, not bytes, so "·" keeps the border straight
banner_line() {
    local colour="$1"
    local text="$2"
    local padding=$((30 - ${#text}))

    printf '│%s  %s%*s  %s│\n' "$C_RESET$colour" "$text" "$padding" '' "$C_RESET$C_VIOLET"
}

# step <name> [index] [total]
step() {
    local name="$1"
    local progress=""

    if [[ -n "${2:-}" ]]; then
        progress="  $C_GREY$2/$3$C_RESET"
    fi

    printf '\n%s%s %s%s%s%s\n' "$C_VIOLET" "$ICON_STEP" "$C_BOLD" "$name" "$C_RESET" "$progress"
}

info() {
    printf '  %s%s%s %s\n' "$C_GREY" "$ICON_INFO" "$C_RESET" "$*"
}

ok() {
    printf '  %s%s%s %s\n' "$C_GREEN" "$ICON_OK" "$C_RESET" "$*"
}

# A command that --dry-run skipped
dry() {
    printf '  %s%s %s%s\n' "$C_DIM" "$ICON_DRY" "$*" "$C_RESET"
}

# Warnings and errors go to stderr; setup_log sends both streams to the log
warn() {
    printf '  %s%s %s%s\n' "$C_YELLOW" "$ICON_WARN" "$*" "$C_RESET" >&2
}

err() {
    printf '  %s%s %s%s\n' "$C_RED" "$ICON_ERR" "$*" "$C_RESET" >&2
}

die() {
    err "$*"
    exit 1
}

# --- Summary ---

# record_result <module> <ok|failed> <seconds>
record_result() {
    MODULE_RESULTS+=("$1|$2|$3")
}

# One line per module: status, name, duration
print_result_line() {
    local name="$1"
    local status="$2"
    local seconds="$3"
    local icon="$ICON_OK"
    local colour="$C_GREEN"

    if [[ "$status" != ok ]]; then
        icon="$ICON_ERR"
        colour="$C_RED"
    fi

    # Pad to the width of the ok icon so names line up ("[x]" vs "[ok]" in plain mode)
    printf -v icon '%-*s' "${#ICON_OK}" "$icon"

    printf '  %s%s%s %-14s %s%4ss%s\n' "$colour" "$icon" "$C_RESET" "$name" "$C_GREY" "$seconds" "$C_RESET"
}

# Table of the modules that ran, then the total time
print_summary() {
    local entry name status seconds
    local total=0

    printf '\n%s%s Summary%s\n' "$C_BLUE" "$ICON_STEP" "$C_RESET"

    for entry in "${MODULE_RESULTS[@]}"; do
        IFS='|' read -r name status seconds <<<"$entry"
        total=$((total + seconds))
        print_result_line "$name" "$status" "$seconds"
    done

    printf '  %s%s%s\n' "$C_GREY" "$(rule 24)" "$C_RESET"
    printf '  %s%-16s %4ss%s\n' "$C_BOLD" "total" "$total" "$C_RESET"
}
