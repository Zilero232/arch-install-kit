Lock runs "loginctl lock-session", so hypridle starts hyprlock (lock_cmd) and never a second copy.

Pick the logout command in layout for your login setup:

Display manager, e.g. sddm (default)
hyprctl dispatch 'hl.dsp.exit()'

Text console login
loginctl terminate-user $USER
