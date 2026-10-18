# Gaming

The `gaming` group sets up Steam and everything around it. Install it with the rest, or later with `./install.sh --groups gaming --only packages,system`.

## What you get

| Tool                                                     | What it's for                                                        |
| -------------------------------------------------------- | -------------------------------------------------------------------- |
| Steam + Proton                                           | Steam games, Windows ones included                                   |
| [ProtonUp-Qt](https://davidotek.github.io/protonup-qt/)  | installs Proton-GE (fixes many games Valve's Proton doesn't)         |
| [Heroic](https://heroicgameslauncher.com/)               | Epic Games and GOG                                                   |
| [Lutris](https://lutris.net/)                            | everything else: Battle.net, EA, emulators, Windows installers       |
| Wine-staging, winetricks, protontricks                   | running and patching Windows games outside Steam                     |
| [GameMode](https://github.com/FeralInteractive/gamemode) | CPU governor, GPU clocks and priority boost while a game runs        |
| [MangoHud](https://github.com/flightlessmango/MangoHud)  | FPS, frame time, CPU/GPU load and temperatures over the game         |
| GOverlay                                                 | GUI for MangoHud settings                                            |
| gamescope                                                | Valve's micro-compositor: fixes resolution, scaling and frame pacing |
| game-devices-udev                                        | Xbox, PlayStation, Switch and 8BitDo controllers work without root   |

You are added to the `gamemode` group, and the GPU module installs the 32-bit Vulkan driver Steam needs.

## Steam launch options

Right-click a game → **Properties** → **Launch options**:

```text
mangohud gamemoderun %command%
```

If a game has the wrong resolution, scaling or stutters, run it through gamescope at the panel's native size:

```text
gamescope -W 2560 -H 1600 -f -- mangohud gamemoderun %command%
```

The MangoHud overlay toggles with `Right Shift + F12`; its look lives in `~/.config/MangoHud/MangoHud.conf`.

## What Hyprland does for games

- **Tearing for the lowest input lag:** Steam games (`steam_app_*`), gamescope and any window that declares game content get the `immediate` rule (`hypr/conf/windowrules.lua`), allowed by `allow_tearing`.
- **Direct scanout** for game windows (`render.direct_scanout = 2`), so a fullscreen game skips the compositor.
- **Adaptive sync (VRR)** for fullscreen windows (`misc.vrr = 2`).
- **No dimming or locking** while anything is fullscreen, games and videos alike.
- **Steam dialogs float:** the friends list, settings and properties windows open centered instead of taking a tile.
- **Sharp Steam UI** at fractional scaling: `STEAM_FORCE_DESKTOPUI_SCALING` follows the monitor scale (`hypr/conf/autostart.lua`).

## Proton-GE

Open **ProtonUp-Qt**, add the latest **GE-Proton** for Steam, restart Steam, then pick it per game: **Properties** → **Compatibility** → **Force the use of a specific Steam Play compatibility tool**.
