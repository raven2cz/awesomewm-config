local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")

local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local box = require("fishlive.widget.dockbox")

local poweroff = box(beautiful.fg_normal, beautiful.fg_focus, "", function() awful.spawn("poweroff") end)
local reboot = box(beautiful.fg_normal, beautiful.fg_focus, "", function() awful.spawn("reboot") end)
local suspend = box(beautiful.fg_normal, beautiful.fg_focus, "", function() awful.spawn.with_shell("systemctl suspend") end)
local lock = box(beautiful.fg_normal, beautiful.fg_focus, "", function() awful.spawn("lock.sh") end)
local refresh = box(beautiful.fg_normal, beautiful.fg_focus, "", function() awesome.restart() end)
local logout = box(beautiful.fg_normal, beautiful.fg_focus, "", awesome.quit)

return wibox.widget {
    {
        nil,
        {
            nil,
            {
                poweroff,
                reboot,
                suspend,
                lock,
                refresh,
                logout,
                spacing = dpi(8),
                layout = wibox.layout.fixed.vertical
            },
            nil,
            expand = "none",
            layout = wibox.layout.align.horizontal
        },
        nil,
        expand = "none",
        layout = wibox.layout.align.vertical
    },
    forced_width = dpi(64),
    widget = wibox.container.background,
}