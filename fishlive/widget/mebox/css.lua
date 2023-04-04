--[[
    David Kosorin (kosorin) - https://github.com/kosorin
    kosorin/awesome-rice is licensed under the
    GNU General Public License v3.0
    https://github.com/kosorin/awesome-rice/blob/main/LICENSE
    (Yet another) Config for Awesome window manager.
    Complete code date: 
    03/15/2023
]]
local format = string.format

local css = {}

function css.style(rules)
    local result = ""
    for selector, declarations in pairs(rules) do
        result = format("%s %s { ", result, selector)
        for property, value in pairs(declarations) do
            result = format("%s %s: %s; ", result, property, tostring(value))
        end
        result = format("%s} ", result)
    end
    return result
end

return css
