#!/usr/bin/env bats
# Modules run through run_module in dry-run mode, with mocks deciding what is "installed".
# /etc files a module checks are globals (TIMESHIFT_CONFIG, ENVIRONMENT_FILE…) that tests
# point at fixtures; what is still a fixed path is exercised by the dry run of install.sh.

load helpers

setup() {
    setup_sandbox
    mock_pacman
    export DRY_RUN=1
    export LINK_DOTFILES=0
    # Fixtures instead of the real /etc/environment and /sys/class/backlight
    export KIT_ENVIRONMENT_FILE="$BATS_TEST_TMPDIR/environment"
    ENVIRONMENT_FILE="$BATS_TEST_TMPDIR/environment"
    export KIT_BACKLIGHT_DIR="$BATS_TEST_TMPDIR/backlight"
    BACKLIGHT_DIR="$BATS_TEST_TMPDIR/backlight"
}

# run_kit_module <file>: runs modules/<file> the way install.sh does, both streams captured
run_kit_module() {
    run kit "run_module \"\$KIT_DIR/installer/modules/$1\" 1 1 2>&1"
}

# --- 25-gpu ---

# mock_gpus <vendor-id...>: lspci lists one display controller per PCI vendor id
mock_gpus() {
    local body=""
    local id

    for id in "$@"; do
        body+="echo '00:02.0 VGA compatible controller [0300]: Some GPU [$id:1234]'"$'\n'
    done
    mock_cmd lspci "$body"
}

@test "gpu: NVIDIA libraries pulled in as a dependency go away on an AMD-only machine" {
    mock_gpus 1002
    # Both installed as dependencies (pacman -Qdq lists them)
    mock_cmd pacman 'case "$1" in -Qq | -Qdq) echo "$2" ;; *) exit 1 ;; esac'

    run_kit_module 25-gpu.sh

    assert_success
    assert_line "  [dry] sudo pacman -Rs --noconfirm nvidia-utils lib32-nvidia-utils"
}

@test "gpu: NVIDIA libraries stay on a machine with an NVIDIA card" {
    echo '# fixture' >"$ENVIRONMENT_FILE"
    mock_gpus 10de
    mock_cmd pacman 'case "$1" in -Qq | -Qdq) echo "$2" ;; *) exit 1 ;; esac'

    run_kit_module 25-gpu.sh

    assert_success
    refute_output --partial "pacman -Rs"
}

@test "gpu: NVIDIA as the only GPU gets the VA-API and GLX variables" {
    echo '# fixture' >"$ENVIRONMENT_FILE"
    mock_gpus 10de

    run_kit_module 25-gpu.sh

    assert_success
    assert_output --partial "nvidia-open-dkms"
    assert_line "  [dry] sudo tee -a $ENVIRONMENT_FILE"
}

@test "gpu: hybrid NVIDIA + AMD leaves the environment alone" {
    echo '# fixture' >"$ENVIRONMENT_FILE"
    mock_gpus 1002 10de

    run_kit_module 25-gpu.sh

    assert_success
    refute_output --partial "$ENVIRONMENT_FILE"
}

@test "gpu: hybrid NVIDIA + Intel leaves the environment alone" {
    echo '# fixture' >"$ENVIRONMENT_FILE"
    mock_gpus 8086 10de

    run_kit_module 25-gpu.sh

    assert_success
    assert_output --partial "nvidia-open-dkms"
    refute_output --partial "$ENVIRONMENT_FILE"
}

@test "gpu: variables already in the environment are not added twice" {
    echo 'LIBVA_DRIVER_NAME=nvidia' >"$ENVIRONMENT_FILE"
    mock_gpus 10de

    run_kit_module 25-gpu.sh

    assert_success
    refute_output --partial "tee -a"
}

# --- 50-system ---

# Root on uuid "root-uuid"; /home a separate partition ("home-uuid") with more free space
mock_partitions() {
    mock_cmd findmnt 'if [[ "${!#}" == /home ]]; then echo home-uuid; else echo root-uuid; fi'
    mock_cmd mountpoint 'exit 0'
    mock_cmd df 'echo Avail; if [[ "${!#}" == /home ]]; then echo 900000; else echo 100000; fi'
}

