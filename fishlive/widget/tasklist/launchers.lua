local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")

local helpers = require("fishlive.helpers")

local favourites = require("fishlive.widget.tasklist.favourites")
local icons = require("fishlive.widget.tasklist.icons")
local get_app_widget = require("fishlive.widget.tasklist.app-widget")

local layout = wibox.layout.fixed.vertical()
local widgets = {}
layout.spacing = 8

local clientIsApp = function(c, app)
    -- returns if the client c is the same as the sidebarbox-app (e.g. firefox, kitty, ...)
    -- some fiddling needed, is kinda hacky
    if app == "intellij" and c.class == "jetbrains-idea" then
        -- hmm
        return true
    elseif c.class ~= nil then
        return string.lower(c.class) == string.lower(app)
    elseif c.instance ~= nil then
        return string.lower(c.instance) == string.lower(app)
    elseif c.name ~= nil then
        return string.lower(c.name) == string.lower(app)
    else
        return false
    end
end

for i, v in pairs(favourites) do
    layout:add(wibox.widget{
        widget = wibox.container.background
    })
end

for i, v in pairs(favourites) do
    local widget = wibox.widget {
        get_app_widget(false),
        widget = wibox.container.background
    }

    widget:get_children_by_id("custom_icon")[1].markup =
        "<span foreground='"..icons[v["name"]]["color"].."'>"..icons[v["name"]]["icon"].."</span>"

    widget:get_children_by_id("selected_indicator")[1].bg = beautiful.bg_normal

    widget.count = 0

    widget:connect_signal("button::release", function()
        awesome.emit_signal("dashboard::close")
        -- open client if at already exists
        -- spawn new client otherwise
        if widget.count > 0 then
            for _, tag in pairs(root.tags()) do
                for _, c in pairs(tag:clients()) do
                    if clientIsApp(c, v["class"]) then
                        c:jump_to(false)
                        return
                    end
                end
            end
        else
            awful.spawn(v["command"])
        end
    end)

    helpers.hover_pointer(widget)

    layout:remove(v["index"])
    layout:insert(v["index"], widget)

    widgets[i] = widget
end

client.connect_signal("manage", function(c)
    for i, v in pairs(favourites) do
        if clientIsApp(c, v["name"]) then
            local widget = widgets[i]
            widget.count = widget.count + 1

            widget:get_children_by_id("selected_indicator")[1].bg = beautiful.leading_fg

            if c.active then
                widget:get_children_by_id("selected_indicator")[1].bg = beautiful.fg_urgent
            end
        end
    end
end)

client.connect_signal("unmanage", function(c)
    for i, v in pairs(favourites) do
        if clientIsApp(c, v["name"]) then
            local widget = widgets[i]
            widget.count = widget.count - 1

            if widget.count == 0 then
                widget:get_children_by_id("selected_indicator")[1].bg = beautiful.bg_normal
            end
        end
    end
end)

client.connect_signal("focus", function(c)
    for i, v in pairs(favourites) do
        if clientIsApp(c, v["name"]) then
            local widget = widgets[i]
            widget:get_children_by_id("selected_indicator")[1].bg = beautiful.fg_urgent
        end
    end
end)

client.connect_signal("unfocus", function(c)
    for i, v in pairs(favourites) do
        if clientIsApp(c, v["name"]) then
            local widget = widgets[i]
            widget:get_children_by_id("selected_indicator")[1].bg = beautiful.leading_fg
        end
    end
end)

return layout