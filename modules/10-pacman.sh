#!/usr/bin/env bash
# pacman.conf: multilib (Steam, lib32 drivers), colors, parallel downloads; makepkg drop-ins.

backup_once /etc/pacman.conf
run sudo sed -i '/^#\[multilib\]/,+1 s/^#//' /etc/pacman.conf
run sudo sed -i 's/^#Color/Color/; s/^#ParallelDownloads.*/ParallelDownloads = 5/' /etc/pacman.conf

write_root_file /etc/makepkg.conf.d/nodebug.conf <"$KIT_DIR/etc/makepkg.conf.d/nodebug.conf"
write_root_file /etc/makepkg.conf.d/jobs.conf <"$KIT_DIR/etc/makepkg.conf.d/jobs.conf"

run sudo pacman -Syu --noconfirm

ok "System updated"
