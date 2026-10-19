-- The single place to swap apps; bindings.lua and autostart.lua use these.

return {
    terminal = "alacritty",
    file_manager = "thunar",
    menu = "rofi -show drun",
    browser = "google-chrome-stable", -- the main one; envs.lua exports it as $BROWSER
    browser_alt = "firefox",
    editor = "code",
    messenger = "Telegram",
    audio_mixer = "pavucontrol",
    scripts = "~/bin",
}
