#! /bin/sh

# Запуск менеджера горячих клавиш (если не запущен)
pgrep -x sxhkd > /dev/null || sxhkd &

###################
# Базовые настройки
###################

# Настройка рабочих столов
# Основной монитор
bspc monitor primary -d 1 2 3 4 5 6 7
# Дополнительный монитор (раскомментируйте и настройте при необходимости)
# bspc monitor HDMI-1 -d 8 9 10

# Следование фокуса за курсором мыши
bspc config focus_follows_pointer true

########################
# Настройка внешнего вида
########################

# Цвета рамок окон
bspc config focused_border_color "#7899FA"  # Цвет рамки активного окна
bspc config normal_border_color "#1f222b"   # Цвет рамки неактивного окна
bspc config active_border_color "#bd93f9"   # Цвет рамки активного окна на неактивном мониторе
bspc config presel_feedback_color "#6272a4" # Цвет предварительного выбора

# Размеры и отступы
bspc config border_width 3                  # Уменьшенная ширина рамки для более современного вида
bspc config window_gap 12                   # Оптимальный размер отступов между окнами
bspc config borderless_monocle true         # Убрать рамки в режиме моно-окна
bspc config gapless_monocle false           # Сохранять отступы в режиме моно-окна

# Установка курсора мыши
xsetroot -cursor_name left_ptr

#########################
# Настройка управления окнами
#########################

# Настройка действий мыши (с клавишей Super/Win)
bspc config pointer_modifier mod4
bspc config pointer_action1 move           # Левая кнопка - перемещение
bspc config pointer_action2 resize_side    # Средняя кнопка - изменение размера (сторона)
bspc config pointer_action3 resize_corner  # Правая кнопка - изменение размера (угол)

######################
# Правила для приложений
######################

# Базовые правила
bspc rule -a feh state=floating
bspc rule -a Pavucontrol state=floating
bspc rule -a Galculator state=floating
bspc rule -a Firefox desktop='^2' follow=on

########################
# Автозапуск приложений
########################

# Загрузка ресурсов X
xrdb merge ~/.Xresources

# Запуск основных скриптов
~/.config/bspwm/scripts/launch.sh &
~/.config/polybar/scripts/launch.sh

# Запуск системных сервисов
dunst -config $HOME/.config/bspwm/dunst/dunstrc &                      # Уведомления
pkill battery-alert; ~/bin/battery_alert.sh &                          # Монитор батареи
pgrep -x redshift > /dev/null || redshift -l 55.7:37.6 -t 6500:3000 &  # Настройка цветовой температуры

# Запуск композитора
picom --config $HOME/.config/bspwm/picom_configurations/blur-shadow.conf &

# Автозапуск пользовательских приложений
flameshot &          # Скриншоты
nm-applet            # Менеджер сети