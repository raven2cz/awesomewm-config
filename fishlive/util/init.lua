--[[

     Fishlive Lua Library
     Layouts, widgets and utilities for Awesome WM

     Utilities section

     Licensed under GNU General Public License v2
      * (c) 2021, A.Fischer
--]]

local awful = require("awful")

-- fishlive utilities submodule
-- fishlive.util
local util = { _NAME = "fishlive.util" }

-- Fisher-Yates shuffle of given table
function util.shuffle(tbl)
  for i = #tbl, 2, -1 do
    local j = math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

-- return string content of the directory
function util.scandir(directory)
  local i, t, popen = 0, {}, io.popen
  local pfile = popen('ls -a "'..directory..'"')
  for filename in pfile:lines() do
    i = i + 1
    if i > 2 then t[i-2] = filename end
  end
  pfile:close()
  return t
end

-- return copied table of the instance
function util.copyTable(t)
  local u = {}
  for k, v in pairs(t) do u[k] = v end
  return setmetatable(u, getmetatable(t))
end

return util
