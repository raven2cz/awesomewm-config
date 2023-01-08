local awful = require("awful")
local beautiful = require("beautiful")
local spawn = require("awful.spawn")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local gears = require("gears")
local dpi = require('beautiful').xresources.apply_dpi

local INC_VOLUME_CMD = 'amixer -D pulse sset Master 5%+'
local DEC_VOLUME_CMD = 'amixer -D pulse sset Master 5%-'
local TOG_VOLUME_CMD = 'amixer -D pulse sset Master toggle'

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
    value         = 1,
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
    icon,
    {
        progressbar,
        top = 6,
        bottom = 6,
        widget = wibox.container.margin
    },
    spacing = 16,
    layout = wibox.layout.fixed.horizontal
}

awesome.connect_signal("evil::volume", function(volume)
    progressbar.value = volume.value / 100;
    icon.text = volume.image
end)

progressbar:connect_signal("button::press", function(_, _, _, button)
    if (button == 4) then awful.spawn(INC_VOLUME_CMD, false)
    elseif (button == 5) then awful.spawn(DEC_VOLUME_CMD, false)
    elseif (button == 1) then awful.spawn(TOG_VOLUME_CMD, false)
    end
end)

return progressbar_container