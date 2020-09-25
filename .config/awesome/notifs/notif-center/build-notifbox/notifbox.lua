local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

--local helpers = require("helpers")

local button = require("widgets.button")

local notifbox = {}

notifbox.create = function(icon, title, message, width)
    local time = os.date("%H:%M") 
    local box = {}

    local dismiss = button.create_image_onclick(beautiful.delete_grey_icon, beautiful.delete_icon, function() 
        _G.remove_notifbox(box)
    end)
    dismiss.forced_height = dpi(24)
    dismiss.forced_width = dpi(24)

    --icon.forced_height = dpi(24)
    --icon.forced_width = dpi(24)

    local img_icon = wibox.widget {
                image = icon, 
                forced_width = dpi(35), 
                forced_height = dpi(35),
                resize = true,
                clip_shape = function(cr)
            gears.shape.rounded_rect(cr, dpi(35), dpi(35), dpi(6))
        end, 
                widget = wibox.widget.imagebox
            }

    local center1 = wibox.container.margin(
        img_icon,
        20,0,14,0
    )

    box = wibox.widget {
        {
           center1, 
            {
                {
                    nil, 
                    {
                        {
                            font = "JetBrains Mono Bold 10", 
                            markup = title, 
                            widget = wibox.widget.textbox
                        }, 
                        {
                            font = "JetBrains Mono Regular 8", 
                            markup = message, 
                            widget = wibox.widget.textbox
                        },
                        layout = wibox.layout.fixed.vertical
                    }, 
                    expand = "none", 
                    layout = wibox.layout.align.vertical
                }, 
                left = dpi(20),
                bottom = dpi(0),
                widget = wibox.container.margin
            }, 
            {
                {
                    {
                        font = "JetBrains Mono Regular 8",
                        markup = time, 
                        widget = wibox.widget.textbox
                    }, 
                    {
                        nil, 
                        dismiss,
                        nil, 
                        expand = "none", 
                        layout = wibox.layout.align.horizontal
                    }, 
                    spacing = dpi(5), 
                    layout = wibox.layout.fixed.vertical
                }, 
                margins = dpi(10), 
                widget = wibox.container.margin
            }, 
            spacing = dpi(20), 
            layout = wibox.layout.align.horizontal
        }, 
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, dpi(6))
        end, 
        bg = beautiful.xcolor0, 
        forced_width = width,  
        widget = wibox.container.background 
    }

    return box
end

return notifbox
