local colorscheme = require "fishlive.colorscheme"

menu = {}

-- Colorschemes Switcher --
menu.prepare_colorscheme_menu = function()
  local menucs = {}
  for i, cs in ipairs(colorscheme.table) do
      menucs[i] = { cs.scheme, function()
          -- call global colorscheme script for switch all GNU/Linux apps
          os.execute("global-colorscheme.lua " .. cs.scheme_id)
          -- permanent storage of selected colorscheme to last.lua
          local file = io.open(os.getenv("HOME") .. "/.config/awesome/fishlive/colorscheme/last.lua", "w")
          file:write('return require "fishlive.colorscheme".' .. cs.scheme_id)
          file:close()
          awesome.restart()
        end
      }
  end
  return menucs
end

return menu
