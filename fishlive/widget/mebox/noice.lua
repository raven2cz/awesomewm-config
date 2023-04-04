--[[
    David Kosorin (kosorin) - https://github.com/kosorin
    kosorin/awesome-rice is licensed under the
    GNU General Public License v3.0
    https://github.com/kosorin/awesome-rice/blob/main/LICENSE
    (Yet another) Config for Awesome window manager.
    Complete code date: 
    03/15/2023
]]
local pairs = pairs
local gtable = require("gears.table")


local noice = { object = {} }

local function get_value(self, property_name, property_descriptor)
    if property_descriptor.proxy then
        return self[property_name]
    else
        return self._style[property_name]
    end
end

local function set_value(self, property_name, property_descriptor, value)
    if property_descriptor.proxy then
        self[property_name] = value
    else
        if self._style[property_name] == value then
            return
        end
        self._style[property_name] = value
        self:emit_signal("property::" .. property_name, value)
        if property_descriptor.property then
            local widget = property_descriptor.id
                and self._style_root:get_children_by_id(property_descriptor.id)[1]
                or self._style_root
            if widget then
                widget[property_descriptor.property] = value
            end
        end
    end
end

local function update_style(self, style, allow_nil)
    style = style or self._style_default
    if style then
        for property_name, value in pairs(style) do
            if allow_nil or value ~= nil then
                self:set_style_value(property_name, value)
            end
        end
    end
end

function noice.object:apply_style(style, allow_nil)
    update_style(self, style, allow_nil)
end

function noice.object:reset_style()
    update_style(self, self._style_default, true)
end

function noice.object:set_style(style)
    update_style(self, style, false)
end

function noice.object:get_style_value(property_name)
    local property_descriptor = self._style_properties[property_name]
    if property_descriptor then
        return get_value(self, property_name, property_descriptor)
    end
end

function noice.object:set_style_value(property_name, value)
    local property_descriptor = self._style_properties[property_name]
    if property_descriptor then
        set_value(self, property_name, property_descriptor, value)
    end
end

function noice.initialize_style(instance, root, default_style)
    instance._style = {}
    instance._style_root = root
    instance._style_default = default_style

    gtable.crush(instance, noice.object, true)

    instance:reset_style()
end

function noice.define_style_properties(module, style_properties)
    module._style_properties = style_properties
    if not style_properties then
        return
    end
    for property_name, property_descriptor in pairs(module._style_properties) do
        if not property_descriptor.proxy then
            assert(not module["get_" .. property_name] and not module["set_" .. property_name],
                "Property '" .. property_name .. "' already exists.")
            module["get_" .. property_name] = function(self)
                return get_value(self, property_name, property_descriptor)
            end
            module["set_" .. property_name] = function(self, value)
                set_value(self, property_name, property_descriptor, value)
            end
        end
    end
end

return noice
