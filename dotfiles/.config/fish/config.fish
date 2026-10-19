# Fish entry point. Everything else is autoloaded:
#   conf.d/     env, colors, abbreviations, prompt (sourced in name order)
#   functions/  one function per file, loaded on first use

if status is-interactive
    set -g fish_greeting # no welcome banner
end
