local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = require('beautiful').xresources.apply_dpi

local popupLib = {}

popupLib.create = function(x, y, height, width, widget)
    local widgetContainer = wibox.widget {
        {
            widget,
            margins = dpi(10),
            widget = wibox.container.margin
        },
        forced_height = height,
        forced_width = width,
        layout = wibox.layout.fixed.vertical
    }

    local popupWidget = awful.popup {
        widget = widgetContainer,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, beautiful.border_radius)
        end,
        visible = false,
        ontop = true,
        x = x,
        y = y
    }

    local mouseInPopup = false
    local timer = gears.timer {
        timeout   = 1.25,
        single_shot = true,
        callback  = function()
            if not mouseInPopup then
                popupWidget.visible = false
            end
        end
    }

    popupWidget:connect_signal("mouse::leave", function()
        if popupWidget.visible then
            mouseInPopup = false
            timer:again()
        end
    end)

    popupWidget:connect_signal("mouse::enter", function()
        mouseInPopup = true
    end)

    return popupWidget
end


local popupWidget = wibox.widget {
    require("notifs.notif-center"),
    expand = "none",
    layout = wibox.layout.fixed.horizontal
}

local width = 550
local margin = 10

local popup = popupLib.create(awful.screen.focused().geometry.width - width - margin, beautiful.wibar_height + 5,
    awful.screen.focused().geometry.height - beautiful.wibar_height - margin, width, popupWidget)

return popup
