#!/usr/bin/env bash
# Interactive prompts via gum. Skipped with --yes or when there is no terminal.

# True when questions can be asked: no --yes, a real terminal and gum installed
is_interactive() {
    if ((ASSUME_YES)); then
        return 1
    fi

    [[ -t 0 ]] && [[ -t 1 ]] && command -v gum &>/dev/null
}

# "yes" or "no" for a 0/1 flag
yes_no() {
    if (($1)); then
        echo yes
    else
        echo no
    fi
}

# Core groups are always installed; the user ticks the optional ones (all ticked by default)
choose_groups() {
    local all_optional
    local selected
    local extra=()

    all_optional="$(IFS=,; echo "${OPTIONAL_GROUPS[*]}")"

    if ! selected="$(gum choose --no-limit \
        --header "Optional package groups (space: toggle, enter: confirm)" \
        --selected "$all_optional" \
        "${OPTIONAL_GROUPS[@]}")"; then
        die "Cancelled"
    fi

    if [[ -n "$selected" ]]; then
        mapfile -t extra <<<"$selected"
    fi

    PKG_GROUPS=("${CORE_GROUPS[@]}" "${extra[@]}")
}

# Shows the plan in a box; anything but yes stops the installer
confirm_plan() {
    local dotfiles_mode="copy"

    if ((LINK_DOTFILES)); then
        dotfiles_mode="symlinks (stow)"
    fi

    gum style --border rounded --padding "0 2" --margin "1 0" \
        "Arch Install Kit" \
        "" \
        "Package groups: ${PKG_GROUPS[*]}" \
        "Dotfiles:       $dotfiles_mode" \
        "Boot splash:    $(yes_no "$WITH_PLYMOUTH")" \
        "Dry run:        $(yes_no "$DRY_RUN")"

    if ! gum confirm "Start?"; then
        die "Cancelled"
    fi
}
