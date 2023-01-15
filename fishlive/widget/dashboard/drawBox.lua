local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local apply_borders = require("fishlive.widget.borders")

local function drawBox(content, width, height)
    local margin = 8
    local padding = 8

    local container = wibox.container.background()
    container.bg = beautiful.bg_normal
    container.forced_width = dpi(width + margin + padding)
    container.forced_height = dpi(height + margin + padding)

    local box = wibox.widget {
            {
                {
                    nil,
                    {
                        nil,
                        content,
                        expand = "none",
                        layout = wibox.layout.align.vertical,
                    },
                    expand = "none",
                    layout = wibox.layout.align.horizontal,
                },
                margins = dpi(padding),
                widget = wibox.container.margin
            },
            widget = container
    }

    local bordered_box = apply_borders(box, dpi(width + 2*padding), dpi(height + 2*padding), 8)

    return wibox.widget {
        bordered_box,
        margins = dpi(margin),
        widget = wibox.container.margin
    }
end

return drawBox