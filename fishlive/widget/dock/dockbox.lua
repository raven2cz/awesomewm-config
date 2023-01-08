local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")

local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local dockbox = require("fishlive.widget.dockbox")

local countIndicator = function()
    return wibox.widget {
        bg = beautiful.fg_normal,
        shape = function(cr, width, height)
            gears.shape.partially_rounded_rect(cr, width, height, false, true, true, false, dpi(50))
        end,
        forced_height = dpi(6),
        widget = wibox.container.background
    }
end

return function(fg, fg_hover, text, app)
    local count = 0
    local countWidget = wibox.layout.fixed.vertical()
    countWidget.forced_width = dpi(5)
    countWidget.spacing = dpi(2)

    local clientIsApp = function(c)
        -- returns if the client c is the same as the sidebarbox-app (e.g. firefox, kitty, ...)
        -- some fiddling needed, is kinda hacky

        if app == "intellij-idea-ultimate-edition" and c.class == "jetbrains-idea" then
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

    client.connect_signal("manage", function(c)
        if clientIsApp(c) then
            count = count + 1

            -- don't add unlimited indicators
            if count < 6 then
                countWidget:insert(1, countIndicator())
            end
        end
    end)

    client.connect_signal("unmanage", function(c)
        if clientIsApp(c) then
            count = count - 1
            if count < 5 then
                countWidget:remove(1)
            end
        end
    end)

    local findApp = function()
        -- open client if at already exists
        -- spawn new client otherwise
        if count > 0 then
            for _, tag in pairs(root.tags()) do
                for _, c in pairs(tag:clients()) do
                    if clientIsApp(c) then
                        c:jump_to(false)
                        return
                    end
                end
            end
        else
            awful.spawn(app)
        end
    end

    return wibox.widget {
        {
            nil,
            countWidget,
            nil,
            expand = "none",
            widget = wibox.layout.align.vertical
        },
        dockbox(fg, fg_hover, text, function()
            findApp()

            awesome.emit_signal("dashboard::close")
        end),
        spacing = dpi(2),
        layout = wibox.layout.fixed.horizontal
    }
end