local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local apps = require("apps")

local drawBox = require("fishlive.widget.dashboard.drawBox")

local text = wibox.widget {
    text = "CONFIG",
    font = "Roboto Bold 12",
    widget = wibox.widget.textbox
}

local icon = wibox.widget {
    markup = "<span foreground='"..beautiful.fg_focus.."'>漣</span>",
    font = "Fira Mono 24",
    widget = wibox.widget.textbox
}

local widget = wibox.widget {
    icon,
    text,
    spacing = dpi(16),
    layout = wibox.layout.fixed.horizontal
}

local container = drawBox(widget, 168, 32)

container:connect_signal("button::press", function()
    awesome.emit_signal("dashboard::toggle")
    awful.spawn(apps.settings, false)
end)

local old_cursor, old_wibox
container:connect_signal("mouse::enter", function()
    -- container.set_background(beautiful.bg_dark)

    -- change cursor
    local wb = mouse.current_wibox
    old_cursor, old_wibox = wb.cursor, wb
    wb.cursor = "hand2"
end)

container:connect_signal("mouse::leave", function()
    -- container.set_background(beautiful.bg_normal)

     -- reset cursor
     if old_wibox then
        old_wibox.cursor = old_cursor
        old_wibox = nil
    end
end)

return container