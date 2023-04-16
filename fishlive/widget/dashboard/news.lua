local wibox = require("wibox")
local beautiful = require("beautiful")
local markup = require("lain").util.markup
local dpi = require("beautiful.xresources").apply_dpi
local fishlive = require("fishlive")

local signal = "signal::news"

return function(sig_news)

  local maxheight = (fishlive.helpers.screen_res_y() - 650) / 2

  local news_textbox = wibox.widget({
    bg = beautiful.bg_normal,
    align = "left",
    valign = "center",
    widget = wibox.widget.textbox
  })
  local news_wibox = wibox.widget {
    news_textbox,
    layout = require("fishlive.widget.overflow").vertical,
    scrollbar_width = 2,
    spacing = 7,
    scroll_speed = 15,
  }
  news_wibox.forced_height = maxheight

  awesome.connect_signal(signal, function(event)
    news_textbox.markup = markup.fontfg(
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
