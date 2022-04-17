local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local fishlive = require("fishlive")

local function layout_row(l, selected)
    local name = awful.layout.getname(l) or "[no name]"
    local img = gears.surface.load_silently(beautiful["layout_" .. name], false)

    local row = wibox.widget {
        {
            {
                {
                    {
                        image = img,
                        forced_width = 16,
                        forced_height = 16,
                        widget = wibox.widget.imagebox
                    },
                    right = 6,
                    widget = wibox.container.margin
                },
                {
                    markup = selected and "<i><b><u>" .. name .. "</u></b></i>" or name,
                    widget = wibox.widget.textbox
                },
                layout = wibox.layout.fixed.horizontal
            },
            margins = 6,
            widget = wibox.container.margin
        },
        bg = beautiful.bg_normal,
        fg = beautiful.fg_normal,
        widget = wibox.container.background
    }

    row:connect_signal("mouse::leave", function(bg_container)
        bg_container:set_bg(beautiful.bg_normal)
        bg_container.fg = beautiful.fg_normal
    end)
    row:connect_signal("mouse::enter", function(bg_container)
        bg_container:set_bg(beautiful.bg_focus)
        bg_container.fg = beautiful.fg_focus
    end)

    row:buttons(
        awful.button({}, 1, function()
                awful.layout.set(l)
        end)
    )
    return row
end

local function build_rows(s)
    local rows = { layout = wibox.layout.fixed.vertical }
    for _, l in ipairs(awful.layout.layouts) do
        table.insert(rows, layout_row(l, l == awful.layout.get(s)))
    end
    return rows
end

local function build_popups()
    local res = {}
    for s in screen do
        table.insert(res, fishlive.widget.widget_popup {
            content_function = function() return build_rows(s) end,
            maximum_width = 200,
            hide_on_left_click = true,
        })
    end
    return res
end

local popups = build_popups()

local function layoutsmenu_widget_builder(s)
    local layoutsmenu_widget = awful.widget.layoutbox(s)

    layoutsmenu_widget:buttons(awful.button({}, 1, function()
        popups[s.index]:toggle()
    end))
    return layoutsmenu_widget
end

return layoutsmenu_widget_builder
