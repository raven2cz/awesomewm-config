local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local apply_borders = require("fishlive.widget.borders")

local size = 45
local radius = 8

return function(fg, fg_hover, text, onclick)
    local textbox = wibox.widget {
        markup = "<span foreground='"..fg.."'>"..text.."</span>",
        font = beautiful.icon_font.."20",
        align = "center",
        valign = "center",
        forced_width = dpi(size),
        forced_height = dpi(size - (2 * radius)),
        widget = wibox.widget.textbox
    }

    local container = wibox.widget {
        textbox,
        bg = beautiful.bg_normal,
        widget = wibox.container.background
    }

    local old_cursor, old_wibox
    container:connect_signal("mouse::enter", function()
        textbox.markup = "<span foreground='"..fg_hover.."'>"..text.."</span>"
        textbox.font = beautiful.icon_font.."25"

        -- change cursor
        local wb = mouse.current_wibox
        old_cursor, old_wibox = wb.cursor, wb
        wb.cursor = "hand2"
    end)

    container:connect_signal("mouse::leave", function()
        textbox.markup = "<span foreground='"..fg.."'>"..text.."</span>"
        textbox.font = beautiful.icon_font.."20"

        -- reset cursor
        if old_wibox then
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end
    end)

    container:connect_signal("button::press", onclick)

    return apply_borders(container, size, size, radius)
end