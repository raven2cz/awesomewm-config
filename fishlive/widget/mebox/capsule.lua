--[[
    David Kosorin (kosorin) - https://github.com/kosorin
    kosorin/awesome-rice is licensed under the
    GNU General Public License v3.0
    https://github.com/kosorin/awesome-rice/blob/main/LICENSE
    (Yet another) Config for Awesome window manager.
    Complete code date: 
    03/15/2023
]]
local setmetatable = setmetatable
local gtable = require("gears.table")
local wibox = require("wibox")
local base = require("wibox.widget.base")
local noice = require("fishlive.widget.mebox.noice")
local theme = require("fishlive.widget.mebox.theme.capsule_theme")


local module = { mt = {} }

function module:layout(_, width, height)
    if not self._private.layout then
        return
    end
    return { base.place_widget_at(self._private.layout, 0, 0, width, height) }
end

function module:fit(context, width, height)
    if not self._private.layout then
        return 0, 0
    end
    return base.fit_widget(self, context, self._private.layout, width, height)
end

function module:get_widget()
    return self._private.content_container:get_widget()
end

function module:set_widget(widget)
    if self._private.content_container:get_widget() == widget then
        return
    end

    widget = widget and base.make_widget_from_value(widget)
    if widget then
        base.check_widget(widget)
    end

    self._private.content_container:set_widget(widget)
    self:emit_signal("property::widget")
end

function module:get_children()
    return self._private.content_container:get_children()
end

function module:set_children(children)
    self:set_widget(children[1])
end

-- TODO: Rename `enabled` property to something more meaningful

function module:get_enabled()
    return self._private.enabled
end

function module:set_enabled(value)
    value = not not value
    if self._private.enabled == value then
        return
    end
    self._private.enabled = value

    local overlay = self._private.layout:get_children_by_id("#overlay")[1]
    if overlay then
        overlay.visible = self._private.enabled
    end
end

noice.define_style_properties(module, {
    background = { id = "#background", property = "bg" },
    foreground = { id = "#background", property = "fg" },
    border_color = { id = "#background", property = "border_color" },
    border_width = { id = "#background", property = "border_width" },
    shape = { id = "#background", property = "shape" },
    margins = { id = "#margin", property = "margins" },
    paddings = { id = "#padding", property = "margins" },
    hover_overlay = { id = "#hover_overlay", property = "bg" },
    press_overlay = { id = "#press_overlay", property = "bg" },
})

function module.new(args)
    args = args or {}

    local self = base.make_widget(nil, nil, { enable_properties = true })

    gtable.crush(self, module, true)

    self._private.layout = wibox.widget {
        id = "#margin",
        layout = wibox.container.margin,
        {
            id = "#background",
            layout = wibox.container.background,
            {
                id = "#background_content",
                layout = wibox.layout.stack,
                {
                    id = "#overlay",
                    layout = wibox.container.background,
                    visible = false,
                    {
                        layout = wibox.layout.stack,
                        {
                            id = "#hover_overlay",
                            layout = wibox.container.background,
                            visible = false,
                        },
                        {
                            id = "#press_overlay",
                            layout = wibox.container.background,
                            visible = false,
                        },
                    },
                },
                {
                    id = "#padding",
                    layout = wibox.container.margin,
                    {
                        id = "#content_container",
                        layout = wibox.container.constraint,
                        args.widget,
                    },
                },
            },
        },
    }

    self._private.content_container = self._private.layout:get_children_by_id("#content_container")[1]

    local background = self._private.layout:get_children_by_id("#background")[1]
    local overlay = self._private.layout:get_children_by_id("#overlay")[1]
    local hover_overlay = self._private.layout:get_children_by_id("#hover_overlay")[1]
    local press_overlay = self._private.layout:get_children_by_id("#press_overlay")[1]

    background:connect_signal("property::shape", function(_, shape)
        overlay.shape = shape
    end)

    self:connect_signal("mouse::enter", function()
        hover_overlay.visible = true
    end)
    self:connect_signal("mouse::leave", function()
        hover_overlay.visible = false
        press_overlay.visible = false
    end)

    self:connect_signal("button::press", function()
        press_overlay.visible = true
    end)
    self:connect_signal("button::release", function()
        press_overlay.visible = false
    end)

    noice.initialize_style(self, self._private.layout, theme.capsule.default_style)

    self:set_enabled(args.enabled ~= false)

    return self
end

function module.mt:__call(...)
    return module.new(...)
end

return setmetatable(module, module.mt)
