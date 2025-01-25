#!/bin/bash

# Цвета в стиле Dracula
BLANK='#00000000'  # Прозрачный
CLEAR='#ffffff22'  # Полупрозрачный белый
DEFAULT='#bd93f9'  # Фиолетовый
TEXT='#f8f8f2'     # Белый текст
WRONG='#ff5555'    # Красный
VERIFYING='#50fa7b'# Зеленый
BACKGROUND='#282a36aa' # Фон с прозрачностью

# Создаем скриншот
TMPBG="/tmp/screen.png"
scrot "$TMPBG"

# Размываем изображение
convert "$TMPBG" -blur 0x8 "$TMPBG"

i3lock \
    -i "$TMPBG" \
    \
    --insidever-color=$BACKGROUND    `# Цвет внутри кольца при проверке` \
    --ringver-color=$VERIFYING       `# Цвет кольца при проверке` \
    \
    --insidewrong-color=$BACKGROUND  `# Цвет внутри кольца при ошибке` \
    --ringwrong-color=$WRONG         `# Цвет кольца при ошибке` \
    \
    --inside-color=$BACKGROUND       `# Цвет внутри кольца в обычном состоянии` \
    --ring-color=$DEFAULT            `# Цвет кольца в обычном состоянии` \
    --line-color=$BLANK              `# Цвет линии разделителя` \
    --separator-color=$DEFAULT        `# Цвет разделителя` \
    \
    --verif-color=$TEXT              `# Цвет текста верификации` \
    --wrong-color=$TEXT              `# Цвет текста ошибки` \
    --time-color=$TEXT               `# Цвет времени` \
    --date-color=$TEXT               `# Цвет даты` \
    --layout-color=$TEXT             `# Цвет индикатора раскладки` \
    --keyhl-color=$VERIFYING         `# Цвет подсветки клавиш` \
    --bshl-color=$WRONG              `# Цвет подсветки backspace` \
    \
    --screen 1                       `# Экран для блокировки` \
    --blur 5                         `# Уровень размытия` \
    --clock                          `# Показывать часы` \
    --indicator                      `# Показывать индикатор` \
    --time-str="%H:%M:%S"           `# Формат времени` \
    --date-str="%A, %d %B %Y"       `# Формат даты` \
    \
    --time-font="JetBrainsMono Nerd Font"    `# Шрифт времени` \
    --date-font="JetBrainsMono Nerd Font"    `# Шрифт даты` \
    --layout-font="JetBrainsMono Nerd Font"  `# Шрифт раскладки` \
    --verif-font="JetBrainsMono Nerd Font"   `# Шрифт верификации` \
    --wrong-font="JetBrainsMono Nerd Font"   `# Шрифт ошибки` \
    \
    --time-size=32                   `# Размер шрифта времени` \
    --date-size=16                   `# Размер шрифта даты` \
    --layout-size=16                 `# Размер шрифта раскладки` \
    --verif-size=24                  `# Размер шрифта верификации` \
    --wrong-size=24                  `# Размер шрифта ошибки` \
    \
    --radius 120                     `# Радиус кольца` \
    --ring-width 8                   `# Толщина кольца` \
    \
    --modif-size=10                  `# Размер индикатора модификаторов` \
    --time-align=0                   `# Выравнивание времени (0-центр)` \
    --date-align=0                   `# Выравнивание даты` \
    \
    --noinput-text=""               `# Текст при отсутствии ввода` \
    --verif-text="проверка..."      `# Текст верификации` \
    --wrong-text="неверно!"         `# Текст ошибки` \
    --lock-text="блокировка..."     `# Текст блокировки` \
    --lockfailed-text="ошибка!"     `# Текст ошибки блокировки` \
    \
    --pass-media-keys               `# Пропускать медиа клавиши` \
    --pass-screen-keys              `# Пропускать клавиши экрана` \
    --pass-volume-keys              `# Пропускать клавиши громкости` \
    \
    --ignore-empty-password         `# Игнорировать пустой пароль` \
    --force-clock                   `# Всегда показывать часы` \
    --refresh-rate=30               `# Частота обновления` \
    --redraw-thread                 `# Отдельный поток отрисовки`