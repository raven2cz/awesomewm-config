local wibox = require("wibox")
local beautiful = require("beautiful")

local hours = wibox.widget.textclock()
hours.font = beautiful.font_board_mono.."38"
hours.format = "%H"

local minutes = wibox.widget.textclock()
minutes.font = beautiful.font_board_mono.."38"
minutes.format = "<span foreground='"..beautiful.base0E.."'>%M</span>"

local seconds = wibox.widget.textclock()
seconds.font = beautiful.font_board_mono.."38"
seconds.format = "<span foreground='"..beautiful.bg_urgent.."'>%S</span>"
seconds.visible = false

local w = wibox.widget {
    hours,
    minutes,
    seconds,
    spacing = 8,
    layout = wibox.layout.fixed.horizontal
}

w:connect_signal('button::press', function(_, _, _, button)
  if button == 1 then
    seconds.visible = not seconds.visible
    local refresh = 1
    if not seconds.visible then refresh = 60 end
    seconds:set_refresh(refresh)
  end
end)

return w