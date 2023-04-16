--[[
    David Kosorin (kosorin) - https://github.com/kosorin
    kosorin/awesome-rice is licensed under the
    GNU General Public License v3.0
    https://github.com/kosorin/awesome-rice/blob/main/LICENSE
    (Yet another) Config for Awesome window manager.
    Complete code date: 
    03/15/2023
]]
local capi = {
    awesome = awesome,
    mousegrabber = mousegrabber,
    screen = screen,
    mouse = mouse,
}
local setmetatable = setmetatable
local ipairs = ipairs
local math = math
local dpi = require("beautiful.xresources").apply_dpi
local awful = require("awful")
local gtable = require("gears.table")
local grectangle = require("gears.geometry").rectangle
local wibox = require("wibox")
local base = require("wibox.widget.base")

local theme = require("fishlive.widget.mebox.theme.mebox_theme")
local binding = require("fishlive.io.binding")
local mod = binding.modifier
local btn = binding.button
local widget_helper = require("fishlive.helpers")
local noice = require("fishlive.widget.mebox.noice")
local fishlive = require("fishlive")

local do_not_cache = "<do-not-cache>"


local function sign(value)
    value = tonumber(value)
    if not value or value == 0 then
        return 0
    end
    return value > 0 and 1 or -1
end

local function get_screen(screen)
    return screen and capi.screen[screen]
end

local mebox = { mt = {} }

function mebox.separator(menu)
    return {
        enabled = false,
        template = menu.separator_template,
    }
end

function mebox.header(text)
    return function(menu)
        return {
            enabled = false,
            text = text,
            template = menu.header_template,
        }
    end
end

local function default_placement(menu, args)
    local border_width = menu.border_width
    local width = menu.width + 2 * border_width
    local height = menu.height + 2 * border_width
    local min_x = args.bounding_rect.x
    local min_y = args.bounding_rect.y
    local max_x = min_x + args.bounding_rect.width - width
    local max_y = min_y + args.bounding_rect.height - height

    local x, y

    if args.geometry then
        local paddings = menu.paddings
        local submenu_offset = menu.submenu_offset

        x = args.geometry.x + args.geometry.width + submenu_offset
        if x > max_x then
            x = args.geometry.x - width - submenu_offset
        end
        y = args.geometry.y - paddings.top - border_width
    else
        local coords = args.coords
        x = coords.x
        y = coords.y
    end

    menu.x = x < min_x and min_x or (x > max_x and max_x or x)
    menu.y = y < min_y and min_y or (y > max_y and max_y or y)
end

local function place(menu, args)
    args = args or {}

    local coords = args.coords or capi.mouse.coords()
    local screen = args.screen
        or awful.screen.getbycoord(coords.x, coords.y)
        or capi.mouse.screen
    screen = get_screen(screen)
    local bounds = screen:get_bounding_geometry(menu.placement_bounding_args)

    local border_width = menu.border_width
    local max_width = bounds.width - 2 * border_width
    local max_height = bounds.height - 2 * border_width
    local width, height = menu._private.layout_container:fit({
        screen = screen,
        dpi = screen.dpi,
        drawable = menu._drawable,
    }, max_width, max_height)

    menu.width = math.max(1, width)
    menu.height = math.max(1, height)

    local parent = menu._private.parent
    local placement_args = {
        geometry = parent and parent:get_item_geometry(parent.active_submenu.index),
        coords = coords,
        bounding_rect = bounds,
        screen = screen,
    }

    local placement = args.placement
        or menu.placement
        or default_placement
    placement(menu, placement_args)
end

local function get_property_value(property, item, menu)
    if item[property] ~= nil then
        return item[property]
    else
        return menu[property]
    end
end

local function get_item_template(item, menu)
    return (item and item.template) or (menu and menu.item_template)
end

local function fix_selected_item(menu, keep_selected_index)
    local actual_selected_index

    for index = 1, #menu._private.items do
        local item = menu._private.items[index]

        if keep_selected_index then
            item.selected = index == menu._private.selected_index
            if item.selected then
                actual_selected_index = index
            end
        else
            if item.selected then
                if actual_selected_index then
                    item.selected = false
                else
                    actual_selected_index = index
                end
            end
        end

        local item_widget = menu._private.item_widgets[index]
        if item_widget then
            menu:update_item(index)
        end
    end

    menu._private.selected_index = actual_selected_index
end

