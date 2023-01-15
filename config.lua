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

local terminal_cmds = {
    {
      cmd = 'journalctl -n 15 --no-pager -u "systemd-*"'
    },
    {
      cmd = 'journalctl -n 30 --no-pager'
    },
    {
      cmd = 'script -q /dev/null -c "journalctl -n 30 --no-pager" | tea -a'
    },
    {
      cmd = 'ls'
    },
    {
      cmd = 'sh chat-gpt "Describe cons and pros of awesomewm." 1.0',
      timeout = 100000
    },
    {
      cmd = 'sh chat-gpt "${input}" 1.0',
      timeout = 100000,
      prompt = 'Enter question for chat-gpt:'
    },
    {
      cmd = 'echo "${input}"',
      prompt = 'Enter text for echo:'
    }
}

local user = {
    terminal = "wezterm",
}

local config = {
    apps = apps,
    user = user,
    weather_coordinates = { 49.261749, 13.903450 },
    dashboard_monitor_storage = {"/", "/home/box/nfs/cloud", "/efi" },
    terminal_cmds = terminal_cmds,
}

return config