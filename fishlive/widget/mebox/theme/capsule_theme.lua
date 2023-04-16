local dpi = require("beautiful.xresources").apply_dpi
local beautiful = require("beautiful")
local gshape = require("gears.shape")

local theme = {}

---------------------------------------------------------------------------------------------

theme.capsule = {
    item_content_spacing = dpi(8),
    item_spacing = dpi(16),
    bar_width = dpi(80),
    bar_height = dpi(12),
    shape_radius = dpi(8),
}

theme.capsule.default_style = {
    hover_overlay = beautiful.fg_focus .. "10",
    press_overlay = beautiful.fg_focus .. "10",
    background = beautiful.bg_normal,
    foreground = beautiful.fg_normal,
    border_color = beautiful.bg_focus,
    border_width = 0,
    shape = function(cr, width, height)
        gshape.rounded_rect(cr, width, height, theme.capsule.shape_radius)
    end,
    margins = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    },
    paddings = {
        left = dpi(14),
        right = dpi(14),
        top = dpi(6),
        bottom = dpi(6),
    },
}

theme.capsule.styles = {
    normal = {
        background = theme.capsule.default_style.background,
        foreground = theme.capsule.default_style.foreground,
        border_color = theme.capsule.default_style.border_color,
        border_width = theme.capsule.default_style.border_width,
    },
    active = {
        hover_overlay = beautiful.bg_normal .. "20",
        press_overlay = beautiful.bg_focus .. "20",
        background = beautiful.bg_normal .. "20",
        foreground = beautiful.fg_normal,
        border_color = theme.capsule.default_style.border_color,
        border_width = 0,
    },
    disabled = {
        background = beautiful.bg_normal,
        foreground = beautiful.fg_normal,
        border_color = beautiful.fg_focus,
        border_width = 0,
    },
    selected = {
        background = beautiful.bg_focus,
        foreground = beautiful.fg_focus,
        border_color = beautiful.bg_urgent,
        border_width = dpi(1),
    },
    urgent = {
        background = beautiful.bg_urgent,
        foreground = beautiful.fg_urgent,
        border_color = beautiful.fg_focus,
        border_width = dpi(1),
    },
    normal_selected = {
        background = beautiful.bg_focus,
        foreground = beautiful.fg_focus,
        border_color = beautiful.bg_urgent,
        border_width = dpi(0),
    },
    active_selected = {
        background = beautiful.bg_focus,
        foreground = beautiful.fg_focus,
        border_color = beautiful.bg_urgent,
        border_width = dpi(0),
    },
    urgent_selected = {
        background = beautiful.bg_urgent,
        foreground = beautiful.fg_urgent,
        border_color = beautiful.bg_urgent,
        border_width = dpi(0),
    },
}

return theme