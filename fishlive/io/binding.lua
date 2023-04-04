--[[
    David Kosorin (kosorin) - https://github.com/kosorin
    kosorin/awesome-rice is licensed under the
    GNU General Public License v3.0
    https://github.com/kosorin/awesome-rice/blob/main/LICENSE
    (Yet another) Config for Awesome window manager.
    Complete code date: 
    03/15/2023
]]
local table = table
local awful = require("awful")
local gtable = require("gears.table")


local binding = {
    awesome_bindings = {},
    button = {
        left = 1,
        middle = 2,
        right = 3,
        wheel_up = 4,
        wheel_down = 5,
        wheel_left = 6,
        wheel_right = 7,
        extra_back = 8,
        extra_forward = 9,
    },
    modifier = {
        any = "Any",
        super = "Mod4",
        alt = "Mod1",
        control = "Control",
        shift = "Shift",
        alt_gr = "Mod5",
    },
    group = {
        mouse_wheel = nil,
        fkeys = {
            from = "F1",
            to = "F35",
        },
        numrow = {
            from = "#19",
            to = "#18",
        },
        numpad = {
            from = "#90",
            to = "#81",
            { trigger = "#90", number = 0 },
            { trigger = "#87", number = 1 },
            { trigger = "#88", number = 2 },
            { trigger = "#89", number = 3 },
            { trigger = "#83", number = 4 },
            { trigger = "#84", number = 5 },
            { trigger = "#85", number = 6 },
            { trigger = "#79", number = 7 },
            { trigger = "#80", number = 8 },
            { trigger = "#81", number = 9 },
        },
        arrows = {
            { trigger = "Left", direction = "left", x = -1, y = 0, },
            { trigger = "Right", direction = "right", x = 1, y = 0, },
            { trigger = "Up", direction = "up", x = 0, y = 1, },
            { trigger = "Down", direction = "down", x = 0, y = -1, },
        },
        arrows_horizontal = {
            { trigger = "Left", direction = "left", x = -1, y = 0, },
            { trigger = "Right", direction = "right", x = 1, y = 0, },
        },
        arrows_vertical = {
            { trigger = "Up", direction = "up", x = 0, y = 1, },
            { trigger = "Down", direction = "down", x = 0, y = -1, },
        },
    },
}

binding.group.mouse_wheel = {
    { trigger = binding.button.wheel_up, direction = "up", y = 1, },
    { trigger = binding.button.wheel_down, direction = "down", y = -1, },
}

for i = 1, 10 do
    table.insert(binding.group.numrow, { trigger = "#" .. i + 9, index = i, number = i == 10 and 0 or i })
end

for i = 1, 35 do
    table.insert(binding.group.fkeys, { trigger = "F" .. i, index = i })
end

local modifier_hash_data = { length = 0 }

function binding.get_modifiers_hash(modifiers)
    local hash = 0
    for _, v in ipairs(modifiers) do
        local modifier_hash = modifier_hash_data[v]
        if not modifier_hash then
            modifier_hash = 1 << modifier_hash_data.length
            modifier_hash_data[v] = modifier_hash
            modifier_hash_data.length = modifier_hash_data.length + 1
        end
        hash = hash | modifier_hash
    end
    return hash
end

local Binding = {}

local function _ensure_awful_bindings(self)
    if self._awful then
        return
    end

    self._awful = {
        keys = {},
        buttons = {},
        hooks = {},
    }

    if self.on_press or self.on_release then
        for _, trigger in ipairs(self.triggers) do
            if trigger._type == "key" then
                table.insert(self._awful.keys, awful.key {
                    modifiers = self.modifiers,
                    key = trigger.trigger,
                    description = self.description,
                    group = self.path and table.concat(self.path, "/") or nil,
                    on_press = self.on_press and function(...) self.on_press(trigger, ...) end or nil,
                    on_release = self.on_release and function(...) self.on_release(trigger, ...) end or nil,
                })
                if self.on_press then
                    table.insert(self._awful.hooks, {
                        self.modifiers,
                        trigger.trigger,
                        function(...) return self.on_press(trigger, ...) end,
                    })
                end
            elseif trigger._type == "button" then
                table.insert(self._awful.buttons, awful.button {
                    modifiers = self.modifiers,
                    button = trigger.trigger,
                    on_press = self.on_press and function(...) self.on_press(trigger, ...) end or nil,
                    on_release = self.on_release and function(...) self.on_release(trigger, ...) end or nil,
                })
            end
        end
    end
end

local last_order = 0

local trigger_types = {
    string = "key",
    number = "button",
}

function binding.new(args)
    local self = {
        on_press = args.on_press,
        on_release = args.on_release,
        modifiers = args.modifiers or {},
        triggers = {},
        path = type(args.path) == "string" and { args.path } or args.path,
        description = args.description,
        text = args.text,
        from = args.from,
        to = args.to,
        target = args.target,
        order = args.order,
    }

    if not self.order then
        self.order = last_order + 1
    end
    last_order = self.order

    local triggers = args.triggers or args

    local function add_trigger(trigger)
        local trigger_type = trigger_types[type(trigger.trigger)]
        if trigger_type then
            trigger._type = trigger_type
            table.insert(self.triggers, trigger)
        end
    end

    if type(triggers) == "table" then
        self.text = triggers.text
        self.from = triggers.from
        self.to = triggers.to
        for _, trigger in ipairs(triggers) do
            if type(trigger) == "table" then
                add_trigger(trigger)
            else
                add_trigger({ trigger = trigger })
            end
        end
    else
        add_trigger({ trigger = triggers })
    end

    return setmetatable(self, { __index = Binding })
end

function binding.add_global(b)
    table.insert(binding.awesome_bindings, b)
    _ensure_awful_bindings(b)
    awful.keyboard.append_global_keybindings(b._awful.keys)
    awful.mouse.append_global_mousebindings(b._awful.buttons)
    return b
end

function binding.add_client(b)
    table.insert(binding.awesome_bindings, b)
    _ensure_awful_bindings(b)
    awful.keyboard.append_client_keybindings(b._awful.keys)
    awful.mouse.append_client_mousebindings(b._awful.buttons)
    return b
end

function binding.add_global_range(bindings)
    for _, b in ipairs(bindings) do
        binding.add_global(b)
    end
end

function binding.add_client_range(bindings)
    for _, b in ipairs(bindings) do
        binding.add_client(b)
    end
end

function binding.awful(modifiers, triggers, on_press, on_release, args)
    if type(on_release) == 'table' then
        args = on_release
        on_release = nil
    end
    return binding.new(gtable.crush({
        on_press = on_press,
        on_release = on_release,
        modifiers = modifiers,
        triggers = triggers,
    }, args or {}))
end

function binding.awful_keys(bindings)
    return gtable.join(table.unpack(gtable.map(function(b)
        _ensure_awful_bindings(b)
        return b._awful.keys
    end, bindings)))
end

function binding.awful_buttons(bindings)
    return gtable.join(table.unpack(gtable.map(function(b)
        _ensure_awful_bindings(b)
        return b._awful.buttons
    end, bindings)))
end

function binding.awful_hooks(bindings)
    return gtable.join(table.unpack(gtable.map(function(b)
        _ensure_awful_bindings(b)
        return b._awful.hooks
    end, bindings)))
end

function binding.require()
    return binding, binding.modifier, binding.button
end

return binding
