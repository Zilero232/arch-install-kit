#!/usr/bin/env bash
# CPU microcode and GPU drivers for whatever hardware is detected.

pkgs=()

case "$(cpu_vendor)" in
    GenuineIntel) pkgs+=(intel-ucode) ;;
    AuthenticAMD) pkgs+=(amd-ucode) ;;
esac

if has_intel_gpu; then
    pkgs+=(mesa lib32-mesa vulkan-intel lib32-vulkan-intel intel-media-driver)
fi
if has_amd_gpu; then
    pkgs+=(mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon)
fi
if has_nvidia; then
    pkgs+=(nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings egl-wayland libva-nvidia-driver)
    while read -r kernel; do
        pkgs+=("$kernel-headers")
    done < <(installed_kernels)
    warn "nvidia-open needs GTX 16xx / RTX 20xx or newer; older cards: nvidia-580xx-dkms (AUR)"
fi

if ((${#pkgs[@]})); then
    pkg_install "${pkgs[@]}"
fi

if has_nvidia; then
    # Drop-ins instead of editing mkinitcpio.conf and the kernel command line
    write_root_file /etc/mkinitcpio.conf.d/nvidia.conf <<<'MODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)'
    write_root_file /etc/modprobe.d/nvidia.conf <<<'options nvidia_drm modeset=1 fbdev=1'

    if ! grep -q LIBVA_DRIVER_NAME /etc/environment; then
        backup_once /etc/environment
        printf 'LIBVA_DRIVER_NAME=nvidia\n__GLX_VENDOR_LIBRARY_NAME=nvidia\n' \
            | run sudo tee -a /etc/environment >/dev/null
    fi
fi
ok "Drivers done"
