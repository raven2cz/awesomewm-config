local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = require("beautiful.xresources").apply_dpi

local user = os.getenv("USER")
local hostname = io.popen("hostnamectl --static"):read("*a")

local avatar = wibox.widget {
    {
        {
            image = beautiful.avatar,
            widget = wibox.widget.imagebox
        },
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, dpi(200))
        end,
        widget = wibox.container.background
    },
    left = dpi(12),
    right = dpi(12),
    widget = wibox.container.margin
}

local username = wibox.widget{
    markup = '<span foreground="'..beautiful.leading_fg..'">'..user..'</span>@<span foreground="'..beautiful.leading_fg..'">'..hostname..'</span>',
    font = beautiful.font_board_mono.."14",
    forced_height = 20,
    align = "center",
    widget = wibox.widget.textbox
}

local uptime = wibox.widget {
    text = "up 0 minutes",
    font = beautiful.font_board_reg.."9",
    align = "center",
    widget = wibox.widget.textbox
}

awful.widget.watch("uptime -p", 60, function(_, stdout)
    -- Remove trailing whitespaces
    local out = stdout:gsub('^%s*(.-)%s*$', '%1')
    uptime.text = out
end)

local host_widget = wibox.widget {
    avatar,
    {
        username,
        uptime,
        spacing = dpi(4),
        layout = wibox.layout.fixed.vertical
    },
    spacing = dpi(16),
    layout = wibox.layout.fixed.vertical
}

host_widget:connect_signal('button::press', function(_, _, _, button)
  if button == 1 then
    awesome.emit_signal("dashboard::close")
  end
end)

return host_widget