function mebox:get_item_geometry(index)
    local border_width = self.border_width
    local geometry = self:geometry()
    local item_widget = self._private.item_widgets[index]
    local item_geometry = item_widget and widget_helper.find_geometry(item_widget, self)
    return item_geometry and {
        x = geometry.x + item_geometry.x + border_width,
        y = geometry.y + item_geometry.y + border_width,
        width = item_geometry.width,
        height = item_geometry.height,
    }
end

function mebox:is_item_active(index)
    local item = self._private.items[index]
    return item and item.visible and item.enabled
end

function mebox:update_item(index)
    local item = self._private.items[index]
    local item_widget = self._private.item_widgets[index]
    if not item or not item_widget then
        return
    end
    local template = get_item_template(item, self)
    if type(template.update_callback) == "function" then
        template.update_callback(item_widget, item, self)
    end
end

local control = { current = setmetatable({ instance = nil }, { __mode = "v" }) }

function control.hide(menu)
    local cm = control.current
    if cm.instance == menu then
        cm.instance = nil
    end
end

function control.show(menu)
    local cm = control.current
    if cm.instance then
        return cm.instance == menu:get_root_menu()
    else
        cm.instance = menu
        return true
    end
end

local function attach_active_submenu(menu, submenu, submenu_index)
    assert(not menu._private.active_submenu)
    menu._private.active_submenu = {
        menu = submenu,
        index = submenu_index,
    }
    menu.opacity = menu.inactive_opacity or 1
    menu:unselect()
end

local function detach_active_submenu(menu)
    if menu._private.active_submenu then
        local clear_parent = true
        local submenu = menu._private.active_submenu.menu
        if menu._private.submenu_cache then
            local cached_submenu = menu._private.submenu_cache[menu._private.active_submenu.index]
            if cached_submenu ~= do_not_cache then
                assert(submenu == cached_submenu)
                clear_parent = false
            end
        end
        if clear_parent then
            submenu._private.parent = nil
        end
    end
    menu._private.active_submenu = nil
    menu.opacity = menu.active_opacity or 1
end

local function hide_active_submenu(menu)
    if menu._private.active_submenu then
        menu._private.active_submenu.menu:hide()
        detach_active_submenu(menu)
    end
end

function mebox:get_active_menu()
    local active = self
    while active._private.active_submenu do
        active = active._private.active_submenu.menu
    end
    return active
end

function mebox:get_root_menu()
    local root = self
    while root._private.parent do
        root = root._private.parent
    end
    return root
end

function mebox:show_submenu(index, context)
    context = context or {}

    if self._private.active_submenu and self._private.active_submenu.index == index then
        if context.source == "mouse" then
            hide_active_submenu(self)
        end
        return
    end

    hide_active_submenu(self)

    index = index or self._private.selected_index
    if not self:is_item_active(index) then
        return
    end

    local item = self._private.items[index]
    if not item.submenu then
        return
    end

    local submenu = self._private.submenu_cache and self._private.submenu_cache[index]
    if not submenu or submenu == do_not_cache then
        local submenu_args = type(item.submenu) == "function"
            and item.submenu(self)
            or item.submenu
        submenu = mebox.new(submenu_args, true)
        submenu._private.parent = self
        if self._private.submenu_cache then
            self._private.submenu_cache[index] = item.cache_submenu == false
                and do_not_cache
                or submenu
        end
    end

    if not submenu then
        return
    end

    attach_active_submenu(self, submenu, index)

    submenu:show(nil, context)
end

function mebox:hide_all()
    local root_menu = self:get_root_menu()
    if root_menu then
        root_menu:hide()
    end
end

function mebox:hide(context)
    if not self.visible then
        return
    end
    context = context or {}

    hide_active_submenu(self)

    local parent = self._private.parent
    if parent and parent._private.active_submenu then
        if context.source == "keyboard" or context.select_parent then
            parent:select(parent._private.active_submenu.index)
        end
        detach_active_submenu(parent)
    end

    for _, item in ipairs(self._private.items) do
        if type(item.on_hide) == "function" then
            item.on_hide(item, self)
        end
    end

    if type(self._private.on_hide) == "function" then
        self._private.on_hide(self)
    end

    if self._private.keygrabber_auto and self._private.keygrabber then
        self._private.keygrabber:stop()
    end

    self.visible = false

    self._private.layout = nil
    self._private.layout_container:set_widget(nil)
    self._private.items = nil
    self._private.item_widgets = nil
    self._private.selected_index = nil

    control.hide(self)
end

