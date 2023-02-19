--[[

     Licensed under GNU General Public License v2
      * (c) 2013, Luca CPZ

--]]

local helpers  = require("lain.helpers")
local wibox    = require("wibox")
local helpers  = require("fishlive.helpers")

-- {thermal} temperature info
-- lain.widget.temp_ryzen

local function factory(args)
    local temp     = { widget = wibox.widget.textbox() }
    local args     = args or {}
    local timeout  = args.timeout or 30
    local settings = args.settings or function() end

    function temp.update()
        helpers.async({"/home/box/bin/cputemp"}, function(f)
            coretemp_now = helpers.all_trim(f) or "N/A"
            widget = temp.widget
            settings()
        end)
    end

    helpers.newtimer("thermal", timeout, temp.update)

    return temp
end

return factory
