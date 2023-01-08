local awful = require("awful")
local beautiful = require("beautiful")
local spawn = require("awful.spawn")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")
local dpi = require('beautiful').xresources.apply_dpi


local main_color = beautiful.base09
local mute_color = beautiful.base0F

local image_size = 24

local icon =  wibox.widget {
    font = "FiraMono NerdFont 16",
    valign = "center",
    align = "center",
    forced_height = image_size,
    forced_width = image_size,
    widget = wibox.widget.textbox
}

local progressbar = wibox.widget {
    max_value     = 100,
    color		  = main_color,
    background_color = mute_color,
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 4)
    end,
    bar_shape = function(cr, width, height)
        gears.shape.partially_rounded_rect(cr, width, height, false, true, true, false, dpi(50))
    end,
    forced_height = 4,
    widget = wibox.widget.progressbar
}

local progressbar_container = wibox.widget {
    {
        icon,
        direction     = 'west',
        layout        = wibox.container.rotate,
    },
    {
        progressbar,
        top = 6,
        bottom = 6,
        widget = wibox.container.margin
    },
    spacing = 16,
    layout = wibox.layout.fixed.horizontal
}

awesome.connect_signal("evil::battery", function(battery)
    progressbar.value = battery.value
    icon.text = battery.image
end)

return progressbar_container