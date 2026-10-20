#!/usr/bin/env bash
# Lists every Hyprland bind that has a description in a searchable rofi menu (Super+/).

set -euo pipefail

# hyprctl reports modifiers as a bit mask; these are the bits, in the order they are written
readonly MODIFIER_BITS=(64 4 8 1)
readonly MODIFIER_NAMES=(Super Ctrl Alt Shift)

# "Super + Shift" for a modmask of 65
modifier_names() {
    local mask="$1"
    local joined=""
    local i

    for i in "${!MODIFIER_BITS[@]}"; do
        if ((mask & MODIFIER_BITS[i])); then
            joined+="${joined:+ + }${MODIFIER_NAMES[i]}"
        fi
    done

    printf '%s' "$joined"
}

# One "keys<TAB>description" line per described bind, from `hyprctl binds -j` on stdin
format_binds() {
    local mask key description mods

    while IFS=$'\t' read -r mask key description; do
        mods="$(modifier_names "$mask")"

        if [[ -n "$mods" ]]; then
            printf '%s + %s\t%s\n' "$mods" "$key" "$description"
        else
            printf '%s\t%s\n' "$key" "$description"
        fi
    done < <(jq -r '.[] | select(.has_description) | [.modmask, .key, .description] | @tsv')
}

main() {
    local binds

    binds="$(hyprctl binds -j)"
    # Esc closes rofi with status 1; that is the normal way out, not an error
    format_binds <<<"$binds" | column -t -s $'\t' | rofi -dmenu -i -p Keys -theme menu >/dev/null || true
}

# Sourcing the file (tests) loads the functions without running main
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
