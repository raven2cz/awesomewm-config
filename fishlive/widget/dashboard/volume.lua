local awful = require("awful")
local beautiful = require("beautiful")
local drawIconProgress = require("fishlive.widget.dashboard.drawIconProgress")

local INC_VOLUME_CMD = 'amixer -D pulse sset Master 2%+'
local DEC_VOLUME_CMD = 'amixer -D pulse sset Master 2%-'
local TOG_VOLUME_CMD = 'amixer -D pulse sset Master toggle'

local signal = "signal::volume"
local main_color = beautiful.base0D
local mute_color = beautiful.base01

return function(sig_volume)
  local progressbar_container, progressbar = drawIconProgress(signal, main_color, mute_color)

  progressbar:connect_signal("button::press", function(_, _, _, button)
    if (button == 4) then awful.spawn(INC_VOLUME_CMD, false)
    elseif (button == 5) then awful.spawn(DEC_VOLUME_CMD, false)
    elseif (button == 1) then awful.spawn(TOG_VOLUME_CMD, false)
    end
    sig_volume:emit_signal("timeout")
  end)

  return progressbar_container
end
