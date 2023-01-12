--[[

     Fishlive Lua Library
     Signal Services

     Provides signals and send it to listeners

     Licensed under GNU General Public License v2
      * (c) 2023, A.Fischer
--]]

local wrequire     = require("fishlive.helpers").wrequire
local setmetatable = setmetatable

local signal       = { _NAME = "fishlive.signal" }

return setmetatable(signal, { __index = wrequire })
