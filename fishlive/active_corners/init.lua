--[[
--  _ __ __ ___   _____ _ __
-- | '__/ _` \ \ / / _ \ '_  \  Antonin Fischer (raven2cz)
-- | | | (_| |\ V /  __/ | | |  https://fishlive.org/
-- |_|  \__,_| \_/ \___|_| |_|  https://github.com/raven2cz

Active Corners Library for AwesomeWM

This library provides an easy way to create and manage active corners in AwesomeWM,
allowing for custom actions to be triggered when the mouse enters defined screen corners.

Improved from hot corners
https://github.com/eromatiya/awesome-glorious-widgets/blob/master/hot-corners/init.lua
origin: manilarome gerome.matilla07@gmail.com
modification: raven2cz to active corners implementation
version: 1.0
]]

local gears = require("gears")
local wibox = require("wibox")
local awful = require("awful")

local active_corners = { _NAME = "fishlive.active_corners" }

-- Internal initialization function
local function _init(s, user_callbacks)
    local screen_corners = {
        tl = { x = 0, y = 0 },
        tr = { x = s.geometry.width - 1, y = 0 },
        br = { x = s.geometry.width - 1, y = s.geometry.height - 1 },
        bl = { x = 0, y = s.geometry.height - 1 }
    }

    for corner_name, position in pairs(screen_corners) do
        local corner_wibox = wibox {
            x = position.x,
            y = position.y,
            visible = true,
            screen = s,
            ontop = true,
            opacity = 0.0,
            height = 1,
            width = 1,
            type = 'utility'
        }

        local corner_timer = gears.timer {
            timeout = 0.5,
            call_now = false,
            autostart = false,
            single_shot = true,
            callback = function()
                if user_callbacks[corner_name] then
                    user_callbacks[corner_name]()
                end
            end
        }

        corner_wibox:connect_signal("mouse::enter", function()
            corner_timer:start()
        end)

        corner_wibox:connect_signal("mouse::leave", function()
            corner_timer:stop()
        end)
    end
end

-- Function to initialize active corners with user-defined callbacks
function active_corners.init(screen, user_callbacks)
    local initialization_delay = 1 -- Delay in seconds

    gears.timer.start_new(initialization_delay, function()
        _init(screen, user_callbacks)
        return false -- Ensures the timer runs only once
    end)
end

return active_corners
