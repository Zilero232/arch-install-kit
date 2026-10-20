# Theming

Every app shares one [Kanagawa](https://github.com/rebelot/kanagawa.nvim) (wave) palette. This page shows where the colors live and how to change them, the GTK theme, wallpapers, the login and boot screens, and the night light.

## Palette and roles

The palette is `~/.config/theme/kanagawa.css` ([`dotfiles/.config/theme/kanagawa.css`](https://github.com/Zilero232/arch-install-kit/blob/master/dotfiles/.config/theme/kanagawa.css)). It defines the official color names (`sumiInk3`, `fujiWhite`, `oniViolet`, `sakuraPink`…) and, under them, a few roles the styles use for structure and state:

| Role                     | Color                                      | Used for                                                   |
| ------------------------ | ------------------------------------------ | ---------------------------------------------------------- |
| `bg`, `bg-dark`          | `sumiInk3`, `sumiInk0`                     | bar strips and cards, the center slab and control center   |
| `surface`, `surface-alt` | `sumiInk4`, `sumiInk5`                     | buttons, hovers, slider troughs, card borders              |
| `border`                 | `sumiInk6`                                 | strip borders, dividers, inactive modules                  |
| `text`, `text-muted`     | `fujiWhite`, `fujiGray`                    | text                                                       |
| `accent`, `accent-alt`   | `oniViolet`, `sakuraPink`                  | toggles and sliders; active workspace, player, unread      |
| `frame`                  | `waveAqua2`                                | the right edge of the right strip and the control center   |
| `highlight`              | `carpYellow`                               | brush strokes under the clock and the control-center title |
| `seal`                   | `autumnRed`                                | critical states, destructive hovers                        |
| `ok`, `warn`, `error`    | `autumnGreen`, `roninYellow`, `samuraiRed` | battery and urgency states                                 |

Waybar, SwayNC, wlogout and `gtk-3.0/gtk.css` load it with `@import url("../theme/kanagawa.css")`. Waybar and SwayNC split their CSS into `style/*.css` files that `style.css` imports in order: plain GTK CSS, no build step.

## Change an accent

1. In `~/.config/theme/kanagawa.css`, re-point the role to another palette name, for example `@define-color accent @crystalBlue;`.
2. Reload Waybar with `pkill -SIGUSR2 waybar` and restart SwayNC with `systemctl --user restart swaync`. wlogout and GTK apps pick the change up the next time they open.
3. Update the apps that can't import CSS. They carry copies of the hex values, so change them by hand:

| File in `~/.config/`                  | What carries the color                            |
| ------------------------------------- | ------------------------------------------------- |
| `rofi/colors.rasi`                    | the launcher and the pickers (`menu.rasi`)        |
| `alacritty/themes/kanagawa_wave.toml` | the terminal                                      |
| `hypr/theme.lua`                      | window borders (`active_border`)                  |
| `hypr/hyprlock.conf`                  | the lock screen                                   |
| `fish/conf.d/fzf.fish`                | fzf in the terminal                               |
| `waybar/modules.jsonc`                | the clock and the calendar tooltip (Pango markup) |
| `MangoHud/MangoHud.conf`              | the in-game overlay                               |
| `gowall/config.yml`                   | the full palette gowall recolors wallpapers to    |

To find every copy of a color, search for its hex value:

```bash
grep -rli '957fb8' ~/.config
```

## GTK, icons and cursor

| Part   | Theme                              |
| ------ | ---------------------------------- |
| GTK    | `Kanagawa-Purple-Dark`             |
| Icons  | `Papirus-Dark` with violet folders |
| Cursor | `Hackneyed-Dark-24px`              |
| Font   | Noto Sans 11                       |

Change them in `nwg-look` and press Apply: it rewrites `gtk-3.0/settings.ini`, `gtk-4.0` and `.gtkrc-2.0`. GTK apps on Wayland read gsettings, so `~/bin/gtk_theme.sh` copies `settings.ini` into gsettings at every login.

The `dotfiles` module colors the Papirus folders violet. To pick another color:

```bash
sudo papirus-folders -C blue --theme Papirus-Dark
```

## Wallpapers

The 373 bundled wallpapers (WebP, 1920×1080, about 88 MB) are copied to `~/Images` without overwriting anything there; add your own in any format hyprpaper reads (PNG, JPEG, WebP, JPEG XL). `~/bin/wallpaper.sh` switches between modes and remembers the last one:

| Keys                | Mode                                                                                     |
| ------------------- | ---------------------------------------------------------------------------------------- |
| `Super + W`         | `random`: a random static picture from `~/Images`                                        |
| `Super + Ctrl + W`  | `pick`: choose a picture in [waypaper](https://github.com/anufrievroman/waypaper)        |
| `Super + Shift + W` | `live`: the Wallpaper Engine scene (see [after install](../install/05-after-install.md)) |

The next login starts the same mode. `Super + W` or `Super + Ctrl + W` switches it to a static picture; if the Workshop scene is missing at login, you see the picture and a notification, and live mode stays saved for the next login.

To make any picture match the palette, recolor it with [gowall](https://achno.github.io/gowall-docs/) and its `Kanagawa` theme from `gowall/config.yml`:

```bash
gowall convert ~/Images/42.webp -t Kanagawa
```

## Login and boot screens

SDDM uses the [Astronaut](https://github.com/Keyitdev/sddm-astronaut-theme) theme, and Plymouth shows the `arch-logo` splash. Switch them with these fish abbreviations:

```bash
sddm_theme_list                 # Astronaut variants, * marks the current one
sddm_theme_set pixel_sakura     # make it the login screen
plymouth_theme_list             # installed boot splashes
plymouth_theme_set arch-logo    # set one and rebuild the initramfs
```

A package update resets the SDDM variant; run `sddm_theme_set` again afterwards.

## Night light

hyprsunset turns the screen to a mild 4500 K at 20:00 and back to a neutral 6500 K at 07:00. Change the times in `~/.config/hypr/hyprsunset.conf`. The night light button in the control center (`Super + N`) toggles it at any time.