# Fixture paths for the /etc files 50-system checks
use_system_fixtures() {
    export KIT_TIMESHIFT_CONFIG="$BATS_TEST_TMPDIR/timeshift.json"
    TIMESHIFT_CONFIG="$BATS_TEST_TMPDIR/timeshift.json"
    export KIT_UFW_CONFIG="$BATS_TEST_TMPDIR/ufw.conf"
    UFW_CONFIG="$BATS_TEST_TMPDIR/ufw.conf"
    export KIT_REGDOM_FILE="$BATS_TEST_TMPDIR/wireless-regdom"
    REGDOM_FILE="$BATS_TEST_TMPDIR/wireless-regdom"
    echo 'ENABLED=yes' >"$UFW_CONFIG"
    : >"$REGDOM_FILE"
}

@test "system: without a Timeshift config one is written" {
    use_system_fixtures
    mock_pacman timeshift
    mock_partitions

    run_kit_module 50-system.sh

    assert_success
    assert_output --regexp "\[dry\] sudo install -Dm644 .+ $TIMESHIFT_CONFIG"
}

@test "system: a Timeshift config on root is moved to a roomier /home" {
    use_system_fixtures
    mock_pacman timeshift
    mock_partitions
    echo '{ "backup_device_uuid" : "root-uuid" }' >"$TIMESHIFT_CONFIG"

    run_kit_module 50-system.sh

    assert_success
    assert_line "  [dry] sudo cp -a $TIMESHIFT_CONFIG $TIMESHIFT_CONFIG.kit.bak"
    assert_output --regexp "\[dry\] sudo install -Dm644 .+ $TIMESHIFT_CONFIG"
}

@test "system: moving the Timeshift target keeps your schedule and excludes" {
    use_system_fixtures
    mock_pacman timeshift
    mock_partitions
    # A real write into the fixture: sudo runs only commands that touch the test's temp dir,
    # everything else (the real /etc) is just logged
    mock_cmd sudo 'if [[ "$*" == *"$(dirname "$MOCK_LOG")"* ]]; then "$@"; fi'
    printf '%s\n' '{ "backup_device_uuid" : "root-uuid", "schedule_daily" : "true", "exclude" : [ "/data/**" ] }' \
        >"$TIMESHIFT_CONFIG"

    DRY_RUN=0 run_kit_module 50-system.sh

    assert_success
    assert_equal "$(jq -r .backup_device_uuid "$TIMESHIFT_CONFIG")" "home-uuid"
    assert_equal "$(jq -r .schedule_daily "$TIMESHIFT_CONFIG")" "true"
    assert_equal "$(jq -r '.exclude[0]' "$TIMESHIFT_CONFIG")" "/data/**"
}

@test "system: a Timeshift config on another disk is left alone" {
    use_system_fixtures
    mock_pacman timeshift
    mock_partitions
    echo '{ "backup_device_uuid" : "usb-uuid" }' >"$TIMESHIFT_CONFIG"

    run_kit_module 50-system.sh

    assert_success
    refute_output --partial "$TIMESHIFT_CONFIG"
}

@test "system: ufw is switched on only when its config says ENABLED=no" {
    use_system_fixtures
    mock_pacman ufw

    run_kit_module 50-system.sh
    assert_success
    refute_output --partial "ENABLED=yes/"

    echo 'ENABLED=no' >"$UFW_CONFIG"
    run_kit_module 50-system.sh
    assert_success
    assert_line "  [dry] sudo sed -i s/^ENABLED=no/ENABLED=yes/ $UFW_CONFIG"
}

# --- 60-login ---

@test "login: the Plymouth theme is set only when the theme list has it" {
    export WITH_PLYMOUTH=1
    mock_pacman plymouth
    mock_cmd efibootmgr
    mock_cmd plymouth-set-default-theme 'if [[ "${1:-}" == -l ]]; then printf "bgrt\narch-logo\n"; else echo bgrt; fi'

    run_kit_module 60-login.sh

    assert_success
    assert_line "  [dry] sudo plymouth-set-default-theme arch-logo"

    mock_cmd plymouth-set-default-theme 'if [[ "${1:-}" == -l ]]; then echo arch-logo-new; else echo bgrt; fi'
    run_kit_module 60-login.sh

    assert_success
    assert_output --partial "Plymouth theme arch-logo not found"
    refute_output --partial "[dry] sudo plymouth-set-default-theme"
}

# --- 80-dotfiles ---