local function add_items(self, args, context)
    local items = type(self._private.items_source) == "function"
        and self._private.items_source(self, args, context)
        or self._private.items_source
    for index, item in ipairs(items) do
        if type(item) == "function" then
            item = item(self, args, context)
        end
        self._private.items[index] = item

        item.index = index
        item.selected = false

        if type(item.on_show) == "function" then
            if item.on_show(item, self, args, context) == false then
                item.visible = false
            end
        end

        item.visible = item.visible == nil or item.visible ~= false
        item.enabled = item.enabled == nil or item.enabled ~= false
        item.selected = item.selected == nil or item.selected ~= false

        if item.visible then
            local item_template = get_item_template(item, self)
            local item_widget = base.make_widget_from_value(item_template)

            local function click_action()
                self:execute(index, { source = "mouse" })
            end

            item_widget.buttons = item.buttons_builder
                and item.buttons_builder(item, self, click_action)
                or binding.awful_buttons {
                    binding.awful({}, btn.left,
                        not item.urgent and click_action,
                        item.urgent and click_action),
                }

            item_widget:connect_signal("mouse::enter", function()
                if get_property_value("mouse_move_select", item, self) then
                    self:select(index)
                end
                if get_property_value("mouse_move_show_submenu", item, self) then
                    self:show_submenu(index)
                else
                    hide_active_submenu(self)
                end
            end)

            local layout = item.layout_id
                and self._private.layout:get_children_by_id(item.layout_id)[1]
                or self._private.layout
            local layout_add = item.layout_add or layout.add
            layout_add(layout, item_widget)

            self._private.item_widgets[index] = item_widget
        else
            self._private.item_widgets[index] = false
        end
    end
end

function mebox:show(args, context)
    if self.visible then
        return
    end

    if not control.show(self) then
        return
    end

    args = args or {}
    context = context or {}

    if type(self._private.on_show) == "function" then
        if self._private.on_show(self, args, context) == false then
            return
        end
    end

    self._private.layout = base.make_widget_from_value(self._private.layout_template)
    self._private.layout_container:set_widget(self._private.layout)
    self._private.items = {}
    self._private.item_widgets = {}
    self._private.selected_index = nil

    add_items(self, args, context)

    if type(self._private.on_ready) == "function" then
        self._private.on_ready(self, args, context)
    end
    for index, item in ipairs(self._private.items) do
        if type(item.on_ready) == "function" then
            local item_widget = self._private.item_widgets[index]
            item.on_ready(item_widget, item, self, args, context)
        end
    end

    if self._private.keygrabber_auto and self._private.keygrabber then
        self._private.keygrabber:start()
    end

    self._private.selected_index = args.selected_index
    fix_selected_item(self, true)

    if self._private.selected_index == nil and context.source == "keyboard" then
        self:select_next("begin")
    end

    place(self, args)

    self.visible = true
end

function mebox:toggle(args, context)
    if self.visible then
        self:hide(context)
        return false
    else
        self:show(args, context)
        return true
    end
end

function mebox:unselect()
    local index = self._private.selected_index

    self._private.selected_index = nil

    local item = self._private.items[index]
    if item then
        item.selected = false
    end

    self:update_item(index)
end

function mebox:select(index)
    if not self:is_item_active(index) then
        return false
    end

    self:unselect()

    self._private.selected_index = index

    local item = self._private.items[index]
    if item then
        item.selected = true
    end

    self:update_item(index)
    return true
end

function mebox:execute(index, context)
    index = index or self._private.selected_index
    if not self:is_item_active(index) then
        return
    end

    context = context or {}

    local item = self._private.items[index]
    local done

    local function can_process(action)
        return done == nil
            and item[action]
            and (context.action == nil or context.action == action)
    end

    if can_process("submenu") then
        self:show_submenu(index, context)
        done = false
    end

    if can_process("callback") then
        local item_widget = self._private.item_widgets[index]
        done = item.callback(item_widget, item, self, context) ~= false
    end

    if done then
        self:hide_all()
    end
end

function mebox:select_next(direction, seek_origin)
    local count = #self._private.items
    if count < 1 then
        return
    end

    if direction == "begin" then
        seek_origin = direction
        direction = 1
    elseif direction == "end" then
        seek_origin = direction
        direction = -1
    end

    local index
    if type(seek_origin) == "number" then
        index = seek_origin
    elseif seek_origin == "begin" then
        index = 0
    elseif seek_origin == "end" then
        index = count + 1
    else
        index = self._private.selected_index or 0
    end

    direction = sign(direction)
    if direction == 0 then
        return
    end
    for _ = 1, count do
        index = index + direction
        if index < 1 then
            index = count
        elseif index > count then
            index = 1
        end

        if self:select(index) then
            return
        end
    end
