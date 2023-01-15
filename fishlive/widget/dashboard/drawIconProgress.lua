local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local dpi = require('beautiful').xresources.apply_dpi

local function drawIconProgress(signal, main_color, mute_color)
    local image_size = dpi(24)
    local prcts_width = dpi(35)

    local icon = wibox.widget {
        font = beautiful.icon_font.."17",
        valign = "center",
        align = "center",
        forced_height = image_size,
        forced_width = image_size,
        widget = wibox.widget.textbox
    }

    local prcts = wibox.widget {
        font = beautiful.font_board_med.."10",
        valign = "center",
        align = "center",
        forced_height = image_size,
        forced_width = prcts_width,
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
        prcts,
        {
            progressbar,
            top = 6,
            bottom = 6,
            widget = wibox.container.margin
        },
        spacing = 8,
        layout = wibox.layout.fixed.horizontal
    }

    awesome.connect_signal(signal, function(event)
        progressbar.value = event.value / 100
        icon.text = event.image
        prcts.text = event.value..'%'
    end)

    return progressbar_container, progressbar
end

return drawIconProgress