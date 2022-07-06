--[[

     Fishlive Lua Library
     Plugins for 3rd parties library and addons

     Plugins section

     Licensed under GNU General Public License v2
      * (c) 2022, A.Fischer
--]]

-- titlebars NICE
local nice = require("nice")

-- fishlive plugins submodule
local plugins = { _NAME = "fishlive.plugins" }

-- Configure Nice Titlebars Library
function plugins.createTitlebarsNiceLib()
  nice {
      win_shade_enabled = true,
      titlebar_height = 29,
      titlebar_radius = 11,
      titlebar_font = "Iosevka Nerd Font 9",
      button_size = 13,
      button_margin_horizontal = 5,
      button_margin_top = 2,
      minimize_color = "#ffb400",
      maximize_color = "#4CBB17",
      close_color = "#ee4266",
      sticky_color = "#774f73",
      floating_color = "#774f73",
      ontop_color = "#774f73",
      titlebar_items = {
          left = {"sticky", "floating", "ontop"},
          middle = "title",
          right = {"minimize", "maximize","close"},
      },
      tooltip_messages = {
          close = "Close",
          minimize = "Minimize",
          maximize_active = "Unmaximize",
          maximize_inactive = "Maximize",
          floating_active = "Floating",
          floating_inactive = "Tiling",
          ontop_active = "OnTop",
          ontop_inactive = "NotOnTop",
          sticky_active = "Sticky",
          sticky_inactive = "NotSticky",
      }
  }
end

return plugins
