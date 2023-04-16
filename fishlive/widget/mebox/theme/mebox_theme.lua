local dpi = require("beautiful.xresources").apply_dpi
local beautiful = require("beautiful")
local gshape = require("gears.shape")
local wibox = require("wibox")
local aplacement = require("awful.placement")
local widget_helper = require("fishlive.helpers")
local css = require("fishlive.widget.mebox.css")
local pango = require("fishlive.widget.mebox.pango")
local capsule = require("fishlive.widget.mebox.capsule")
local theme_capsule = require("fishlive.widget.mebox.theme.capsule_theme")

local theme = {}

---------------------------------------------------------------------------------------------

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

---------------------------------------------------------------------------------------------

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

---------------------------------------------------------------------------------------------

theme.mebox.default_style = widget_helper.crush_clone(theme.popup.default_style, {
    separator_template = theme.mebox.horizontal_separator_template,
    header_template = theme.mebox.header_template,
    placement_bounding_args = {
        honor_workarea = true,
        honor_padding = false,
        margins = theme.popup.margins,
    },
    placement = false,
    submenu_offset = dpi(4),
    active_opacity = 1,
    inactive_opacity = 1,
    paddings = {
        left = dpi(8),
        right = dpi(8),
        top = dpi(8),
        bottom = dpi(8),
    },
    item_width = dpi(128),
    item_height = dpi(36),
    item_template = {
        id = "#container",
        widget = capsule,
        margins = {
            left = 0,
            right = 0,
            top = dpi(2),
            bottom = dpi(2),
        },
        paddings = {
            left = dpi(8),
            right = dpi(8),
            top = dpi(6),
            bottom = dpi(6),
        },
        {
            layout = wibox.layout.align.horizontal,
            expand = "inside",
            nil,
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(12),
                {
                    id = "#icon",
                    widget = wibox.widget.imagebox,
                    resize = true,
                },
                {
                    id = "#text",
                    widget = wibox.widget.textbox,
                },
            },
            {
                widget = wibox.container.margin,
                right = -dpi(4),
                {
                    visible = false,
                    id = "#submenu_icon",
                    widget = wibox.widget.imagebox,
                    resize = true,
                },
            },
        },
        update_callback = function(self, item, menu)
            self.forced_width = item.width or menu.item_width
            self.forced_height = item.height or menu.item_height

            self.enabled = item.enabled
            self.opacity = item.enabled and 1 or 0.5

            local style = item.active
                and (item.selected
                    and theme_capsule.capsule.styles.active_selected
                    or theme_capsule.capsule.styles.active)
                or (item.urgent
                    and (item.selected
                        and theme_capsule.capsule.styles.urgent_selected
                        or theme_capsule.capsule.styles.urgent)
                    or (item.selected
                        and theme_capsule.capsule.styles.normal_selected
                        or theme_capsule.capsule.styles.normal))
            self:apply_style(style)

            local icon_widget = self:get_children_by_id("#icon")[1]
            if icon_widget then
                local paddings = menu.paddings
                icon_widget.forced_width = self.forced_height - paddings.top - paddings.bottom

                local icon, color
                if item.checked == nil then
                    icon = item.icon
                    color = item.icon_color
                else
                    local checkbox_type = item.checkbox_type or "checkbox"
                    local style = theme.mebox[checkbox_type][not not item.checked]
                    icon = style.icon
                    color = style.color
                end

                if color ~= false then
                    if not color or item.active or item.selected then
                        color = style.foreground
                    end
                    local stylesheet = css.style { path = { fill = color } }
                    icon_widget:set_stylesheet(stylesheet)
                else
                    icon_widget:set_stylesheet(nil)
                end

                icon_widget:set_image(icon)
            end

            local text_widget = self:get_children_by_id("#text")[1]
            if text_widget then
                local text = item.text or ""
                text_widget:set_markup(pango.span { foreground = style.foreground, text, })
            end

            local submenu_icon_widget = self:get_children_by_id("#submenu_icon")[1]
            if submenu_icon_widget then
                submenu_icon_widget.visible = not not item.submenu
                if submenu_icon_widget.visible then
                    local icon = item.submenu_icon or beautiful.dir .. "/icons/chevron-right.svg"
                    local color = style.foreground
                    local stylesheet = css.style { path = { fill = color } }
                    submenu_icon_widget:set_stylesheet(stylesheet)
                    submenu_icon_widget:set_image(icon)
                end
            end

            if item.flex then
                self.forced_width = self:fit({
                    screen = menu.screen,
                    dpi = menu.screen.dpi,
                    drawable = menu._drawable,
                }, menu.screen.geometry.width, menu.screen.geometry.height)
            end
        end,
    },
})

return theme