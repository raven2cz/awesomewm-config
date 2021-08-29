--[[

     Fishlive Lua Library
     Layouts, widgets and utilities for Awesome WM

     Utilities section

     Licensed under GNU General Public License v2
      * (c) 2021, A.Fischer
--]]

local wrequire     = require("fishlive.helpers").wrequire
local setmetatable = setmetatable

local layout       = { _NAME = "fishlive.layout" }

return setmetatable(layout, { __index = wrequire })
