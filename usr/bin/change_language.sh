# Версия с тремя раскладками

#!/usr/bin/env bash

# Константы
NOTIFY_TIME=800
NOTIFY_ICON="input-keyboard"
LAYOUTS=("us" "ru" "ua")

# Получаем текущую раскладку
get_layout() {
    setxkbmap -query | grep layout | awk '{print $2}'
}

# Отправляем уведомление
send_notification() {
    local layout=$1
    local message="Keyboard: ${layout^^}"
    
    notify-send -i "$NOTIFY_ICON" "$message" -t "$NOTIFY_TIME" -h string:x-canonical-private-synchronous:keyboard
}

# Меняем раскладку
change_layout() {
    local current_layout=$(get_layout)
    local next_layout
    
    # Находим следующую раскладку
    for i in "${!LAYOUTS[@]}"; do
        if [ "${LAYOUTS[$i]}" = "$current_layout" ]; then
            next_index=$(( (i + 1) % ${#LAYOUTS[@]} ))
            next_layout=${LAYOUTS[$next_index]}

            break
        fi
    done
    
    # Если текущая раскладка не найдена, используем первую
    [ -z "$next_layout" ] && next_layout=${LAYOUTS[0]}
    
    setxkbmap "$next_layout" -option grp:caps_toggle
    send_notification "$next_layout"
}

# Основная функция
main() {
    change_layout
}

# Запуск скрипта
main