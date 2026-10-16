#!/usr/bin/env bash
# pacman.conf: multilib (Steam, lib32 drivers), colors, parallel downloads.

backup_once /etc/pacman.conf
run sudo sed -i '/^#\[multilib\]/,+1 s/^#//' /etc/pacman.conf
run sudo sed -i 's/^#Color/Color/; s/^#ParallelDownloads.*/ParallelDownloads = 5/' /etc/pacman.conf

run sudo pacman -Syu --noconfirm
ok "System updated"
