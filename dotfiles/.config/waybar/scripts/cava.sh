#!/usr/bin/env bash
# Streams the cava audio spectrum as a line of bar glyphs for the custom/cava module.
# Adapted from a community waybar script (original author unknown).

set -euo pipefail

readonly BARS="▁▂▃▄▅▆▇█"
readonly CONFIG_FILE="/tmp/bar_cava_config"

write_cava_config() {
    cat >"$CONFIG_FILE" <<EOF
[general]
framerate = 60
bars = 14

[input]
method = pulse
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
EOF
}

# sed script that turns cava's digits 0-7 into bar glyphs and drops the separators
build_sed_script() {
    local script="s/;//g" i
    for ((i = 0; i < ${#BARS}; i++)); do
        script+=";s/$i/${BARS:$i:1}/g"
    done
    # Silence is a row of the lowest bar: print an empty line so waybar hides the module
    script+=";s/^${BARS:0:1}*\$//"
    echo "$script"
}

main() {
    write_cava_config
    pkill -f "cava -p $CONFIG_FILE" || true
    cava -p "$CONFIG_FILE" | sed -u "$(build_sed_script)"
}

main "$@"
