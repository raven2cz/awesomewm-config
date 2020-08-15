local layout = require(... .. ".layout")
local editor = require(... .. ".editor")
local switcher = require(... .. ".switcher")
local function default_name(tag)
   if tag.machi_name_cache == nil then
      tag.machi_name_cache =
         tostring(tag.screen.geometry.width) .. "x" .. tostring(tag.screen.geometry.height) .. "+" ..
         tostring(tag.screen.geometry.x) .. "+" .. tostring(tag.screen.geometry.y) .. '+' .. tag.name
   end
   return tag.machi_name_cache
end
local default_editor = editor.default_editor
local default_layout = layout.create{ name_func = default_name }
local gcolor = require("gears.color")
local beautiful = require("beautiful")

local icon_raw
local source = debug.getinfo(1, "S").source
if source:sub(1, 1) == "@" then
   icon_raw = source:match("^@(.-)[^/]+$") .. "icon.png"
end

local function get_icon()
   if icon_raw ~= nil then
      return gcolor.recolor_image(icon_raw, beautiful.fg_normal)
   else
      return nil
   end
end

return {
   layout = layout,
   editor = editor,
   switcher = switcher,
   default_editor = default_editor,
   default_layout = default_layout,
   icon_raw = icon_raw,
   get_icon = get_icon,
}
