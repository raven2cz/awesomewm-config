local beautiful = require("beautiful")
local colorscheme = require("fishlive.colorscheme")
local dpi = require("beautiful.xresources").apply_dpi

local config_menu_template = { mt = { __index = {} } }

local root_menu

local function generate_menu(items)
    return {
        item_width = dpi(200),
        item_height = dpi(30),
        items_source = items,
    }
end

local function convert_awesome_menu(awmenu)
    local menu = {}
    for i, item in ipairs(awmenu) do
        menu[i] = {
            text = item[1],
            callback = item[2],
        }
    end
    return menu
end

root_menu = generate_menu({
    {
        text = "Colorschemes",
        icon = beautiful.dir .. "/icons/theme-light-dark.svg",
        icon_color = beautiful.base0D,
        submenu = generate_menu(convert_awesome_menu(colorscheme.menu.prepare_colorscheme_menu()))
    },
    {
        text = "Portraits",
        icon = beautiful.dir .. "/icons/pirate.svg",
        icon_color = beautiful.base0D,
        submenu = generate_menu(convert_awesome_menu(colorscheme.menu.prepare_portrait_menu()))
    }
})

function config_menu_template.mt.__index.shared()
    return root_menu or {}
end

return setmetatable(config_menu_template, config_menu_template.mt)
