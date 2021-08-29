
--------------------------------------------- widget.tabbar.default.lua -- ;

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

local bg_normal = beautiful.tabbar_bg_normal or beautiful.bg_normal or "#1a1a1a"
local fg_normal = beautiful.tabbar_fg_normal or beautiful.fg_normal or "#595959"
local bg_focus  = beautiful.tabbar_bg_focus  or beautiful.bg_focus  or "#292929"
local bg_active  = "#43417a"
-- local bg_active  = "#394037"

local fg_focus  = beautiful.tabbar_fg_focus  or beautiful.fg_focus  or "#ffffff"
local font      = beautiful.tabbar_font      or beautiful.font      or "Recursive Sans Casual Static 8"
local size      = beautiful.tabbar_size or 14
local position = beautiful.tabbar_position or "bottom"

local function create(c, focused_bool, buttons, idx)
    local flexlist = wibox.layout.flex.horizontal
    local title_temp = string.lower(c.class) or c.name or "-"
    local bg_temp = bg_normal
    local fg_temp = fg_normal

    if focused_bool then 
        bg_temp = bg_focus
        fg_temp = fg_focus
    end

    if client.focus == c and focused_bool  then
        bg_temp = bg_active
    end --|when the client is maximized and then minimized, bg
        --|color should be active

    local text_temp = wibox.widget.textbox()

    text_temp.align = "center"
    text_temp.valign = "center"
    text_temp.wrap = "word"
    text_temp.font = font
    text_temp.focused = false
    text_temp.markup = "<span foreground='" .. fg_temp .. "'>" .. title_temp.. "</span>"

    if focused_bool then text_temp.focused = true end

    local wid_temp = wibox.widget({
        id = c.window,
        text_temp,
        buttons = buttons,
        bg = bg_temp,
        focused = focused_bool,
        widget = wibox.container.background()
    })

    return wid_temp
end 

return {
    layout = wibox.layout.flex.horizontal,
    create = create,
    create_focused = create_focused,
    position = position,
    size = size,
    bg_normal = bg_normal,
    bg_focus  = bg_focus,
}