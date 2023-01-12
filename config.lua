local apps = {
    terminal = "wezterm",
    launcher = "rofi -show-icons -modi windowcd,window,drun -show drun -filter ",
    xrandr = "lxrandr",
    screenshot = "scrot -e 'echo $f'",
    volume = "pavucontrol",
    appearance = "lxappearance",
    browser = "firefox-developer-edition",
    fileexplorer = "dolphin",
    musicplayer = "pragha",
    settings = "code /home/box/.config/awesome/"
}

local user = {
    terminal = "wezterm",
    floating_terminal = "wezterm"
}

local config = {
    apps = apps,
    user = user,
    weather_coordinates = { 49.261749, 13.903450 },
    dashboard_monitor_storage = {"/", "/home", "/efi" },
}

return config