local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi
local helpers = require("fishlive.helpers")

local function createGadgetPie(title, value, detailText, maxValue)
    -- solve type conversion problems
    if type(value) == "string" then
      value = helpers.all_trim(value)
    end
    value = tonumber(value) or 0
    local max_value = maxValue or 100
    local percent = math.floor(value / max_value * 100)
    return wibox.widget{
      {
          markup = "<span foreground='"..beautiful.fg_focus.."'>"..title.."</span>",
          font = beautiful.font_board_monob.."12",
          align = "center",
          widget = wibox.widget.textbox
      },
      {
        {
          min_value = 0,
          max_value = 100,
          value = percent,
          start_angle = 3 * math.pi / 2,
          bg = beautiful.base01,
          colors = { beautiful.bg_urgent },
          rounded_edge = true,
          thickness = 10,
          widget = wibox.container.arcchart
        },
        {
          markup = "<span foreground='"..beautiful.fg_normal.."'>"..percent.."%</span>",
          font = beautiful.font_board_bold.."8",
          align = "center",
          widget = wibox.widget.textbox
        },
        forced_width = dpi(54),
        forced_height = dpi(54),
        layout = wibox.layout.stack
      },
      {
        markup = "<span foreground='"..beautiful.fg_normal.."'>"..detailText.."</span>",
        align = "center",
        font = beautiful.font_board_med.."9",
        widget = wibox.widget.textbox
      },
      spacing = 8,
      layout = wibox.layout.fixed.vertical
    }
end

return createGadgetPie
