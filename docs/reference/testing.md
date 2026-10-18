# Testing

The tests live in `tests/` and run without Arch, sudo or a Hyprland session: commands that would touch the system are replaced by small fake scripts. Everything they need comes from `bun install`, plus `lua` for the layout switch test (`sudo pacman -S lua`).

## Run the tests

```bash
bun install               # once: bats, bats-assert, jsonc-parser, ajv…
bun run test              # offline suite, about 10 seconds
bun run test:packages     # every listed package exists (network, synced pacman db)
bun run test:all          # both
```

`bun run test` runs three layers one after another and stops at the first that fails. To run a single layer or file:

```bash
bun test tests/                          # config checks
bunx bats tests/bats/pkg.bats            # one bats file
bunx bats tests/bats -f 'quick_toggle'   # bats tests whose name matches
lua tests/lua/layout_switch_test.lua     # Lua layout switch
```

The pre-commit hook doesn't run the tests, so commits stay fast; run `bun run test` before you push. CI ([`test.yml`](https://github.com/Zilero232/arch-install-kit/blob/master/.github/workflows/test.yml)) runs the suite on Ubuntu, and again in an `archlinux` container with Hyprland and swaync installed, together with `./install.sh --dry-run --yes` and the package check.

## What each layer covers

| Layer          | Files                              | Covers                                                                                                                                                                                               |
| -------------- | ---------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Config checks  | `tests/configs.test.ts`            | Waybar modules, formats and commands; swaync schema, scripts and buttons; Hyprland `--verify-config` and `hl.dsp.` dispatches; TOML files; dotfiles; lists                                           |
| Polkit rule    | `tests/polkit.test.ts`             | the INCY rule against a stub of polkit's JavaScript API: allowed helper calls, path and argument checks, wheel + active local session                                                                |
| Bash (bats)    | `tests/bats/*.bats`                | `lib/` functions, `install.sh` flags and module selection, the `gpu`, `system`, `login`, `dotfiles` and `services` modules in dry run against fixtures, `wallpaper.sh`, `quick_toggle.sh`, `cava.sh` |
| Lua            | `tests/lua/layout_switch_test.lua` | Alt+Shift / Ctrl+Shift layout switch: taps, other keys in the chord, capitals, autorepeat, switching only after the last key is up                                                                   |
| Packages (net) | `tests/packages.sh`                | Every name in `packages/*.txt` is in the synced repos (`pacman -Slq`) or the AUR (one RPC v5 request)                                                                                                |

Some checks skip themselves when the tool they need is missing, and say so in the output: the swaync schema check needs `/etc/xdg/swaync/configSchema.json`, the Hyprland check needs `Hyprland`, the grub branch of `bootloader` needs `/etc/default/grub`, and `timezone_city` needs tzdata. In CI only, a Hyprland that cannot start at all is reported and skipped; on your machine it fails the test.

A module's `/etc` files that a test needs are globals with a default, overridable only through a `KIT_`-prefixed variable (`KIT_ENVIRONMENT_FILE`, `KIT_TIMESHIFT_CONFIG`, `KIT_UFW_CONFIG`, `KIT_REGDOM_FILE`, `KIT_BACKLIGHT_DIR`), so a test exports a fixture path and a stray variable in your shell can't redirect a write into `/etc`. What still reads fixed paths (`70-boot`, the GRUB branch of `60-login`) is covered by the dry run in CI, which runs every module on a real Arch system.

## Bats helpers and mocks

Every `.bats` file starts with `load helpers` and calls `setup_sandbox` from its `setup()`. [`tests/bats/helpers.bash`](https://github.com/Zilero232/arch-install-kit/blob/master/tests/bats/helpers.bash) gives each test:

- its own `HOME`, `XDG_STATE_HOME` and `XDG_RUNTIME_DIR` in a temp dir, so logs, state files and backups never touch your real home;
- a mock dir first in `PATH`, plus `NO_COLOR=1` so the installer prints plain ASCII.

| Helper                  | What it does                                                                                 |
| ----------------------- | -------------------------------------------------------------------------------------------- |
| `mock_cmd name 'body'`  | a fake `name` that appends `name args` to `$MOCK_LOG`, then runs `body` (default: `exit 0`)  |
| `mock_pacman pkg…`      | `pacman -Qq` (so `is_installed`) succeeds only for these packages                            |
| `mock_calls`            | the calls the mocks recorded, one per line                                                   |
| `kit 'code'`            | runs `code` in a fresh bash with every `lib/*.sh` loaded, the way `install.sh` loads them    |
| `in_script file 'code'` | sources a `dotfiles/bin` or `waybar/scripts` script without running `main`, then runs `code` |

`kit` uses a separate shell because `lib/run.sh` defines its own `run`, which would replace bats' `run`. Scripts in `dotfiles/bin/` and `waybar/scripts/` end with a source guard (`if [[ "${BASH_SOURCE[0]}" == "$0" ]]`), which is what lets `in_script` load their functions.

## Add a test

A bats test for a `lib/` function: mock what it calls, run it through `kit`, assert on the output and on the recorded calls.

```bash
@test "pkg_install: a dry run prints the yay command and runs nothing" {
    mock_cmd yay

    DRY_RUN=1 run kit 'pkg_install foo bar'

    assert_success
    assert_output --partial "[dry] yay -S --needed --noconfirm"
    assert_equal "$(mock_calls)" ""
}
```

- A new script in `dotfiles/bin/`: end it with the source guard and add tests to `tests/bats/scripts.bats`, running it whole (`run "$BIN/name.sh" args`) or one function at a time (`run in_script …`).
- A new command in a Waybar or swaync config: add it to `COMMAND_PACKAGES` in `tests/configs.test.ts` with the package that provides it.
- A new module: add a dry-run test to `tests/bats/modules.bats`; mock the commands it calls and turn each `/etc` path it checks into a global with a default (`FOO_CONFIG="${FOO_CONFIG:-/etc/foo.conf}"`) that the test points at a fixture.
- Assertions come from [bats-assert](https://github.com/bats-core/bats-assert#usage) (`assert_output`, `assert_line`, `refute_output`…) and [bun:test](https://bun.sh/docs/test/writing) (`expect`).

When a test fails, fix the code, not the test, unless the test itself is wrong.
