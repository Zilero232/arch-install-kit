# Keybindings

`Super` is the Windows key. Source: [`hypr/conf/bindings.lua`](https://github.com/Zilero232/arch-install-kit/blob/master/dotfiles/.config/hypr/conf/bindings.lua). Every bind has a description, so `hyprctl binds` lists them too.

## Apps

| Keys                       | Action                    |
| -------------------------- | ------------------------- |
| `Super + Enter`            | terminal (Alacritty)      |
| `Super + D`                | app launcher (Rofi)       |
| `Super + Shift + N`        | file manager (Thunar)     |
| `Super + Shift + H`        | Google Chrome (main)      |
| `Super + Shift + Ctrl + H` | Chrome, incognito         |
| `Super + Shift + F`        | Firefox                   |
| `Super + Shift + Ctrl + F` | Firefox, private window   |
| `Super + Shift + T`        | Telegram                  |
| `Super + Shift + C`        | VS Code                   |
| `Super + Shift + P`        | PhpStorm                  |
| `Super + Shift + V`        | VirtualBox                |
| `Super + Shift + K`        | calendar (calcurse)       |
| `Super + Shift + Z`        | audio mixer (pavucontrol) |

## Tools

| Keys                | Action                                                                 |
| ------------------- | ---------------------------------------------------------------------- |
| `PrtSc`             | region → annotate in satty (Enter copies and saves to `~/Screenshots`) |
| `Shift + PrtSc`     | whole screen → annotate in satty                                       |
| `Super + S`         | screenshot of the screen → clipboard                                   |
| `Super + Shift + S` | screenshot of a region → `~/Screenshots`                               |
| `Super + V`         | clipboard history                                                      |
| `Super + C`         | color picker → clipboard                                               |
| `Super + .`         | emoji picker                                                           |
| `Super + =`         | calculator                                                             |
| `Super + Shift + O` | copy text from a screen region (OCR, English and Russian), if any      |
| `Super + Shift + R` | start / stop recording a region → `~/Videos` (with a notification)     |
| `Super + W`         | random static wallpaper from `~/Images`                                |
| `Super + Ctrl + W`  | pick a wallpaper in waypaper                                           |
| `Super + Shift + W` | back to the live Wallpaper Engine scene                                |
| `Super + N`         | notification center                                                    |
| `Super + P`         | show / hide Waybar                                                     |
| `Super + O`         | show / hide Telegram and the audio mixer                               |

## Control center (Super + N)

The swaync control center has a row of quick buttons above the volume and brightness sliders ([`swaync/config.json`](https://github.com/Zilero232/arch-install-kit/blob/master/dotfiles/.config/swaync/config.json)):

| Button       | Action                                  |
| ------------ | --------------------------------------- |
| Wi-Fi        | network settings (nm-connection-editor) |
| Bluetooth    | Bluetooth manager (blueman)             |
| Night light  | toggle hyprsunset at 4500 K             |
| Microphone   | mute / unmute the microphone            |
| Mixer        | audio mixer (pavucontrol)               |
| Screenshot   | region → annotate in satty              |
| Color picker | pick a color → clipboard                |
| Wallpaper    | random static wallpaper from `~/Images` |
| Lock         | lock the screen                         |
| Power        | power menu (wlogout)                    |

## Session

| Keys                | Action        |
| ------------------- | ------------- |
| `Super + L`         | lock screen   |
| `Super + X`         | power menu    |
| `Super + Shift + Q` | exit Hyprland |

## Windows

| Keys                   | Action                 |
| ---------------------- | ---------------------- |
| `Super + Q`            | close window           |
| `Super + F`            | fullscreen             |
| `Super + T`            | toggle floating        |
| `Super + J`            | toggle split direction |
| `Super + ←↑→↓`         | move focus             |
| `Super + Shift + ←↑→↓` | resize window          |
| `Super + drag left`    | move window            |
| `Super + drag right`   | resize window          |

## Workspaces

| Keys                      | Action                        |
| ------------------------- | ----------------------------- |
| `Super + 1…0`             | go to workspace 1–10          |
| `Super + Shift + 1…0`     | move window to workspace 1–10 |
| 3-finger horizontal swipe | switch workspace (touchpad)   |

## Zoom

| Keys                          | Action     |
| ----------------------------- | ---------- |
| `Super + Shift + scroll up`   | zoom in    |
| `Super + Shift + scroll down` | zoom out   |
| `Super + Ctrl + Z`            | reset zoom |

## Media keys

| Keys                           | Action            |
| ------------------------------ | ----------------- |
| Volume up / down / mute        | output volume     |
| Mic mute                       | microphone        |
| Play / pause / next / previous | media player      |
| Brightness up / down           | screen brightness |

## Keyboard layout

| Keys                            | Action                |
| ------------------------------- | --------------------- |
| `Alt + Shift` or `Ctrl + Shift` | switch layout (us/ru) |

Like on Windows, the layout switches when you let go of the keys, and only if you pressed nothing else in between, so `Ctrl + Shift + T`, `Ctrl + Shift + ←` and `Alt + Shift + Tab` keep working ([`hypr/conf/layout_switch.lua`](https://github.com/Zilero232/arch-install-kit/blob/master/dotfiles/.config/hypr/conf/layout_switch.lua)). One exception: a mouse click in between (`Ctrl + Shift` + click to select a range) still switches the layout on release, because Hyprland's Lua API has no mouse-button event.
