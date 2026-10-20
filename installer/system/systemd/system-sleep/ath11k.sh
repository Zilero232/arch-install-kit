#!/bin/sh
# Unloads the Qualcomm QCNFA765 Wi-Fi driver around suspend: ath11k_pci hangs s2idle resume
# on some laptops (the screen stays black, nothing responds). https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Hooks_in_/usr/lib/systemd/system-sleep
# systemd-sleep calls this with $1 = pre | post.

case "$1" in
    pre)
        modprobe -r ath11k_pci
        ;;
    post)
        modprobe ath11k_pci
        ;;
esac
