local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

local dpi = require("beautiful.xresources").apply_dpi

local weed = wibox.widget{
    markup = '<span foreground="'..beautiful.base0B..'">ﲤ</span>',
    font = "Fira Mono 48",
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

local avatar = wibox.widget {
    {
        image = beautiful.avatar,
        widget = wibox.widget.imagebox
    },
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, dpi(200))
    end,
    widget = wibox.container.background
}

local username = wibox.widget{
    markup = '<span foreground="'..beautiful.leading_fg..'">box</span>@<span foreground="'..beautiful.leading_fg..'">r5arch</span>',
    font = "Fira Mono 12",
    widget = wibox.widget.textbox
}

local uptime = wibox.widget {
    text = "up 0 minutes",
    font = "Roboto Regular 9",
    widget = wibox.widget.textbox
}

awful.widget.watch("uptime -p", 60, function(_, stdout)
    -- Remove trailing whitespaces
    local out = stdout:gsub('^%s*(.-)%s*$', '%1')--:gsub(", ", ",\n")
    uptime.text = out
end)

return wibox.widget {
    avatar,
    {
        nil,
        {
            username,
            uptime,
            spacing = dpi(2),
            layout = wibox.layout.fixed.vertical
        },
        nil,
        expand = "none",
        layout = wibox.layout.align.vertical
    },
    spacing = dpi(16),
    layout = wibox.layout.fixed.horizontal
}
