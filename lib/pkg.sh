#!/usr/bin/env bash
# Package lists and installation. yay resolves both repo and AUR packages.

PACKAGES_DIR="$KIT_DIR/packages"
# SKIP_AUTOSNAP stops timeshift-autosnap from taking a snapshot before every batch the kit
# installs (yay runs pacman through sudo, which drops the environment unless told to keep it)
YAY_FLAGS=(
    --needed --noconfirm --answerdiff None --answerclean None --removemake
    --sudoflags "--preserve-env=SKIP_AUTOSNAP"
)

# --- Queries ---

# One or more names per line, '#' starts a comment
read_pkgs() {
    sed 's/#.*//' "$1" | tr -s ' \t' '\n' | sed '/^$/d'
}

is_installed() {
    pacman -Qq "$1" &>/dev/null
}

# --- Install ---

# One transaction first; if a single package breaks it, retry one by one
pkg_install() {
    local pkg

    if (($# == 0)); then
        return 0
    fi

    if ! run env SKIP_AUTOSNAP=1 yay -S "${YAY_FLAGS[@]}" "$@"; then
        warn "Batch install failed, retrying one by one"
        for pkg in "$@"; do
            run env SKIP_AUTOSNAP=1 yay -S "${YAY_FLAGS[@]}" "$pkg" || true
        done
    fi

    pkg_record_missing "$@"
}

# yay can exit 0 even when an AUR build fails (e.g. a blocked download),
# so ask pacman what actually got installed and record the rest
pkg_record_missing() {
    local pkg

    if ((DRY_RUN)); then
        return 0
    fi

    for pkg in "$@"; do
        if ! is_installed "$pkg"; then
            echo "$pkg" >>"$FAILED_FILE"
            warn "failed: $pkg"
        fi
    done

    return 0
}

# Installs one group: packages/<group>.txt
pkg_install_list() {
    local group="$1"
    local file="$PACKAGES_DIR/$group.txt"
    local pkgs=()

    if [[ ! -f "$file" ]]; then
        die "No package list: $file"
    fi

    mapfile -t pkgs < <(read_pkgs "$file")

    # --no-plymouth leaves the splash packages out too, not just their setup
    if ((!${WITH_PLYMOUTH:-1})); then
        mapfile -t pkgs < <(printf '%s\n' "${pkgs[@]}" | grep -v '^plymouth')
    fi

    info "$group: ${#pkgs[@]} packages"
    pkg_install "${pkgs[@]}"
}

# Installer prerequisites from packages/bootstrap.txt (all from the official repos)
pkg_bootstrap() {
    local pkg
    local missing=()

    while read -r pkg; do
        if ! is_installed "$pkg"; then
            missing+=("$pkg")
        fi
    done < <(read_pkgs "$PACKAGES_DIR/bootstrap.txt")

    if ((${#missing[@]} == 0)); then
        return 0
    fi

    # This runs before the "Start?" question, so say plainly that it upgrades the system.
    # -Syu, not -S: installing on a stale database would be a partial upgrade
    step "Installing installer dependencies: ${missing[*]}"
    info "Installing the installer's own dependencies (${missing[*]}); this updates the system first"
    if ! run sudo pacman -Syu --needed --noconfirm "${missing[@]}"; then
        die "Cannot install: ${missing[*]}"
    fi
}

# --- Remove ---

# True only for a package installed under exactly this name: `pacman -Qq waybar`
# also succeeds for waybar-git, which provides waybar, and that one must stay
is_installed_exactly() {
    local name

    if ! name="$(pacman -Qq "$1" 2>/dev/null)"; then
        return 1
    fi

    [[ "$name" == "$1" ]]
}

# Uninstalls whatever from packages/conflicts.txt is present
pkg_remove_conflicts() {
    local pkg
    local found=()

    while read -r pkg; do
        if is_installed_exactly "$pkg"; then
            found+=("$pkg")
        fi
    done < <(read_pkgs "$PACKAGES_DIR/conflicts.txt")

    if ((${#found[@]})); then
        info "Removing conflicting: ${found[*]}"
        run sudo pacman -Rdd --noconfirm "${found[@]}"
    fi

    return 0
}
