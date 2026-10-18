#!/usr/bin/env bash
# CPU microcode and GPU drivers for whatever hardware is detected.

ENVIRONMENT_FILE="${KIT_ENVIRONMENT_FILE:-/etc/environment}" # KIT_*: tests point it at a fixture

pkgs=()

case "$(cpu_vendor)" in
    GenuineIntel)
        pkgs+=(intel-ucode)
        ;;
    AuthenticAMD)
        pkgs+=(amd-ucode)
        ;;
esac

if has_intel_gpu; then
    pkgs+=(mesa lib32-mesa vulkan-intel lib32-vulkan-intel intel-media-driver)
fi

if has_amd_gpu; then
    pkgs+=(mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon)
fi

if has_nvidia; then
    pkgs+=(nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings)
    pkgs+=(egl-wayland libva-nvidia-driver)
    while read -r kernel; do
        pkgs+=("$kernel-headers")
    done < <(installed_kernels)
    warn "nvidia-open needs GTX 16xx / RTX 20xx or newer; older cards: nvidia-580xx-dkms (AUR)"
fi

if ((${#pkgs[@]})); then
    pkg_install "${pkgs[@]}"
fi

# Drop-ins instead of editing mkinitcpio.conf and the kernel command line
if has_nvidia; then
    write_root_file /etc/mkinitcpio.conf.d/nvidia.conf \
        <<<'MODULES+=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)'
    write_root_file /etc/modprobe.d/nvidia.conf \
        <<<'options nvidia_drm modeset=1 fbdev=1'

    # Only when NVIDIA is the only GPU: on hybrid laptops Hyprland runs on the iGPU,
    # and these would send video decoding and GLX to the dGPU for every program
    if ! has_intel_gpu && ! has_amd_gpu && ! grep -q LIBVA_DRIVER_NAME "$ENVIRONMENT_FILE"; then
        backup_once "$ENVIRONMENT_FILE"
        # A here-doc, not `printf | run …`: a dry run doesn't read the pipe (SIGPIPE)
        run sudo tee -a "$ENVIRONMENT_FILE" >/dev/null <<'EOF'
LIBVA_DRIVER_NAME=nvidia
__GLX_VENDOR_LIBRARY_NAME=nvidia
EOF
    fi
fi

ok "Drivers done"