end

mebox.layout_navigators = {}

function mebox.layout_navigators.direction(menu, x, y, direction, context)
    local current_region_index
    local current_region
    local boundary = {}
    local regions = {}
    local region_map = {}
    local i = 0
    for index, item_widget in ipairs(menu._private.item_widgets) do
        if menu._private.items[index].visible then
            local region = widget_helper.find_geometry(item_widget, menu)
            if region then
                i = i + 1
                regions[i] = region
                region_map[i] = index
                if index == menu._private.selected_index then
                    current_region_index = i
                    current_region = region
                end

                if not boundary.left or boundary.left > region.x then
                    boundary.left = region.x
                end
                if not boundary.top or boundary.top > region.y then
                    boundary.top = region.y
                end
                if not boundary.right or boundary.right < region.x + region.width then
                    boundary.right = region.x + region.width
                end
                if not boundary.bottom or boundary.bottom < region.y + region.height then
                    boundary.bottom = region.y + region.height
                end
            end
        end
    end

    if not current_region then
        if direction == "down" or direction == "right" then
            menu:select_next("begin")
        elseif direction == "up" or direction == "left" then
            menu:select_next("end")
        end
        return
    end

    -- TODO: Swap left/right if submenu on other side
    if direction == "left" then
        regions[#regions + 1] = {
            x = boundary.left - 2,
            y = boundary.top,
            width = 1,
            height = boundary.bottom - boundary.top,
        }
    elseif direction == "right" then
        regions[#regions + 1] = {
            x = boundary.right + 1,
            y = boundary.top,
            width = 1,
            height = boundary.bottom - boundary.top,
        }
    end

    local found = false
    repeat
        local target_region_index = grectangle.get_in_direction(direction, regions, current_region)
        if not target_region_index or target_region_index == current_region_index then
            break
        end

        local index = region_map[target_region_index]
        if index then
            found = menu:select(index)
            if not found then
                current_region_index = target_region_index
                current_region = regions[current_region_index]
            end
        elseif target_region_index > #region_map then
            if direction == "left" then
                if menu._private.parent then
                    menu:hide(context)
                end
                found = true
            elseif direction == "right" then
                menu:execute(nil, setmetatable({ action = "submenu" }, { __index = context }))
                found = true
            end
        end
    until found
end

function mebox:navigate(x, y, direction, context)
    context = context or {}
    local layout_navigator = type(self._private.layout_navigator) == "function"
        and self._private.layout_navigator
        or mebox.layout_navigators.direction
    layout_navigator(self, sign(x), sign(y), direction, context)
end

noice.define_style_properties(mebox, {
    bg = { proxy = true },
    fg = { proxy = true },
    border_color = { proxy = true },
    border_width = { proxy = true },
    shape = { proxy = true },
    paddings = { id = "#layout_container", property = "margins" },
    item_width = {},
    item_height = {},
    item_template = {},
    placement = {},
    placement_bounding_args = {},
    active_opacity = {},
    inactive_opacity = {},
    submenu_offset = {},
    separator_template = {},
    header_template = {},
})

