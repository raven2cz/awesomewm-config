local colorscheme = require "fishlive.colorscheme"

local menu = {}

local function writeToFile(resource, content)
  local file = assert(io.open(resource, "w"))
  file:write(content)
  file:close()
end

-- Colorschemes Switcher --
menu.prepare_colorscheme_menu = function()
  local menucs = {}
  for i, cs in ipairs(colorscheme.table) do
      menucs[i] = { cs.scheme, function()
          local homeDir = os.getenv("HOME")
          -- call global colorscheme script for switch all GNU/Linux apps
          os.execute(homeDir.."/.local/bin/global-colorscheme.lua " .. cs.scheme_id)
          -- permanent storage of selected colorscheme to last.lua
          writeToFile(
            homeDir .. "/.config/awesome/fishlive/colorscheme/last.lua",
            'return require "fishlive.colorscheme".' .. cs.scheme_id
          )
          -- permanent storage of selected colorscheme for global system
          writeToFile(
            homeDir .. "/.colorscheme",
            cs.scheme_id
          )
          -- permanent storage of selected colorscheme for global system
          writeToFile(
            homeDir .. "/.portrait",
            cs.scheme_id
          )
          -- change rofi theme
          writeToFile(
            homeDir .. "/.config/rofi/config.rasi",
            '@theme "'..homeDir..'/.config/rofi/multicolor-'..cs.scheme_id..'.rasi"'
          )
          -- change conky theme
          writeToFile(
            homeDir .. "/.config/conky/MX-CoreBlue/conkytheme.lua",
            "return { color0 = '"..cs.base07.."', color1 = '" .. cs.leading_fg .. "' }"
          )
          -- restart AWESOME
          awesome.restart()
        end
      }
  end
  return menucs
end

-- Portrait Colorscheme Switcher --
menu.prepare_portrait_menu = function()
  local menucs = {}
  -- table of supported portraits
  for i, cs in ipairs(colorscheme.table_portrait) do
      menucs[i] = { cs, function()
          local homeDir = os.getenv("HOME")
          -- permanent storage of selected colorscheme for global system
          writeToFile(
            homeDir .. "/.portrait",
            cs
          )
          -- restart AWESOME
          awesome.restart()
        end
      }
  end
  return menucs
end

return menu