@test "dotfiles: copy mode rsyncs into HOME with a dated backup dir" {
    run_kit_module 80-dotfiles.sh

    assert_success
    assert_output --regexp "\[dry\] rsync -a --backup --backup-dir=$HOME/.config-backup/[0-9-]+ --exclude=/.config/swaync/config.json $REPO_DIR/dotfiles/ $HOME/"
    assert_line "  [ok] Dotfiles deployed"
    refute_output --partial "stow"
    refute_output --partial "hypr-legacy"
}

@test "dotfiles: old hyprlang files are moved to the backup, the kept .conf files are not" {
    mkdir -p "$HOME/.config/hypr/conf"
    touch "$HOME/.config/hypr/hyprland.conf" \
        "$HOME/.config/hypr/conf/bindings.conf" \
        "$HOME/.config/hypr/hypridle.conf"

    run_kit_module 80-dotfiles.sh

    assert_success
    assert_output --regexp "\[dry\] mv $HOME/.config/hypr/hyprland.conf .+/hypr-legacy/"
    assert_output --regexp "\[dry\] mv $HOME/.config/hypr/conf/bindings.conf .+/hypr-legacy/"
    refute_output --partial "hypridle.conf"
}

@test "dotfiles: link mode uses stow and moves real files out of the way first" {
    mkdir -p "$HOME/.config/waybar"

    # A backlight is present, yet link mode must not render swaync into the stow symlink
    mkdir -p "$BACKLIGHT_DIR/intel_backlight"
    echo raw >"$BACKLIGHT_DIR/intel_backlight/type"

    LINK_DOTFILES=1 run_kit_module 80-dotfiles.sh

    assert_success
    refute_output --partial "swaync"
    assert_output --regexp "\[dry\] mv $HOME/.config/waybar .+/.config/waybar"
    assert_line "  [dry] stow --restow -d $REPO_DIR -t $HOME dotfiles"
    refute_output --partial "rsync"
}

@test "dotfiles: papirus folders are recolored only when papirus-folders is installed" {
    mock_cmd papirus-folders 'echo "  blue"'

    run_kit_module 80-dotfiles.sh
    refute_output --partial "papirus-folders -C"

    mock_pacman papirus-folders
    run_kit_module 80-dotfiles.sh
    assert_line "  [dry] sudo papirus-folders -C violet --theme Papirus-Dark"
}

@test "dotfiles: Chrome becomes the default browser once, only when it is installed" {
    mock_cmd xdg-settings 'echo firefox.desktop'

    run_kit_module 80-dotfiles.sh
    refute_output --partial "xdg-settings set"

    mock_pacman google-chrome
    run_kit_module 80-dotfiles.sh
    assert_line "  [dry] xdg-settings set default-web-browser google-chrome.desktop"

    mock_cmd xdg-settings 'echo google-chrome.desktop'
    run_kit_module 80-dotfiles.sh
    refute_output --partial "xdg-settings set"
}

@test "dotfiles: papirus folders already violet are left alone" {
    mock_pacman papirus-folders
    mock_cmd papirus-folders 'printf "  blue\n> violet\n"'

    run_kit_module 80-dotfiles.sh

    assert_success
    refute_output --partial "papirus-folders -C"
}

@test "dotfiles: the swaync config gets this machine's backlight device" {
    # acpi_video0 sorts first but is the firmware fallback; the raw driver must win
    mkdir -p "$BACKLIGHT_DIR/acpi_video0" "$BACKLIGHT_DIR/intel_backlight"
    echo firmware >"$BACKLIGHT_DIR/acpi_video0/type"
    echo raw >"$BACKLIGHT_DIR/intel_backlight/type"

    run kit 'swaync_config_render | jq -r ".\"widget-config\".backlight.device"'
    assert_output "intel_backlight"

    rm -r "$BACKLIGHT_DIR/acpi_video0" "$BACKLIGHT_DIR/intel_backlight"
    run kit 'swaync_config_render | jq -r ".\"widget-config\".backlight.device"'
    assert_output "amdgpu_bl1"
}

@test "dotfiles: the swaync config is rewritten only when it differs" {
    local config="$HOME/.config/swaync/config.json"

    mkdir -p "$BACKLIGHT_DIR/intel_backlight" "$(dirname "$config")"
    echo raw >"$BACKLIGHT_DIR/intel_backlight/type"
    echo '{"old": true}' >"$config"

    # Changed: the old file goes to the backup, the rendered one takes its place
    run_kit_module 80-dotfiles.sh
    assert_success
    assert_output --regexp "\[dry\] mv $config $HOME/.config-backup/[0-9-]+/.config/swaync/config.json"
    assert_output --regexp "\[dry\] install -Dm644 .+ $config"

    # Same content: nothing to do, nothing backed up
    kit 'swaync_config_render' >"$config"
    run_kit_module 80-dotfiles.sh
    assert_success
    refute_output --partial "$config"
}

