#!/usr/bin/env bash
# Colored terminal output; the log file gets the same text without ANSI codes.

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/arch-install-kit"
LOG_FILE="$STATE_DIR/install-$(date +%F-%H%M%S).log"
FAILED_FILE="$STATE_DIR/failed-packages"

# From here on all output also goes to LOG_FILE, with colour codes stripped
setup_log() {
    mkdir -p "$STATE_DIR"
    : >"$FAILED_FILE"
    exec > >(tee >(sed -u 's/\x1b\[[0-9;]*m//g' >>"$LOG_FILE")) 2>&1
}

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
info() { printf '    %s\n' "$*"; }
ok()   { printf '\033[1;32m[ok]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
err()  { printf '\033[1;31m[x]\033[0m %s\n' "$*"; }
die()  { err "$*"; exit 1; }
