local apps = {
    terminal = "wezterm",
    launcher = "sh /home/box/.config/rofi/launch.sh",
    switcher = nil,
    xrandr = "lxrandr",
    screenshot = "scrot -e 'echo $f'",
    volume = "pavucontrol",
    appearance = "lxappearance",
    browser = "firefox",
    fileexplorer = "dolphin",
    musicplayer = "pragha",
    settings = "code /home/box/awesome/"
}

user = {
    terminal = "wezterm",
    floating_terminal = "wezterm"
}

return apps
