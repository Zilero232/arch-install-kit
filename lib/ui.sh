#!/usr/bin/env bash
# Interactive prompts via gum. Skipped with --yes or when there is no terminal.

# True when questions can be asked: no --yes, a real terminal and gum installed
is_interactive() {
    ((!ASSUME_YES)) && [[ -t 0 ]] && [[ -t 1 ]] && command -v gum &>/dev/null
}

# Core groups are always installed; the user ticks the optional ones (all ticked by default)
choose_groups() {
    local selected extra=()
    selected="$(gum choose --no-limit \
        --header "Optional package groups (space: toggle, enter: confirm)" \
        --selected "$(IFS=,; echo "${OPTIONAL_GROUPS[*]}")" \
        "${OPTIONAL_GROUPS[@]}")" || die "Cancelled"

    if [[ -n "$selected" ]]; then
        mapfile -t extra <<<"$selected"
    fi
    PKG_GROUPS=("${CORE_GROUPS[@]}" "${extra[@]}")
}

# Shows the plan in a box; anything but yes stops the installer
confirm_plan() {
    local dotfiles_mode="copy"
    ((LINK_DOTFILES)) && dotfiles_mode="symlinks (stow)"

    gum style --border rounded --padding "0 2" --margin "1 0" \
        "Arch Install Kit" \
        "" \
        "Package groups: ${PKG_GROUPS[*]}" \
        "Dotfiles:       $dotfiles_mode" \
        "Boot splash:    $( ((WITH_PLYMOUTH)) && echo yes || echo no)" \
        "Dry run:        $( ((DRY_RUN)) && echo yes || echo no)"

    gum confirm "Start?" || die "Cancelled"
}
