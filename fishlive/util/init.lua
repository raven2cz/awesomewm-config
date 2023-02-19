--[[

     Fishlive Lua Library
     Layouts, widgets and utilities for Awesome WM

     Utilities section

     Licensed under GNU General Public License v2
      * (c) 2021, A.Fischer
--]]

local io = io

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

-- return extract path from the full filepath.
-- This code will extract the path "path/to" from the filepath "path/to/myfile.txt"
-- and store it in the variable "path". The "match" function uses
-- a regular expression to match the pattern of the path,
-- which in this case is any character (.) that appears one or more times (+) before
-- the last forward slash (/) in the string, followed by any character
-- that is not a forward slash ([^/]*) and a file extension (.%w+).
-- The $ sign at the end of the pattern ensures that the match is at the end of the string.
function util.getPathFrom(filepath)
    return string.match(filepath, "(.+)/[^/]*%.%w+$")
end

-- check if folder exists --
function util.is_dir(path)
    local f = io.open(path, "r")
    if f == nil then return false end
    local ok, err, code = f:read(1)
    f:close()
    return code == 21
end

-- return images from the defined directoru
function util.getImgsFromDir(dir, subdir)
  local fulldir
  if subdir then
    fulldir = dir .. subdir .. "/"
  else
    fulldir = dir .. "/"
  end
  local imgNames = util.scandirArgs{dir=fulldir, fileExt='*.{png,jpg}'}
  local imgsources = {}
  for i=1,#imgNames do
    imgsources[i] = fulldir .. imgNames[i]
  end
  return imgNames, imgsources
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

-- get max screen_resolution X coordination
function util.screen_res_x()
  return io.popen("echo $(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f1)"):read("*all"):gsub("%s+", "")
end

-- get max screen_resolution Y coordination
function util.screen_res_y()
  return io.popen("echo $(xrandr --current | grep '*' | uniq | awk '{print $1}' | cut -d 'x' -f2)"):read("*all"):gsub("%s+", "")
end

return util
