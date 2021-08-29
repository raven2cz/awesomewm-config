local naughty = require('naughty')
local gears = require("gears")
local awful = require("awful")
local beautiful = require('beautiful')

local function old_shuffle(direction)
   return function()
      local tablist = region_tablist()

      if direction == "backward" then
         local prev_client = nil
         for i = #tablist, 1, -1 do
            prev_client = tablist[i]
            prev_client:emit_signal("request::activate", "mouse_enter",{raise = true})
            break --|activate previous client
         end
         return
      end

      if direction == "forward" then
         local next_client = nil
         for _, cc in ipairs(tablist) do
            client.focus:lower()
            next_client = tablist[_+1]
            next_client:emit_signal("request::activate", "mouse_enter",{raise = true})
            break --|activate next client
         end
         return
      end
   end
end --|
    --|this uses the old hack that doesn't rely on
    --|global_client_index. keeping it here for historical
    --|reasons in case we need this again.

local function clear_tabbar(c, position)
   if not c then return end
   local position = position or "bottom"
   local titlebar = awful.titlebar(c, {size=3, position=position})
   titlebar:setup{
      layout=wibox.layout.flex.horizontal, nil
   }
end --|clears bottom tabbar

local function reload(m)
  if package.loaded[m] then
    local attrs = {}
    for key,value in pairs(package.loaded[m]) do
      attrs[key] = value
    end
    package.loaded[m] = nil
    temp_module = require(tostring(m))
    for key,value in pairs(attrs) do
      temp_module[key] = value
    end
  else
    temp_module = require(m)
  end
  return temp_module
end

local function getlowest(table)
   local low = math.huge
   local index
   for i, v in pairs(table) do
      if v < low then
         low = v
         index = i
      end
   end
   return index
end

local function compare(a,b)
   return a.v < b.v
end

local function tablelength(T)
   local count = 0
   for _ in pairs(T) do count = count + 1 end
   return count
end --|return table length
    
local function set_contains(set, key)
    return set[key] ~= nil
end --|tests table if key exists

local function get_client_ix(id, ids)
   for i, c in ipairs(ids) do
      if id == c.window then
         return i
      end
   end
end --|finds out where id is located inside ids.


-------------------------------------------------------------- exports -- ;

return {
    set_contains = set_contains,
    tablelength = tablelength,
    compare = compare,
    getlowest = getlowest,
    get_client_ix = get_client_ix,
    reload = reload,
    clear_tabbar = clear_tabbar
}