--[[
new_args:
- (style properties)
- layout_template : widget | table | function [wibox.layout.fixed.vertical]
- layout_navigator : function(menu, x, y, navigation_context) [nil]
- cache_submenus : boolean [true]
- items_source : table<item> | function(menu, show_args, show_context) [self]
- on_show : function(menu, show_args, show_context) [nil]
- on_hide : function(menu) [nil]
- on_ready : function(menu, show_args, show_context) [nil]
- mouse_move_select : boolean [false]
- mouse_move_show_submenu : boolean [true]
- keygrabber_auto : boolean [true]
- keygrabber_builder : function(menu) [nil]
- buttons_builder : function(menu) [nil]

menu._private:
- parent : menu | nil
- active_submenu : table | nil
- submenu_cache : table<menu> | nil
- items : table<item> | nil
- item_widgets : table<widget> | nil
- selected_index : number | nil
- layout_template : widget | table | function
- layout_navigator : function(menu, x, y, navigation_context) | nil
- items_source : table<item> | function(menu, show_args, show_context)
- on_show : function(menu, show_args, show_context) | nil
- on_hide : function(menu) | nil
- on_ready : function(menu, show_args, show_context) | nil
- mouse_move_select : boolean
- mouse_move_show_submenu : boolean
- keygrabber_auto : boolean
- keygrabber : awful.keygrabber

item:
- index : number
- visible : boolean
- enabled : boolean
- selected : boolean
- mouse_move_select : boolean | nil
- mouse_move_show_submenu : boolean | nil
- cache_submenu : boolean | nil
- submenu : ctor_args | nil
- callback : function(item_widget, item, menu, execute_context) | nil
- on_show : function(item, menu, show_args, show_context) | nil
- on_hide : function(item, menu) | nil
- on_ready : function(item_widget, item, menu, show_args, show_context) | nil
- layout : string | nil
- layout_add : function(layout, item_widget) | nil
- buttons_builder : function(item, menu, default_click_action) [nil]

active_submenu:
- index : number
- menu : menu
]]
function mebox.new(args, is_submenu)
    args = args or {}

    local self = wibox {
        type = "popup_menu",
        ontop = true,
        visible = false,
        widget = {
            id = "#layout_container",
            layout = wibox.container.margin,
        },
    }

    gtable.crush(self, mebox, true)

    self._private.submenu_cache = args.cache_submenus ~= false and {} or nil
    self._private.items_source = args.items_source or args
    self._private.on_show = args.on_show
    self._private.on_hide = args.on_hide
    self._private.on_ready = args.on_ready
    self._private.mouse_move_select = args.mouse_move_select == true
    self._private.mouse_move_show_submenu = args.mouse_move_show_submenu ~= false
    self._private.layout_navigator = args.layout_navigator
    self._private.layout_template = args.layout_template or wibox.layout.fixed.vertical
    self._private.layout_container = self:get_children_by_id("#layout_container")[1]
    self._private.click_to_hide = args.click_to_hide or false

    noice.initialize_style(self, self.widget, theme.mebox.default_style)

    self:apply_style(args)

    self.buttons = type(args.buttons_builder) == "function"
        and args.buttons_builder(self)
        or binding.awful_buttons {
            binding.awful({}, btn.right, function()
                self:hide()
            end),
        }

    if not is_submenu then
        self._private.keygrabber_auto = args.keygrabber_auto ~= false
        self._private.keygrabber = type(args.keygrabber_builder) == "function"
            and args.keygrabber_builder(self)
            or awful.keygrabber {
                keybindings = binding.awful_keys {
                    binding.awful({}, {
                        { trigger = "Left", x = -1, direction = "left" },
                        { trigger = "h", x = -1, direction = "left" },
                        { trigger = "Right", x = 1, direction = "right" },
                        { trigger = "l", x = 1, direction = "right" },
                        { trigger = "Up", y = -1, direction = "up" },
                        { trigger = "k", y = -1, direction = "up" },
                        { trigger = "Down", y = 1, direction = "down" },
                        { trigger = "j", y = 1, direction = "down" },
                    }, function(trigger)
                        local active_menu = self:get_active_menu()
                        active_menu:navigate(trigger.x, trigger.y, trigger.direction, { source = "keyboard" })
                    end),
                    binding.awful({}, {
                        { trigger = "Home", direction = "begin" },
                        { trigger = "End", direction = "end" },
                    }, function(trigger)
                        local active_menu = self:get_active_menu()
                        active_menu:select_next(trigger.direction)
                    end),
                    binding.awful({}, "Tab", function()
                        local active_menu = self:get_active_menu()
                        active_menu:select_next(1)
                    end),
                    binding.awful({ mod.shift }, "Tab", function()
                        local active_menu = self:get_active_menu()
                        active_menu:select_next(-1)
                    end),
                    binding.awful({}, "Return", function()
                        local active_menu = self:get_active_menu()
                        active_menu:execute(nil, { source = "keyboard" })
                    end),
                    binding.awful({ mod.shift }, "Return", function()
                        local active_menu = self:get_active_menu()
                        active_menu:execute(nil, { source = "keyboard", action = "callback" })
                    end),
                    binding.awful({}, "Escape", function()
                        self:hide({ source = "keyboard" })
                    end),
                    binding.awful({ mod.shift }, "Escape", function()
                        local active_menu = self:get_active_menu()
                        active_menu:hide({ source = "keyboard" })
                    end),
                },
            }
    end

    if self._private.click_to_hide then
        fishlive.widget.click_to_hide(self, nil, true)
    end

    return self
end

function mebox.mt:__call(...)
    return mebox.new(...)
end

return setmetatable(mebox, mebox.mt)
