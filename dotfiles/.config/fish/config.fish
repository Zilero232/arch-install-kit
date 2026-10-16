# Fish entry point. Everything else is autoloaded:
#   conf.d/     env, colours, abbreviations, prompt (sourced in name order)
#   functions/  one function per file, loaded on first use
#   fish_plugins  fisher plugin list (`fisher update` installs it)

if status is-interactive
    set -g fish_greeting # no welcome banner
end
