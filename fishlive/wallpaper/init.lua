--[[

     Fishlive Lua Library
     Wallpaper Extension for Awesome WM

     Licensed under GNU General Public License v2
      * (c) 2022, A.Fischer
--]]

local awful = require("awful")
local gears = require("gears")
local helpers = require("fishlive.helpers")

-- fishlive wallpaper submodule
-- fishlive.wallpaper
local wallpaper = { _NAME = "fishlive.wallpaper" }

-- User Wallpaper Changer
function wallpaper.createUserWallpaper(t)
   local screen = t.screen
   local wppath_user = t.wppath_user
   local wp_user = helpers.scandir(wppath_user)
   local wp_user_idx = 0
   t.wp_user = wp_user

   return function(direction)
     local maxIdx = #wp_user
     wp_user_idx = wp_user_idx + direction
     if wp_user_idx < 1 then wp_user_idx = maxIdx end
     if wp_user_idx > maxIdx then wp_user_idx = 1 end

     local wp = wp_user[wp_user_idx]

     for s in screen do
       for i = 1,#s.tags do
         local tag = s.tags[i]
         if tag.selected then
           t.wallpaper_user = wppath_user .. wp
           t.wallpaper_user_tag = tag
           awesome.emit_signal("wallpaper::change", t.wallpaper_user)
           gears.wallpaper.maximized(t.wallpaper_user, s, false)
         end
       end
     end
   end
end

-- Tag Wallpaper Changer
function wallpaper.registerTagWallpaper(t)
  local screen = t.screen
  local wp_selected = t.wp_selected
  local wp_random = t.wp_random
  local wppath = t.wppath
  local wp_user_params = t.wp_user_params
  local wp_colorscheme_params = t.wp_colorscheme_params
  local change_wallpaper_colorscheme = t.change_wallpaper_colorscheme

  -- For each screen
  for scr in screen do
    -- Set actual wallpaper for first tag and screen
    local wp = wp_selected[1]
    if wp == "random" then wp = wp_random[1] end
    awesome.emit_signal("wallpaper::change", wppath .. wp)
    gears.wallpaper.maximized(wppath .. wp, scr, false)

    -- Go over each tab
    for t = 1,#scr.tags do
      local tag = scr.tags[t]
      tag:connect_signal("property::selected", function (tag)
        -- And if selected
        if not tag.selected then return end
        -- Set the color of tag
        --theme.taglist_fg_focus = theme.baseColors[tag.index]
        -- Set random wallpaper
        if wp_user_params.wallpaper_user_tag == tag then
          wp = wp_user_params.wallpaper_user
        elseif wp_colorscheme_params.wallpaper_user_tag == tag then
          wp = wp_colorscheme_params.wallpaper_user
        elseif wp_selected[t] == "random" then
          local position = math.random(1, #wp_random)
          wp = wppath .. wp_random[position]
        elseif wp_selected[t] == "colorscheme" then
          if not wp_colorscheme_params.wallpaper_user then
            change_wallpaper_colorscheme(1)
          end
          wp = wp_colorscheme_params.wallpaper_user
        else
          wp = wppath .. wp_selected[t]
        end
        --gears.wallpaper.fit(wppath .. wp_selected[t], s)
        awesome.emit_signal("wallpaper::change", wp)
        gears.wallpaper.maximized(wp, s, false)
      end)
    end
  end
end

return wallpaper
