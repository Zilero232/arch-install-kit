#!/bin/bash
# Package lists and installation. yay resolves both repo and AUR packages.

PACKAGES_DIR="$KIT_DIR/packages"
YAY_FLAGS=(--needed --noconfirm --answerdiff None --answerclean None --removemake)

# One or more names per line, '#' starts a comment
read_pkgs() {
    sed 's/#.*//' "$1" | tr -s ' \t' '\n' | sed '/^$/d'
}

is_installed() {
    pacman -Qq "$1" &>/dev/null
}

# One transaction first; if a single package breaks it, retry one by one and record failures
pkg_install() {
    (($#)) || return 0
    run yay -S "${YAY_FLAGS[@]}" "$@" && return 0

    warn "Batch install failed, retrying one by one"
    local pkg
    for pkg in "$@"; do
        if ! run yay -S "${YAY_FLAGS[@]}" "$pkg"; then
            echo "$pkg" >>"$FAILED_FILE"
            warn "failed: $pkg"
        fi
    done
    return 0
}

pkg_install_list() {
    local file="$PACKAGES_DIR/$1.txt" pkgs
    [ -f "$file" ] || die "No package list: $file"

    mapfile -t pkgs < <(read_pkgs "$file")
    info "$1: ${#pkgs[@]} packages"
    pkg_install "${pkgs[@]}"
}

pkg_remove_conflicts() {
    local pkg found=()
    while read -r pkg; do
        if is_installed "$pkg"; then
            found+=("$pkg")
        fi
    done < <(read_pkgs "$PACKAGES_DIR/conflicts.txt")

    if ((${#found[@]})); then
        info "Removing conflicting: ${found[*]}"
        run sudo pacman -Rdd --noconfirm "${found[@]}"
    fi
    return 0
}
