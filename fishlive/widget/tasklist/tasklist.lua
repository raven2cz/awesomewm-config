local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi

local helpers = require("fishlive.helpers")
local launchers = require("fishlive.widget.tasklist.launchers")
local get_app_widget = require("fishlive.widget.tasklist.app-widget")
local icons = require("fishlive.widget.tasklist.icons")
local borders = require("fishlive.widget.tasklist.borders")
local favourites = require("fishlive.widget.tasklist.favourites")
local source = require("fishlive.widget.tasklist.source")

local container = {}
local applist = {}

local SPACING = 8

local function get_height()
    local app_count = helpers.tablelength(favourites) + helpers.tablelength(source())
    local height = app_count * 54 - SPACING
    return dpi(height)
end

local current_height = get_height()
local previous_height = 0

local function redraw_borders()
    previous_height = current_height
    current_height = get_height()

    if previous_height ~= current_height then
        if helpers.tablelength(source()) == 0 then
            applist.spacing = dpi(0)
        else
            applist.spacing = dpi(SPACING)
        end

        container.redraw(current_height)
    end
end

local function get_custom_icon(c)
    for i, v in pairs(icons) do
        if v["class"] == string.lower(c.class) then
            return v
        end
    end

    return nil
end

local tasklist_buttons = gears.table.join(
    awful.button({}, 1, function(c)
        awesome.emit_signal("dashboard::close")
        if c ~= client.focus then
            c:jump_to(false)
        else
            --c.minimized = true
        end
    end),
    awful.button({}, 3, function()
        awful.menu.client_list({theme = { width = 250 }})
    end),
    awful.button({}, 4, function()
        awful.client.focus.byidx(1)
    end),
    awful.button({}, 5, function()
        awful.client.focus.byidx(-1)
    end)
)

local widget = awful.widget.tasklist {
    screen = screen.primary,
    filter = function() return true end, -- Filtering is already done in source
    source = source,
    buttons = tasklist_buttons,
    layout = {
        spacing = SPACING,
        layout  = wibox.layout.fixed.vertical,
    },
    widget_template = {
        get_app_widget(true),
        id = 'background_role',
        widget = wibox.container.background,
        create_callback = function(self, c, index, objects) --luacheck: no unused
            if c.active then
                self:get_children_by_id('selected_indicator')[1].bg = beautiful.base0B
            end

            local icon = get_custom_icon(c)
            if icon then
                self:get_children_by_id("custom_icon")[1].markup =
                    "<span foreground='"..icon["color"].."'>"..icon["icon"].."</span>"
                self:get_children_by_id("custom_icon")[1].visible = true
                self:get_children_by_id("default_icon")[1].visible = false
            else
                self:get_children_by_id("default_icon")[1].visible = true
                self:get_children_by_id("custom_icon")[1].visible = false
            end

            helpers.hover_pointer(self)
        end,
        update_callback = function(self, c, index, objects) --luacheck: no unused
            if c.active then
                self:get_children_by_id('selected_indicator')[1].bg = beautiful.base0B
            else
                self:get_children_by_id('selected_indicator')[1].bg = beautiful.base03
            end
        end
    }
}

client.connect_signal("manage", function(c)
    redraw_borders()
end)

client.connect_signal("unmanage", function(c)
    redraw_borders()
end)

applist = wibox.widget {
    launchers,
    widget,
    layout = wibox.layout.fixed.vertical
}

container = borders(
    wibox.widget {
        applist,
        bg = beautiful.bg_normal,
        widget = wibox.container.background
    }, dpi(53), get_height(), dpi(SPACING)
)

return container