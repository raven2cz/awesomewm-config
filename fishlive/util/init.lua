--[[

     Fishlive Lua Library
     Layouts, widgets and utilities for Awesome WM

     Utilities section

     Licensed under GNU General Public License v2
      * (c) 2021, A.Fischer
--]]

local io = io
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

-- return string content of the directory with ls arguments and file extensions support
function util.scandirArgs(lsargs)
  local dir = lsargs.dir
  local args = lsargs.args or ''
  local fileExt = lsargs.fileExt or ''
  local i, t, popen = 0, {}, io.popen
  local pfile = popen('cd '..dir..'; ls '..args..' '..fileExt)
  for filename in pfile:lines() do
    i = i + 1
    t[i] = filename
  end
  pfile:close()
  return t
end

-- check if folder exists --
function util.is_dir(path)
    local f = io.open(path, "r")
    if f == nil then return false end
    local ok, err, code = f:read(1)
    f:close()
    return code == 21
end

-- return copied table of the instance
function util.copyTable(t)
  local u = {}
  for k, v in pairs(t) do u[k] = v end
  return setmetatable(u, getmetatable(t))
end

function util.screen_resolution()
  return io.popen("echo $(xwininfo -root | grep 'geometry' | awk '{print $2;}')"):read("*all"):gsub("%s+", "")
end

function util.screen_res_x()
  return io.popen("echo $(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f1)"):read("*all"):gsub("%s+", "")
end

function util.screen_res_y()
  return io.popen("echo $(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f2)"):read("*all"):gsub("%s+", "")
end

return util
