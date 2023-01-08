local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local dpi = require('beautiful').xresources.apply_dpi

local INC_BRIGHTNESS_CMD = 'brightnessctl set 5%+'
local DEC_BRIGHTNESS_CMD = 'brightnessctl set 5%-'

local main_color = beautiful.base09
local mute_color = beautiful.base0F

local image_size = 24

local icon =  wibox.widget {
    font = "Fira Mono 24",
    valign = "center",
    align = "center",
    forced_height = image_size,
    forced_width = image_size,
    widget = wibox.widget.textbox
}

local progressbar = wibox.widget {
    value = 1,
    color		  = main_color,
    background_color = mute_color,
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 4)
    end,
    bar_shape = function(cr, width, height)
        gears.shape.partially_rounded_rect(cr, width, height, false, true, true, false, dpi(50))
    end,
    forced_height = dpi(4),
    widget        = wibox.widget.progressbar
}

local progressbar_container = wibox.widget {
    icon,
    {
        progressbar,
        top = 6,
        bottom = 6,
        forced_height = dpi(4),
        widget = wibox.container.margin
    },
    spacing = 16,
    layout = wibox.layout.fixed.horizontal
}

awesome.connect_signal("evil::brightness", function(brightness)
    progressbar.value = brightness.value / 100
    icon.text = brightness.image
end)

progressbar:connect_signal("button::press", function(_, _, _, button)
    if (button == 4) then awful.spawn(INC_BRIGHTNESS_CMD, false)
    elseif (button == 5) then awful.spawn(DEC_BRIGHTNESS_CMD, false)
    end
end)

return progressbar_container