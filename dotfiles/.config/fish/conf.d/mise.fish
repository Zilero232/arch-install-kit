# mise: per-project tool versions (node, bun, python...) from mise.toml / .tool-versions

status is-interactive; or return
type -q mise; or return

mise activate fish | source
