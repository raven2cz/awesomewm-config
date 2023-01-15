local awful = require("awful")
local beautiful = require("beautiful")
local drawIconProgress = require("fishlive.widget.dashboard.drawIconProgress")

local INC_BRIGHTNESS_CMD = 'brightnessctl set 2%+'
local DEC_BRIGHTNESS_CMD = 'brightnessctl set 2%-'

local signal = "signal::brightness"
local main_color = beautiful.base0B
local mute_color = beautiful.base01

return function(sig_brightness)
  local progressbar_container, progressbar = drawIconProgress(signal, main_color, mute_color)

  progressbar:connect_signal("button::press", function(_, _, _, button)
    if (button == 4) then awful.spawn(INC_BRIGHTNESS_CMD, false)
    elseif (button == 5) then awful.spawn(DEC_BRIGHTNESS_CMD, false)
    end
    sig_brightness:emit_signal("timeout")
  end)

  return progressbar_container
end
