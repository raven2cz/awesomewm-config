local wibox = require("wibox")
local beautiful = require("beautiful")
local markup = require("lain").util.markup
local dpi = require("beautiful.xresources").apply_dpi

local signal = "signal::news"

return function(sig_news)
  local news_wibox = wibox.widget({
    bg = beautiful.bg_normal,
    align = "left",
    valign = "center",
    widget = wibox.widget.textbox
  })

  awesome.connect_signal(signal, function(event)
    news_wibox.markup = markup.fontfg(
        beautiful.operator_font..dpi(12),
        beautiful.base0E,
        event.value
    )
  end)

  news_wibox:connect_signal('button::press', function(_, _, _, button)
    if button == 1 then
        sig_news:emit_signal("timeout")
    end
  end)

  return news_wibox
end
