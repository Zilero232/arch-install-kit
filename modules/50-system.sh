#!/bin/bash
# Locale, user groups and small system defaults.

if ! grep -q '^ru_RU.UTF-8' /etc/locale.gen; then
    backup_once /etc/locale.gen
    run sudo sed -i 's/^#ru_RU.UTF-8/ru_RU.UTF-8/' /etc/locale.gen
    run sudo locale-gen
fi

for group in video input; do
    if ! id -nG "$USER" | grep -qw "$group"; then
        run sudo usermod -aG "$group" "$USER"
    fi
done
if is_installed docker && ! id -nG "$USER" | grep -qw docker; then
    run sudo usermod -aG docker "$USER"
fi
ok "System configured"
