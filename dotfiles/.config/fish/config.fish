# --- ОСНОВНЫЕ НАСТРОЙКИ ---
set -U fish_greeting          # Отключение приветствия
set -gx EDITOR micro          # Основной редактор
set -gx VISUAL micro          # Визуальный редактор
set -gx BROWSER firefox       # Браузер по умолчанию
set -gx TERM xterm-256color   # Поддержка 256 цветов

# --- УЛУЧШЕННЫЕ АЛИАСЫ ---
# Базовые
alias cls="clear"
alias g="git"
alias n="nvim"
alias m="micro"

# Улучшенный ls (если установлен exa)
if type -q exa
    alias ls="exa --icons --group-directories-first"
    alias ll="exa -l --icons --group-directories-first"
    alias la="exa -la --icons --group-directories-first"
    alias tree="exa --tree --icons"
else
    # Стандартный ls с цветами
    alias ls="ls --color=auto"
    alias ll="ls -l --color=auto"
    alias la="ls -la --color=auto"
end

# Системные логи и журналы
alias syslog_emerg="sudo dmesg --level=emerg,alert,crit"
alias syslog="sudo dmesg --level=err,warn"
alias xlog='grep "(EE)\|(WW)\|error\|failed" ~/.local/share/xorg/Xorg.0.log'
alias journal="journalctl -xef"  # Просмотр журнала в реальном времени

# Управление журналами
alias vacuum="journalctl --vacuum-size=100M"
alias vacuum_time="journalctl --vacuum-time=2weeks"

# Сетевые алиасы
alias myip="curl ifconfig.me"
alias ports="netstat -tulanp"

# --- ФУНКЦИИ ---

# Создание директории и переход в неё
function mkcd
    mkdir -p $argv[1] && cd $argv[1]
end

# Быстрый поиск файлов
function f
    find . -name "*$argv[1]*"
end

# Архивация файлов
function pack
    if test (count $argv) = 1
        tar -czf $argv[1].tar.gz $argv[1]
    else
        echo "Usage: pack <directory>"
    end
end

# --- ИНТЕГРАЦИЯ С FZF (если установлен) ---
if type -q fzf
    # Поиск файлов
    bind \cf 'fzf | read -l result; and cd (dirname $result)'
    # Поиск по истории
    bind \cr 'history | fzf | read -l result; and commandline -r $result'
end

# --- ПОДСВЕТКА СИНТАКСИСА ---
set fish_color_command green
set fish_color_param cyan
set fish_color_quote yellow
set fish_color_error red
set fish_color_comment brblack

# --- PROMPT CUSTOMIZATION ---

# Custom prompt
function fish_prompt
    set_color brblue
    echo -n (prompt_pwd)
    set_color yellow
    echo -n ' → '
    set_color normal
end

# --- PATH ДОБАВЛЕНИЯ ---

# Добавление путей
if test -d ~/.local/bin
    set -gx PATH ~/.local/bin $PATH
end

# --- ОПЦИОНАЛЬНЫЕ ИНТЕГРАЦИИ ---

# Starship (если установлен)
if type -q starship
    starship init fish | source
end

# Direnv (если установлен)
if type -q direnv
    direnv hook fish | source
end