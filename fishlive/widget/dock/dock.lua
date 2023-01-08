local wibox = require("wibox")
local beautiful = require("beautiful")

local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local apps = require("apps")
local box = require("fishlive.widget.dock.dockbox")

local browser = box(beautiful.yellow, beautiful.yellow_light, "", apps.browser)
local fileexplorer = box(beautiful.blue, beautiful.blue_light, "", apps.fileexplorer)
local terminal = box(beautiful.fg_normal, beautiful.fg_focus, "", apps.terminal)
local intellij = box(beautiful.red, beautiful.red_light, "", "intellij-idea-ultimate-edition")
local gimp = box(beautiful.cyan, beautiful.cyan_light, "", "gimp")
local spotify = box(beautiful.green, beautiful.green_light, "", "spotify")
local musicplayer = box(beautiful.cyan, beautiful.cyan_light, "", apps.musicplayer)

return wibox.widget {
    {
        nil,
        {
            nil,
            {
                browser,
                fileexplorer,
                terminal,
                intellij,
                --gimp,
                musicplayer,
                spotify,
                spacing = dpi(8),
                layout = wibox.layout.fixed.vertical
            },
            nil,
            expand = "none",
            layout = wibox.layout.align.vertical
        },
        nil,
        expand = "none",
        layout = wibox.layout.align.horizontal
    },
    widget = wibox.container.background,
}