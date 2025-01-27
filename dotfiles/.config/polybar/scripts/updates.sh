#!/bin/bash

# Проверяем обновления pacman и AUR
updates_arch=$(checkupdates 2>/dev/null | wc -l)
updates_aur=$(yay -Qum 2>/dev/null | wc -l)

# Считаем общее количество
updates=$(($updates_arch + $updates_aur))

if [ "$updates" -gt 0 ]; then
    echo "$updates"
else
    echo "0"
fi