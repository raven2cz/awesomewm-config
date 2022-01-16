--[[

     Fishlive Lua Library
     Colorscheme Switcher for Awesome WM

     UI section

     Licensed under GNU General Public License v2
      * (c) 2022, A.Fischer
--]]

local wrequire = require("fishlive.helpers").wrequire
local setmetatable = setmetatable

local colorscheme = { _NAME = "fishlive.colorscheme" }

return setmetatable(colorscheme, { __index = wrequire })
