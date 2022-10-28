--[[

     Fishlive Lua Library
     Status Services

     Provides statues and send it to listeners

     Licensed under GNU General Public License v2
      * (c) 2022, A.Fischer
--]]

local wrequire     = require("fishlive.helpers").wrequire
local setmetatable = setmetatable

local status       = { _NAME = "fishlive.status" }

return setmetatable(status, { __index = wrequire })
