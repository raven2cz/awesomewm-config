local dpi = require("beautiful.xresources").apply_dpi
local beautiful = require("beautiful")
local gshape = require("gears.shape")
local wibox = require("wibox")
local aplacement = require("awful.placement")
local pango = require("fishlive.widget.mebox.pango")

local theme = {}

-- -------------------------------------------------------------------------------------------

theme.popup = {
    margins = dpi(6),
}
theme.popup.default_style = {
    bg = beautiful.background,
    fg = beautiful.foreground,
    border_color = beautiful.bg_focus,
    border_width = dpi(1),
    shape = function(cr, width, height)
        gshape.rounded_rect(cr, width, height, dpi(16))
    end,
    placement = aplacement.under_mouse,
    paddings = {
        left = dpi(20),
        right = dpi(20),
        top = dpi(20),
        bottom = dpi(20),
    },
}

-- -------------------------------------------------------------------------------------------

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

-- -------------------------------------------------------------------------------------------

theme.mebox = {
    horizontal_separator_template = {
        widget = wibox.widget.separator,
        orientation = "horizontal",
        forced_height = dpi(16),
        color = beautiful.base02,
        thickness = dpi(1),
        span_ratio = 1,
        update_callback = function(self, item, menu)
            self.forced_width = item.width or menu.item_width
        end,
    },
    vertical_separator_template = {
        widget = wibox.widget.separator,
        orientation = "vertical",
        forced_width = dpi(16),
        color = beautiful.base02,
        thickness = dpi(1),
        span_ratio = 1,
        update_callback = function(self, item, menu)
            self.forced_height = item.height or menu.item_height
        end,
    },
    header_template = {
        widget = wibox.container.margin,
        margins = {
            left = dpi(8),
            right = dpi(8),
            top = dpi(6),
            bottom = dpi(6),
        },
        {
            id = "#text",
            widget = wibox.widget.textbox,
        },
        update_callback = function(self, item)
            local text_widget = self:get_children_by_id("#text")[1]
            if text_widget then
                local color = beautiful.fg_urgent
                local text = item.text or ""
                text_widget:set_markup(pango.span {
                    size = "smaller",
                    text_transform = "uppercase",
                    foreground = color,
                    weight = "bold",
                    text,
                })
            end
        end,
    },
    checkbox = {
        [false] = {
            icon = beautiful.dir .. "/icons/checkbox-blank-outline.svg",
            color = beautiful.bg_focus,
        },
        [true] = {
            icon = beautiful.dir .. "/icons/checkbox-marked.svg",
            color = beautiful.bg_urgent,
        },
    },
    radiobox = {
        [false] = {
            icon = beautiful.dir .. "/icons/radiobox-blank.svg",
            color = beautiful.bg_focus,
        },
        [true] = {
            icon = beautiful.dir .. "/icons/radiobox-marked.svg",
            color = beautiful.bg_urgent,
        },
    },
    toggle_switch = {
        [false] = {
            icon = beautiful.dir .. "/icons/toggle-switch-off-outline.svg",
            color = beautiful.bg_urgent,
        },
        [true] = {
            icon = beautiful.dir .. "/icons/toggle-switch.svg",
            color = beautiful.bg_urgent,
        },
    },
}

return theme