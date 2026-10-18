#!/usr/bin/env bats
# lib/hw.sh: GPU vendors from lspci, the bootloader and the installed kernels.

load helpers

# lspci -nn lines as they look on real machines
readonly INTEL_GPU='00:02.0 VGA compatible controller [0300]: Intel Corporation Alder Lake-P GT2 [Iris Xe Graphics] [8086:46a6] (rev 0c)'
readonly AMD_GPU='03:00.0 VGA compatible controller [0300]: Advanced Micro Devices, Inc. [AMD/ATI] Rembrandt [Radeon 680M] [1002:1681] (rev c8)'
readonly NVIDIA_GPU='01:00.0 3D controller [0302]: NVIDIA Corporation GA107M [GeForce RTX 3050 Mobile] [10de:25a2] (rev a1)'
readonly AUDIO='00:1f.3 Audio device [0403]: Intel Corporation Alder Lake PCH-P High Definition Audio Controller [8086:51c8] (rev 01)'

setup() {
    setup_sandbox
}

# mock_lspci <line...>: lspci prints these lines
mock_lspci() {
    printf '%s\n' "$@" >"$BATS_TEST_TMPDIR/lspci.out"
    mock_cmd lspci "cat '$BATS_TEST_TMPDIR/lspci.out'"
}

# --- GPU ---

@test "Intel only: Intel GPU, no AMD (\"ati\" in \"Corporation\" must not count), no NVIDIA" {
    mock_lspci "$INTEL_GPU" "$AUDIO"

    run kit 'has_intel_gpu'
    assert_success
    run kit 'has_amd_gpu'
    assert_failure
    run kit 'has_nvidia'
    assert_failure
}

@test "AMD only: AMD GPU, no Intel GPU (an Intel audio device is not a GPU)" {
    mock_lspci "$AMD_GPU" "$AUDIO"

    run kit 'has_amd_gpu'
    assert_success
    run kit 'has_intel_gpu'
    assert_failure
    run kit 'has_nvidia'
    assert_failure
}

@test "hybrid laptop: Intel and NVIDIA (3D controller) are both found" {
    mock_lspci "$INTEL_GPU" "$NVIDIA_GPU"

    run kit 'has_intel_gpu'
    assert_success
    run kit 'has_nvidia'
    assert_success
    run kit 'has_amd_gpu'
    assert_failure
}

@test "gpu_info: only display devices, empty without lspci output" {
    mock_lspci "$INTEL_GPU" "$AUDIO"

    run kit 'gpu_info'
    assert_success
    assert_output "$INTEL_GPU"

    mock_lspci ""
    run kit 'gpu_info'
    assert_success
    assert_output ""
}

# --- Boot ---

# The grub branch reads the real /etc/default/grub, so these tests make is_installed grub
# false and exercise the efibootmgr branch, which is the one that needs a mock
@test "bootloader: systemd-boot when efibootmgr lists Linux Boot Manager" {
    mock_pacman
    mock_cmd efibootmgr 'echo "Boot0001* Linux Boot Manager	HD(1,GPT,...)/File(\EFI\systemd\systemd-bootx64.efi)"'

    run kit 'bootloader'

    assert_success
    assert_output systemd-boot
}

@test "bootloader: unknown when neither grub nor systemd-boot is found" {
    mock_pacman
    mock_cmd efibootmgr 'echo "Boot0000* Windows Boot Manager"'

    run kit 'bootloader'

    assert_success
    assert_output unknown
}

@test "bootloader: grub when /etc/default/grub exists and grub is installed" {
    if [[ ! -f /etc/default/grub ]]; then
        skip "no /etc/default/grub on this machine"
    fi
    mock_pacman grub

    run kit 'bootloader'

    assert_success
    assert_output grub
}

@test "installed_kernels: unique package names from the pkgbase files" {
    local modules="$BATS_TEST_TMPDIR/modules"

    mkdir -p "$modules"/{6.17.1-arch1-1,6.12.50-1-lts,6.17.0-arch1-1}
    echo linux >"$modules/6.17.1-arch1-1/pkgbase"
    echo linux-lts >"$modules/6.12.50-1-lts/pkgbase"
    echo linux >"$modules/6.17.0-arch1-1/pkgbase"

    run kit "KERNEL_MODULES_DIR='$modules'; installed_kernels"

    assert_success
    assert_output "$(printf '%s\n' linux linux-lts)"
}

@test "installed_kernels: nothing installed gives no output" {
    run kit "KERNEL_MODULES_DIR='$BATS_TEST_TMPDIR/none'; installed_kernels"

    assert_success
    assert_output ""
}

# --- Location ---

# timezone_city reads tzdata's tables from /usr/share/zoneinfo; only timedatectl is mocked
require_tzdata() {
    if [[ ! -f /usr/share/zoneinfo/zone1970.tab ]] || [[ ! -f /usr/share/zoneinfo/iso3166.tab ]]; then
        skip "tzdata tables not installed"
    fi
}

@test "timezone_city: city and country from the system timezone" {
    require_tzdata
    mock_cmd timedatectl 'echo Europe/Moscow'

    run kit 'timezone_city'

    assert_success
    assert_output "Moscow,Russia"
}

@test "timezone_city: underscores in the zone become spaces" {
    require_tzdata
    mock_cmd timedatectl 'echo America/New_York'

    run kit 'timezone_city'

    assert_success
    assert_output "New York,United States"
}

@test "timezone_city: empty for a zone without a country (UTC) or without timedatectl" {
    require_tzdata
    mock_cmd timedatectl 'echo Etc/UTC'
    run kit 'timezone_city'
    assert_success
    assert_output ""

    mock_cmd timedatectl 'exit 1'
    run kit 'timezone_city'
    assert_success
    assert_output ""
}