@test "dotfiles: update_home_file writes, then leaves an unchanged file alone" {
    run kit 'DRY_RUN=0; echo one | update_home_file .config/x/file'
    assert_success
    assert_equal "$(cat "$HOME/.config/x/file")" "one"

    run kit 'DRY_RUN=0; echo one | update_home_file .config/x/file; ls "$HOME/.config-backup" 2>&1'
    assert_output --partial "No such file"

    run kit 'DRY_RUN=0; echo two | update_home_file .config/x/file; cat "$BACKUP_DIR/.config/x/file"'
    assert_output "one"
    assert_equal "$(cat "$HOME/.config/x/file")" "two"
}

# --- 90-services ---

@test "services: only units whose package is installed are enabled" {
    mock_pacman networkmanager mpd
    # Nothing enabled yet; the rfkill check reads plain "enabled"
    mock_cmd systemctl 'if [[ "$*" == *--quiet* ]]; then exit 1; fi; echo enabled'

    run_kit_module 90-services.sh

    assert_success
    assert_line "  [dry] sudo systemctl enable NetworkManager.service"
    assert_line "  [dry] systemctl --user enable mpd.socket"
    refute_output --partial "bluetooth.service"
    refute_output --partial "unmask"
}

@test "services: a unit that is already enabled is skipped" {
    mock_pacman networkmanager bluez
    mock_cmd systemctl 'if [[ "$*" == "is-enabled --quiet bluetooth.service" ]]; then exit 1; fi; echo enabled'

    run_kit_module 90-services.sh

    assert_success
    assert_line "  [dry] sudo systemctl enable bluetooth.service"
    refute_output --partial "enable NetworkManager.service"
}

@test "services: a masked rfkill socket is unmasked" {
    mock_cmd systemctl 'echo masked'

    run_kit_module 90-services.sh

    assert_success
    assert_line "  [dry] sudo systemctl unmask systemd-rfkill.service systemd-rfkill.socket"
}

@test "services: one unit failing to enable doesn't stop the others, but fails the module" {
    mock_pacman networkmanager bluez sddm mpd
    # A real run (no dry run) against mocks: sudo just runs the command, systemctl fails for bluetooth
    mock_cmd sudo '"$@"'
    mock_cmd systemctl 'if [[ "$*" == *--quiet* || "$*" == "enable bluetooth.service" ]]; then exit 1; fi'

    DRY_RUN=0 run_kit_module 90-services.sh

    assert_failure
    assert_output --partial "Could not enable bluetooth.service"
    assert_output --partial "Some units could not be enabled"
    run mock_calls
    assert_line "systemctl enable NetworkManager.service"
    assert_line "systemctl enable sddm.service"
    assert_line "systemctl --user enable mpd.socket"
    assert_line "systemctl mask NetworkManager-wait-online.service"
}

# --- 55-printing ---

@test "printing: skipped without cups" {
    run_kit_module 55-printing.sh

    assert_success
    assert_output --partial "Printing skipped"
    refute_output --partial "[dry]"
}

@test "printing: mDNS goes into nsswitch once, before resolve, and ufw opens 5353/udp" {
    export KIT_NSSWITCH_FILE="$BATS_TEST_TMPDIR/nsswitch.conf"
    echo 'hosts: mymachines resolve [!UNAVAIL=return] files myhostname dns' >"$KIT_NSSWITCH_FILE"
    mock_pacman cups nss-mdns ufw

    run_kit_module 55-printing.sh

    assert_success
    assert_output --partial "sed -i /^hosts:/ s/resolve/mdns_minimal [NOTFOUND=return] resolve/ $KIT_NSSWITCH_FILE"
    assert_output --partial "[dry] sudo ufw allow 5353/udp comment mDNS: network printers and scanners"

    echo 'hosts: mymachines mdns_minimal [NOTFOUND=return] resolve files dns' >"$KIT_NSSWITCH_FILE"
    run_kit_module 55-printing.sh
    refute_output --partial "sed -i"
}
