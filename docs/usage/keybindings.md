# Keybindings

`Super` is the Windows key. Source: [`hypr/conf/bindings.lua`](https://github.com/Zilero232/arch-install-kit/blob/master/dotfiles/.config/hypr/conf/bindings.lua). Every bind has a description, so `hyprctl binds` lists them too.

## Apps

| Keys                       | Action                    |
| -------------------------- | ------------------------- |
| `Super + Enter`            | terminal (Alacritty)      |
| `Super + D`                | app launcher (Rofi)       |
| `Super + Shift + N`        | file manager (Thunar)     |
| `Super + Shift + F`        | Firefox                   |
| `Super + Shift + H`        | Google Chrome             |
| `Super + Shift + Ctrl + F` | Firefox, private window   |
| `Super + Shift + Ctrl + H` | Chrome, incognito         |
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
| `Super + Shift + O` | copy text from a screen region (OCR, English and Russian)              |
| `Super + Shift + R` | start / stop recording a region → `~/Videos`                           |
| `Super + W`         | random static wallpaper from `~/Images`                                |
| `Super + Ctrl + W`  | pick a wallpaper in waypaper                                           |
| `Super + Shift + W` | back to the live Wallpaper Engine scene                                |
| `Super + N`         | notification centre                                                    |
| `Super + P`         | show / hide Waybar                                                     |
| `Super + O`         | show / hide Telegram and the audio mixer                               |

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

| Keys                  | Action                        |
| --------------------- | ----------------------------- |
| `Super + 1…0`         | go to workspace 1–10          |
| `Super + Shift + 1…0` | move window to workspace 1–10 |

## Zoom

| Keys                          | Action     |
| ----------------------------- | ---------- |
| `Super + Shift + scroll down` | zoom in    |
| `Super + Shift + scroll up`   | zoom out   |
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

Like on Windows, the layout switches when you let go of the keys, and only if you pressed nothing else in between, so `Ctrl + Shift + T`, `Ctrl + Shift + ←` and `Alt + Shift + Tab` keep working ([`hypr/conf/layout_switch.lua`](https://github.com/Zilero232/arch-install-kit/blob/master/dotfiles/.config/hypr/conf/layout_switch.lua)).
