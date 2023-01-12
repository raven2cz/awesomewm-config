local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi

local tasklist = require("fishlive.widget.tasklist.tasklist")

local width = 53
local openerWidth = 8

tasklist.forced_width = width

local dock_container = wibox({
    visible = true,
    ontop = true,
    type = "dock",
    screen = screen.primary,
    x = 0,
    y = beautiful.bar_height,
    width = dpi(width + openerWidth),
    height = dpi(awful.screen.focused().geometry.height - beautiful.bar_height),
    bg = "#00000000"
})

local dock_opener = wibox.widget {
    forced_width = dpi(openerWidth),
    input_passthrough = true,
    bg = "#00000000",
    widget = wibox.container.background
}

local mouse_in_dock = false

local function get_fullscreen()
    local tag = awful.screen.focused().selected_tag

    for _, client in pairs(tag:clients()) do
        if client.fullscreen then
            return true
        end
    end

    return false
end

local function get_auto_hide()
    if client.focus and client.focus.x < width then
        return true
    end

    return false
end

local function show_cb()
    if not mouse_in_dock and get_auto_hide() then return false end

    local delta = 2

    if dock_container.x < 0 then
        dock_container.x = dock_container.x + delta
        return true
    else
        return false
    end
end

local function hide_cb()
    if mouse_in_dock or not get_auto_hide() then return false end

    local delta = 2

    if dock_container.x > -width then
        dock_container.x = dock_container.x - delta
        return true
    else
        return false
    end
end

local function show()
    gears.timer.start_new(0.002, show_cb)
end

local function hide()
    gears.timer.start_new(0.002, hide_cb)
end

dock_opener:connect_signal("mouse::enter", function()
    if get_fullscreen() then return end

    mouse_in_dock = true
    show()
end)
dock_opener:connect_signal("mouse::leave", function()
    mouse_in_dock = false
    hide()
end)

tasklist:connect_signal("mouse::leave", function()
    mouse_in_dock = false
    hide()
end)

tasklist:connect_signal("mouse::enter", function()
    mouse_in_dock = true
    show()
end)

local update = function(tag)
    if tag == nil then
        tag = awful.screen.focused().selected_tag
    end

    if get_auto_hide() and not mouse_in_dock then
        hide()
    else
        show()
    end
end

client.connect_signal("focus", update)
client.connect_signal("manage", update)
client.connect_signal("unmanage", update)
client.connect_signal("property::size", update)
client.connect_signal("property::position", update)
client.connect_signal("tagged", update)
tag.connect_signal("property::layout", update)
tag.connect_signal("property::selected", update)

dock_container:setup {
    {
        input_passthrough = true,
        bg = "#0000000",
        widget = wibox.container.background
    },
    {
        tasklist,
        dock_opener,
        layout = wibox.layout.fixed.horizontal
    },
    {
        input_passthrough = true,
        bg = "#0000000",
        widget = wibox.container.background
    },
    expand = "none",
    layout = wibox.layout.align.vertical
}

update()