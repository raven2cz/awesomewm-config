local wibox = require("wibox")
local beautiful = require("beautiful")

local hours = wibox.widget.textclock()
hours.font = beautiful.font_board_mono.."38"
hours.format = "%H"

local minutes = wibox.widget.textclock()
minutes.font = beautiful.font_board_mono.."38"
minutes.format = "<span foreground='"..beautiful.base0E.."'>%M</span>"

return wibox.widget {
    hours,
    minutes,
    spacing = 8,
    layout = wibox.layout.fixed.horizontal
}