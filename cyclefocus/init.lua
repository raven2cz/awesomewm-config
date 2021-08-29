--- Cycle through recently focused clients (Alt-Tab and more).
--
-- Author: http://daniel.hahler.de
-- Github: https://github.com/blueyed/awesome-cyclefocus

local awful        = require('awful')
-- local setmetatable = setmetatable
local naughty      = require("naughty")
local table        = table
local tostring     = tostring
local floor        = require("math").floor
local capi         = {
--     tag            = tag,
    client         = client,
    keygrabber     = keygrabber,
--     mousegrabber   = mousegrabber,
    mouse          = mouse,
    screen         = screen,
    awesome        = awesome,
}
local wibox        = require("wibox")

local xresources = require("beautiful").xresources
local dpi = xresources and xresources.apply_dpi or function() end

--- Escape pango markup, taken from naughty.
local escape_markup = function(s)
    local escape_pattern = "[<>&]"
    local escape_subs = { ['<'] = "&lt;", ['>'] = "&gt;", ['&'] = "&amp;" }
    return s:gsub(escape_pattern, escape_subs)
end


-- Configuration. This can be overridden: global or via args to cyclefocus.cycle.
local cyclefocus
cyclefocus = {
    -- Should clients get shown during cycling?
    -- This should be a function (or `false` to disable showing clients), which
    -- receives a client object, and can make use of `cyclefocus.show_client`
    -- (the default implementation).
    show_clients = true,
    -- Should clients get focused during cycling?
    -- This is required for the tasklist to highlight the selected entry.
    focus_clients = true,
    -- Should the selected client get raised?
    -- This calls `cyclefocus.raise_client_without_focus` by default, which you
    -- can use when overriding this with a function (that gets the client as
    -- argument).
    raise_client = true,
    -- Should the mouse pointer be moved away during cycling?
    -- This is normally done to avoid interference from sloppy focus handling,
    -- but can be disabled if you do not use sloppy focus.
    move_mouse_pointer = true,

    -- How many entries should get displayed before and after the current one?
    display_next_count = 3,
    display_prev_count = 3,

    -- Default preset to use for entries.
    -- `preset_for_offset` (below) gets added to it.
    default_preset = {},

    --- Templates for entries in the list.
    -- The following arguments get passed to a callback:
    --  - client: the current client object.
    --  - idx: index number of current entry in clients list.
    --  - displayed_list: the list of entries in the list, possibly filtered.
    preset_for_offset = {
        -- Default callback, which will gets applied for all offsets (first).
        default = function (preset, args)
            -- Default font and icon size (gets overwritten for current/0 index).
            preset.font = 'sans 8'
            preset.icon_size = dpi(24)
            preset.text = escape_markup(cyclefocus.get_client_title(args.client, false))
        end,

        -- Preset for current entry.
        ["0"] = function (preset, args)
            preset.font = 'sans 14'
            preset.icon_size = dpi(36)
            preset.text = escape_markup(cyclefocus.get_client_title(args.client, true))
            -- Add screen number if there is more than one.
            if screen.count() > 1 then
                preset.text = preset.text .. " [screen " .. tostring(args.client.screen.index) .. "]"
            end
            preset.text = preset.text .. " [#" .. args.idx .. "] "
            preset.text = '<b>' .. preset.text .. '</b>'
        end,

        -- You can refer to entries by their offset.
        -- ["-1"] = function (preset, args)
        --     -- preset.icon_size = 32
        -- end,
        -- ["1"] = function (preset, args)
        --     -- preset.icon_size = 32
        -- end
    },

    -- Default builtin filters.
    -- (meant to get applied always, but you could override them)
    cycle_filters = {
        function(c, source_c) return not c.minimized end,  --luacheck: no unused args
    },

    -- Experimental: Width of icon column ("max_icon_size", used for margin).
    -- This could be "margin" etc instead, but currently only the width for the
    -- current entry is known.
    icon_col_width = dpi(36),

    -- EXPERIMENTAL: only add clients to the history that have been focused by
    -- cyclefocus.
    -- This allows to switch clients using other methods, but those are then
    -- not added to cyclefocus' internal history.
    -- The get_next_client function will then first consider the most recent
    -- entry in the history stack, if it's not focused currently.
    --
    -- You can use cyclefocus.history.add to manually add an entry, or
    -- cyclefocus.history.append if you want to add it to the end of the stack.
    -- This might be useful in a request::activate signal handler.
    -- XXX: needs to be also handled in request::activate then probably.
    -- TODO: make this configurable during runtime of the binding, e.g. by
    --       flagging entries in the stack or using different stacks.
    -- only_add_internal_focus_changes_to_history = true,

    -- The filter to ignore clients altogether (get not added to the history stack).
    -- This is different from the cycle_filters.
    -- The function should return true / the client if it's ok, nil otherwise.
    filter_focus_history = awful.client.focus.filter,

    -- Display notifications while cycling?
    -- WARNING: without raise_clients this will not make sense probably!
    display_notifications = true,

    -- Debugging: messages get printed, and should show up in ~/.xsession-errors etc.
    -- 1: enable, 2: verbose, 3: very verbose, 4: much verbose.
    debug_level = 0,
    -- Use naughty notifications for debugging (additional to printing)?
    debug_use_naughty_notify = false,
}


-- Wrap icon widget with margin.
local get_icon_wrapper_widget = function(w, preset)
    local icon_margin = preset.icon_margin or dpi(5)
    local icon_center_margin = icon_margin + math.max(0, (cyclefocus.icon_col_width - preset.icon_size)/2)
    local iconmarginbox = wibox.container.margin(w)
    iconmarginbox:set_left(icon_center_margin)
    iconmarginbox:set_right(icon_center_margin)
    iconmarginbox:set_top(icon_margin)
    iconmarginbox:set_bottom(icon_margin)
    return iconmarginbox
end

-- Get widget for client icon.  Uses awful.widget.clienticon if available.
if awful.widget.clienticon then
    cyclefocus.get_client_icon_widget = function(c, preset)
        local w = awful.widget.clienticon(c)
        w:set_forced_width(preset.icon_size)
        w:set_forced_height(preset.icon_size)
        return get_icon_wrapper_widget(w, preset)
    end
else
    local has_gears, gears = pcall(require, 'gears')
    local icon_loader
    if has_gears then
        -- Use gears to prevent memory leaking.
        icon_loader = gears.surface.load
    else
        icon_loader = function(icon) return icon end
    end

    cyclefocus.get_client_icon_widget = function(c, preset)
        if not c.icon then
            return
        end
        local icon = icon_loader(c.icon)
        local icon_size = preset.icon_size

        -- Code originally via naughty.
        local cairo = require("lgi").cairo
        local scaled = cairo.ImageSurface(cairo.Format.ARGB32, icon_size, icon_size)
        local cr = cairo.Context(scaled)
        cr:scale(preset.icon_size / icon:get_height(), preset.icon_size / icon:get_width())
        cr:set_source_surface(icon, 0, 0)
        cr:paint()
        icon = scaled

        local iconbox = wibox.widget.imagebox()
        iconbox:set_resize(false)
        iconbox:set_image(icon)
        return get_icon_wrapper_widget(iconbox, preset)
    end
end

-- A set of default filters, which can be used for cyclefocus.cycle_filters.
cyclefocus.filters = {
    -- Filter clients on the same screen.
    same_screen = function (c, source_c)
        return (c.screen or capi.mouse.screen) == source_c.screen
    end,

    same_class = function (c, source_c)
        return c.class == source_c.class
    end,

    -- Only marked clients (via awful.client.mark and .unmark).
    marked = function (c, source_c)  --luacheck: no unused args
        return awful.client.ismarked(c)
    end,

    common_tag  = function (c, source_c)
        if c == source_c then
            return true
        end
        cyclefocus.debug("common_tag_filter\n"
            .. cyclefocus.get_object_name(c) .. " <=> " .. cyclefocus.get_object_name(source_c), 3)
        for _, t in pairs(c:tags()) do
            for _, t2 in pairs(source_c:tags()) do
                if t == t2 then
                    cyclefocus.debug('common_tag_filter: client shares tag "'
                        .. cyclefocus.get_object_name(t)
                        .. '" with "' .. cyclefocus.get_object_name(c)..'"', 2)
                    return true
                end
            end
        end
        return false
    end,

    -- EXPERIMENTAL:
    -- Skip clients that were added through "focus" signal.
    -- Replaces only_add_internal_focus_changes_to_history.
    not_through_focus_signal = function (c, source_c)  --luacheck: no unused args
        local attribs = cyclefocus.history.attribs(c)
        return not attribs.source or attribs.source ~= "focus"
    end,
}

local ignore_focus_signal = false  -- Flag to ignore the focus signal internally.
local showing_client

-- This can be used in signal handlers to e.g. skip changing border_width.
cyclefocus.get_shown_client = function()
    return showing_client
end

-- Debug function. Set focusstyle.debug to activate it. {{{
cyclefocus.debug = function(msg, level)
    level = level or 1
    if not cyclefocus.debug_level or cyclefocus.debug_level < level then
        return
    end

    if cyclefocus.debug_use_naughty_notify then
        naughty.notify({
            -- TODO: use indenting
            -- text = tostring(msg)..' ['..tostring(level)..']',
            text = tostring(msg),
            timeout = 10,
        })
    end
    print("cyclefocus: " .. msg)
end

local get_object_name = function (o)
    if not o then
        return '[no object]'
    elseif not o.valid then
        return '[invalid object]'
    elseif not o.name then
        return '[no object name]'
    else
        return o.name
    end
end
cyclefocus.get_object_name = get_object_name

local utf8_truncate = function (s, length)
    if length == 0 then
        return s
    end
    local n = 0
    for i = 1, s:len() do
        local b = s:byte(i)
        if b < 0x80 or b >= 0xc0 then
            n = n + 1
            if n > length then
                return s:sub(1, i - 1) .. '…'
            end
        end
    end
    return s
end

cyclefocus.get_client_title = function (c, current)  --luacheck: no unused args
    -- Use get_object_name to handle .name=nil.
    local title = cyclefocus.get_object_name(c)
    return utf8_truncate(title, 80)
end
-- }}}


-- Internal functions to handle the focus history. {{{
-- Based on awful.client.focus.history.
local history = {
    stack = {}
}

--- Remove a client from the history stack.
-- @tparam table Client.
function history.delete(c)
    local k = history._get_key(c)
    if k then
        table.remove(history.stack, k)
    end
end

function history._get_key(c)
    for k, v in ipairs(history.stack) do
        if v[1] == c then
            return k
        end
    end
end

function history.attribs(c)
    local k = history._get_key(c)
    if k then
        return history.stack[k][2]
    end
end

function history.clear()
    history.stack = {}
end

-- @param filter: a function / boolean to filter clients: true means to add it.
function history.add(c, filter, append, attribs)
    filter = filter or cyclefocus.filter_focus_history
    append = append or false
    attribs = attribs or {}

    -- Less verbose debugging during startup/restart.
    cyclefocus.debug("history.add: " .. get_object_name(c), capi.awesome.startup and 4 or 2)

    if filter and type(filter) == "function" then
        if not filter(c) then
            cyclefocus.debug("Filtered! " .. get_object_name(c), 2)
            return true
        end
    end

    -- Remove any existing entries from the stack.
    history.delete(c)

    if append then
        table.insert(history.stack, {c, attribs})
    else
        table.insert(history.stack, 1, {c, attribs})
    end

    -- Manually add it to awesome's internal history (where we've removed the
    -- signal from).
    awful.client.focus.history.add(c)
end

function history.movetotop(c)
    local attribs = history.attribs(c)
    history.add(c, true, false, attribs)
end

function history.append(c, filter, attribs)
    return history.add(c, filter, true, attribs)
end

--- Save the history into a X property.
function history.persist()
    local ids = {}
    for _, v in ipairs(history.stack) do
        table.insert(ids, v[1].window)
    end
    local xprop = table.concat(ids, " ")
    capi.awesome.set_xproperty('awesome.cyclefocus.history', xprop)
end

--- Load history from the X property.
function history.load()
    local xprop = capi.awesome.get_xproperty('awesome.cyclefocus.history')
    if not xprop or xprop == "" then
        return
    end

    local cls = capi.client.get()
    local ids = {}
    for id in string.gmatch(xprop, "%S+") do
        table.insert(ids, 1, id)
    end
    for _,window in ipairs(ids) do
        for _,c in pairs(cls) do
            if tonumber(window) == c.window then
                history.add(c, true, false, {source="load"})
                break
            end
        end
    end
end

-- Persist history when restarting awesome.
capi.awesome.register_xproperty('awesome.cyclefocus.history', 'string')
capi.awesome.connect_signal("exit", function(restarting)
    ignore_focus_signal = true
    if restarting then
        history.persist()
    end
end)

-- On startup / restart: load the history and jump to the last focused client.
cyclefocus.load_on_startup = function()
    capi.awesome.disconnect_signal("refresh", cyclefocus.load_on_startup)

    ignore_focus_signal = true
    history.load()
    if history.stack[1] then
        showing_client = history.stack[1][1]
        showing_client:jump_to()
        showing_client = nil
    end
    ignore_focus_signal = false
end
capi.awesome.connect_signal("refresh", cyclefocus.load_on_startup)

-- Export it. At least history.add should be.
cyclefocus.history = history
-- }}}

-- Connect to signals. {{{
-- Add clients that got focused to the history stack,
-- but not when we are cycling through the clients ourselves.
capi.client.connect_signal("focus", function (c)
    if ignore_focus_signal or capi.awesome.startup then
        cyclefocus.debug("Ignoring focus signal: " .. get_object_name(c), 4)
        return
    end
    history.add(c, nil, nil, {source="focus"})
end)

-- Disable awesome's internal history handler to handle `ignore_focus_signal`.
-- https://github.com/awesomeWM/awesome/pull/906.
if awful.client.focus.history.disable_tracking then
    awful.client.focus.history.disable_tracking()
else
    capi.client.disconnect_signal("focus", awful.client.focus.history.add)
end

capi.client.connect_signal("manage", function (c)
    if ignore_focus_signal then
        cyclefocus.debug("Ignoring focus signal (manage): " .. get_object_name(c), 2)
        return
    end

    -- During startup: append any clients, to make them known,
    -- but not override history.load etc.
    if capi.awesome.startup then
        history.append(c)
    else
        history.add(c, nil, false, {source="manage"})
    end
end)

capi.client.connect_signal("unmanage", function (c)
    history.delete(c)
end)
-- }}}

-- Raise a client (does not include focusing).
-- Default implementation for raise_client option.
-- NOTE: awful.client.jumpto also focuses the screen / resets the mouse.
-- See https://github.com/blueyed/awesome-cyclefocus/issues/6
-- Based on awful.client.jumpto, without the code for mouse.
-- Calls tag:viewonly always to update the tag history, also when
-- the client is visible.
cyclefocus.raise_client_without_focus = function(c)
    -- Try to make client visible, this also covers e.g. sticky
    local t = c:tags()[1]
    if t then
        t:view_only()
    end
    c:jump_to()
end


local restore_callback_show_client
local show_client_restore_client_props = {}
client.connect_signal("unmanage", function (c)
    if c == restore_callback_show_client then
        restore_callback_show_client = nil
    end
    if c == showing_client then
        showing_client = nil
    end

    if show_client_restore_client_props[c] then
        show_client_restore_client_props[c] = nil
    end
end)


local beautiful = require("beautiful")

--- Callback to get properties for clients that are shown during cycling.
-- @client c
-- @return table
cyclefocus.decorate_show_client = function(c)
    return {
        -- border_color = beautiful.fg_focus,
        border_color = beautiful.border_focus,
        border_width = c.border_width or 1,
        -- XXX: changes layout / triggers resizes.
        -- border_width = 10,
    }
end
--- Callback to get properties for other clients that are visible during cycling.
-- @client c
-- @return table
cyclefocus.decorate_show_client_others = function(c)  --luacheck: no unused args
    return {
        -- XXX: too distracting.
        -- opacity = 0.7
    }
end

local show_client_apply_props = {}

local show_client_apply_props_others = {}
local show_client_restore_client_props_others = {}

local callback_show_client_lock
local decorate_if_showing_client = function (c)
    if c == showing_client then
        cyclefocus.callback_show_client(c)
    end
end
-- A table with property callbacks.  Could be merged with decorate_if_showing_client.
local update_show_client_restore_client_props = {}
--- Callback when a client gets shown during cycling.
-- This can be overridden itself, but it's meant to be configured through
-- decorate_show_client instead.
-- @client c
-- @param boolean Restore the previous state?
cyclefocus.callback_show_client = function (c, restore)
    if callback_show_client_lock then return end
    callback_show_client_lock = true

    if restore then
        -- Restore all saved properties.
        if show_client_restore_client_props[c] then
            -- Disconnect signals.
            for k,_ in pairs(show_client_restore_client_props[c]) do
                client.disconnect_signal("property::" .. k, decorate_if_showing_client)
                client.disconnect_signal("property::" .. k, update_show_client_restore_client_props[c][k])
            end

            for k,v in pairs(show_client_restore_client_props[c]) do
                c[k] = v
            end

            -- Restore properties for other clients.
            for _c,props in pairs(show_client_restore_client_props_others[c]) do
                for k,v in pairs(props) do
                    -- XXX: might have an "invalid object" here!
                    _c[k] = v
                end
            end

            show_client_apply_props[c] = nil
            show_client_restore_client_props[c] = nil
            show_client_restore_client_props_others[c] = nil
        end
    else
        -- Save orig settings on first call.
        local first_call = not show_client_restore_client_props[c]
        if first_call then
            show_client_restore_client_props[c] = {}
            show_client_apply_props[c] = {}

            -- Get props to apply and store original values.
            show_client_apply_props[c] = cyclefocus.decorate_show_client(c)
            update_show_client_restore_client_props[c] = {}
            for k,_ in pairs(show_client_apply_props[c]) do
                show_client_restore_client_props[c][k] = c[k]
            end

            -- Get props for other clients and store original values.
            -- TODO: handle all screens?!
            show_client_apply_props_others[c] = cyclefocus.decorate_show_client_others(c)
            show_client_restore_client_props_others[c] = {}
            for s in capi.screen do
                for _,_c in pairs(awful.client.visible(s)) do
                    if _c ~= c then
                        show_client_restore_client_props_others[c][_c] = {}
                        for k,_ in pairs(show_client_apply_props_others[c]) do
                            show_client_restore_client_props_others[c][_c][k] = _c[k]
                        end
                    end
                end
            end
        end
        -- Apply props from callback.
        for k,v in pairs(show_client_apply_props[c]) do
            c[k] = v
        end
        -- Apply props for other clients.
        for _c,_ in pairs(show_client_restore_client_props_others[c]) do
            for k,v in pairs(show_client_apply_props_others[c]) do
                _c[k] = v  -- see: XXX_1
            end
        end

        if first_call then
            for k,_ in pairs(show_client_apply_props[c]) do
                client.connect_signal("property::" .. k, decorate_if_showing_client)

                -- Update client props to be restored during showing a client,
                -- e.g. border_color from focus signals.
                update_show_client_restore_client_props[c][k] = function()
                    if c.valid then
                        show_client_restore_client_props[c][k] = c[k]
                    end
                end
                client.connect_signal("property::" .. k, update_show_client_restore_client_props[c][k])
            end
            -- TODO: merge with above; also disconnect on restore.
            -- for k,v in pairs(show_client_apply_props_others[c]) do
            --     client.connect_signal("property::" .. k, decorate_if_showing_client)
            -- end
        end
    end

    callback_show_client_lock = false
end

-- Handle temporarily setting "ontop" for shown clients.
-- This is a function that keeps track and handles the related "below",
-- "above", and "fullscreen" properties.
-- Ref: https://github.com/awesomeWM/awesome/issues/667
local restore_ontop_c

-- Helper function to restore state of the temporarily selected client.
cyclefocus.show_client = function (c)
    showing_client = c

    if c then
        if restore_callback_show_client then
            cyclefocus.callback_show_client(restore_callback_show_client, true)
        end
        restore_callback_show_client = c

        -- Restore ontop (and related) properties.
        if restore_ontop_c then
            restore_ontop_c()
            restore_ontop_c = nil
        end

        -- Handle setting ontop for the current client.
        -- This involves managing other properties, since setting "ontop"
        -- resets "fullscreen", "below", and "above".
        if not c.ontop then
            if c.fullscreen then
                -- Keep fullscreen clients as is.
                -- This requires to temporarily unset ontop for others.
                -- NOTE: the client might not be visible with other ontop clients
                --       after selecting it.  This could be handled by setting
                --       ontop in the end (unsetting its fullscreen then though).
                local ontop_restore_clients = {}
                for _,_c in pairs(awful.client.visible(client.screen)) do
                    if _c.ontop then
                        table.insert(ontop_restore_clients, _c)
                        _c.ontop = false
                    end
                end
                if #ontop_restore_clients then
                    function restore_ontop_c()
                        for _,_c in pairs(ontop_restore_clients) do
                            if _c.valid then
                                _c.ontop = true
                            end
                        end
                    end
                end
            else
                local ontop_orig_props = {c.ontop, c.below, c.above, c.fullscreen}
                function restore_ontop_c()
                    if c.valid then
                        c.ontop = ontop_orig_props[1]
                        c.below = ontop_orig_props[2]
                        c.above = ontop_orig_props[3]
                        c.fullscreen = ontop_orig_props[4]
                    end
                end
                c.ontop = true
            end
        end

        -- Make the clients tag visible, if it currently is not.
        local sel_tags = c.screen.selected_tags
        local c_tag = c.first_tag or c:tags()[1]
        if c_tag and not awful.util.table.hasitem(sel_tags, c_tag) then
            -- Select only the client's first tag, after de-selecting
            -- all others.

            -- Make the client sticky temporarily, so it will be
            -- considered visbile internally.
            -- NOTE: this is done for client_maybevisible (used by autofocus).
            local restore_sticky = c.sticky
            c.sticky = true

            for _, t in pairs(c.screen.tags) do
                if t ~= c_tag then
                    t.selected = false
                end
            end
            c_tag.selected = true

            -- Restore.
            c.sticky = restore_sticky
        end
        cyclefocus.callback_show_client(c, false)

    else  -- No client provided, restore only.
        if restore_ontop_c then
            restore_ontop_c()
            restore_ontop_c = nil
        end
        cyclefocus.callback_show_client(restore_callback_show_client, true)
        showing_client = nil
    end
end

--- Cached main wibox.
local wbox
local wbox_screen
local layout

-- Main function.
cyclefocus.cycle = function(startdirection_or_args, args)
    if type(startdirection_or_args) == 'number' then
        awful.util.deprecate('startdirection is not used anymore: pass in args only', {raw=true})
    else
        args = startdirection_or_args
    end
    args = awful.util.table.join(awful.util.table.clone(cyclefocus), args)
    -- The key name of the (last) modifier: this gets used for the "release" event.
    local modifier = args.modifier or 'Alt_L'
    local keys = args.keys or {'Tab', 'ISO_Left_Tab'}
    local shift = args.shift or 'Shift'
    -- cycle_filters: merge with defaults from module.
    local cycle_filters = awful.util.table.join(args.cycle_filters or {},
        cyclefocus.cycle_filters)

    -- Use "Escape" as exit_key if not used as key.
    local exit_key = args.exit_key
    if exit_key == nil then
        for _,key in pairs({'Escape', 'q'}) do
            if not awful.util.table.hasitem(keys, key) then
                exit_key = key
                break
            end
        end
    end

    -- Not documented.
    local get_client_icon_widget = args.get_client_icon_widget

    local filter_result_cache = {}     -- Holds cached filter results.

    local show_clients = args.show_clients
    if show_clients and type(show_clients) ~= 'function' then
        show_clients = cyclefocus.show_client
    end

    local raise_client_fn = args.raise_client
    if raise_client_fn and type(raise_client_fn) ~= 'function' then
        raise_client_fn = cyclefocus.raise_client_without_focus
    end

    -- Support single filter.
    if args.cycle_filter then
        cycle_filters = awful.util.table.clone(cycle_filters)
        table.insert(cycle_filters, args.cycle_filter)
    end

    -- Set flag to ignore any focus events while cycling through clients.
    ignore_focus_signal = true

    -- Internal state.
    local initiating_client = args.initiating_client or capi.client.focus  -- Will be jumped to via Escape (abort).

    -- Save list of selected tags for all screens.
    local restore_tag_selected = {}
    for s in capi.screen do
        restore_tag_selected[s] = {}
        for _,t in pairs(s.tags) do
            restore_tag_selected[s][t] = t.selected
        end
    end

    --- Helper function to get the next client.
    -- @param direction 1 (forward) or -1 (backward).
    -- @param idx Current index in the stack.
    -- @param stack Current stack (default: history.stack).
    -- @param consider_cur_idx Also look at the current idx, and consider it
    --                         when it's not focused.
    -- @return client or nil and current index in stack.
    local get_next_client = function(direction, idx, stack, consider_cur_idx)
        local startidx = idx
        stack = stack or history.stack
        consider_cur_idx = consider_cur_idx or args.focus_clients

        local nextc

        cyclefocus.debug('get_next_client: #' .. idx .. ", dir=" .. direction
            .. ", start=" .. startidx .. ", consider_cur=" .. tostring(consider_cur_idx), 2)

        local n = #stack
        if consider_cur_idx then
            local c_top = stack[idx][1]
            if c_top ~= capi.client.focus then
                n = n+1
                cyclefocus.debug("Considering nextc from top of stack: " .. tostring(c_top), 2)
            else
                consider_cur_idx = false
            end
        end
        for loop_stack_i = 1, n do
            if not consider_cur_idx or loop_stack_i ~= 1 then
                idx = idx + direction
                if idx < 1 then
                    idx = #stack
                elseif idx > #stack then
                    idx = 1
                end
            end
            cyclefocus.debug('find loop: #' .. idx .. ", dir=" .. direction, 3)
            nextc = stack[idx][1]

            if nextc then
                -- Filtering.
                if cycle_filters then
                    -- Get and init filter cache data structure. {{{
                    -- TODO: move function(s) up?
                    local get_cached_filter_result = function(f, a, b)
                        b = b or false  -- handle nil
                        if filter_result_cache[f] == nil then
                            filter_result_cache[f] = { [a] = { [b] = { } } }
                            return nil
                        elseif filter_result_cache[f][a] == nil then
                            filter_result_cache[f][a] = { [b] = { } }
                            return nil
                        elseif filter_result_cache[f][a][b] == nil then
                            return nil
                        end
                        return filter_result_cache[f][a][b]
                    end
                    local set_cached_filter_result = function(f, a, b, value)
                        b = b or false  -- handle nil
                        get_cached_filter_result(f, a, b)  -- init
                        filter_result_cache[f][a][b] = value
                    end -- }}}

                    -- Apply filters, while looking up cache.
                    local filter_result
                    for _k, filter in pairs(cycle_filters) do
                        cyclefocus.debug("Checking filter ".._k.."/"..#cycle_filters..": "..tostring(filter), 4)
                        filter_result = get_cached_filter_result(filter, nextc, initiating_client)
                        if filter_result ~= nil then
                            if not filter_result then
                                nextc = false
                                break
                            end
                        else
                            filter_result = filter(nextc, initiating_client)
                            set_cached_filter_result(filter, nextc, initiating_client, filter_result)
                            if not filter_result then
                                cyclefocus.debug("Filtering/skipping client: " .. get_object_name(nextc), 3)
                                nextc = false
                                break
                            end
                        end
                    end
                end
                if nextc then
                    -- Found client to switch to.
                    break
                end
            end
        end
        cyclefocus.debug("get_next_client returns: " .. get_object_name(nextc) .. ', idx=' .. idx, 1)
        return nextc, idx
    end

    local first_run = true
    local nextc
    local idx = 1  -- Currently focused client in the stack.

    -- Get the screen before moving the mouse.
    local initial_screen = awful.screen.focused and awful.screen.focused() or mouse.screen

    -- Move mouse pointer away to avoid sloppy focus kicking in.
    local restore_mouse_coords
    if show_clients and args.move_mouse_pointer then
        local s = capi.screen[capi.mouse.screen]
        local coords = capi.mouse.coords()
        restore_mouse_coords = {s = s, x = coords.x, y = coords.y}
        local pos = {x = s.geometry.x, y = s.geometry.y}
        -- move cursor without triggering signals mouse::enter and mouse::leave
        capi.mouse.coords(pos, true)
        restore_mouse_coords.moved = pos
    end

    capi.keygrabber.run(function(mod, key, event)
        -- Helper function to exit out of the keygrabber.
        -- If a client is given, it will be jumped to.
        local exit_grabber = function(c)
            cyclefocus.debug("exit_grabber: " .. get_object_name(c), 2)
            if wbox then
                wbox.visible = false
            end
            capi.keygrabber.stop()

            -- Restore.
            if show_clients then
                show_clients()
            end

            -- Restore previously selected tags for screen(s).
            -- With a given client, handle other screens first, otherwise
            -- the focus might be on the wrong screen.
            if restore_tag_selected then
                for s in capi.screen do
                    if not c or s ~= c.screen then
                        for _,t in pairs(s.tags) do
                            t.selected = restore_tag_selected[s][t]
                        end
                    end
                end
            end

            -- Restore mouse if it has not been moved during cycling.
            if restore_mouse_coords then
                if restore_mouse_coords.s == capi.screen[capi.mouse.screen] then
                  local coords = capi.mouse.coords()
                  local moved_coords = restore_mouse_coords.moved
                  if moved_coords.x == coords.x and moved_coords.y == coords.y then
                      capi.mouse.coords({x = restore_mouse_coords.x, y = restore_mouse_coords.y}, true)
                  end
                end
            end

            if c then
                showing_client = c
                raise_client_fn(c)
                if c ~= initiating_client then
                    history.movetotop(c)
                end
                showing_client = nil
            end
            ignore_focus_signal = false

            return true
        end

        cyclefocus.debug("grabber: mod: " .. table.concat(mod, ',')
            .. ", key: " .. tostring(key)
            .. ", event: " .. tostring(event)
            .. ", modifier_key: " .. tostring(modifier), 3)

        if exit_key and key == exit_key then
            return exit_grabber(initiating_client)
        elseif #mod == 1 and mod[1] == 'Control' and key == 'c' then
            -- exit on Ctrl-C always.
            return exit_grabber(initiating_client)
        end

        -- Direction (forward/backward) is determined by status of shift.
        local direction = awful.util.table.hasitem(mod, shift) and -1 or 1

        if event == "release" and key == modifier then
            -- Focus selected client when releasing modifier.
            -- When coming here on first run, the trigger was pressed quick and
            -- we need to fetch the next client while exiting.
            if first_run then
                nextc, idx = get_next_client(direction, idx)
            end
            if show_clients then
                show_clients(nextc)
            end
            return exit_grabber(nextc)
        end

        -- Ignore any "release" events and unexpected keys, except for the first run.
        if not first_run then
            if not awful.util.table.hasitem(keys, key) then
                cyclefocus.debug("Ignoring unexpected key: " .. tostring(key), 1)
                return true
            end
            if event == "release" then
                return true
            end
        end
        first_run = false

        nextc, idx = get_next_client(direction, idx)
        if not nextc then
            return exit_grabber()
        end

        -- Show the client, which triggers setup of restore_callback_show_client etc.
        if show_clients then
            show_clients(nextc)
        end
        -- Focus client.
        if args.focus_clients then
            capi.client.focus = nextc
        end

        if not args.display_notifications then
            return true
        end

        local container_margin_top_bottom = dpi(5)
        local container_margin_left_right = dpi(5)
        if not wbox then
            wbox = wibox({ontop = true })
            wbox._for_screen = mouse.screen
            wbox:set_fg(beautiful.fg_normal)
            wbox:set_bg("#ffffff00")

            local container_inner = wibox.layout.align.vertical()
            local container_layout = wibox.container.margin(
                container_inner,
                container_margin_left_right, container_margin_left_right,
                container_margin_top_bottom, container_margin_top_bottom)
            container_layout = wibox.container.background(container_layout)
            container_layout:set_bg(beautiful.bg_normal..'cc')

            wbox:set_widget(container_layout)
            -- "fixed" appears to work better for when there are no icons to
            -- prevent cropping of the text.
            layout = wibox.layout.fixed.vertical()
            container_inner:set_middle(layout)
        else
            layout:reset()
        end

        -- Set geometry always, the screen might have changed.
        if not wbox_screen or wbox_screen ~= initial_screen then
            wbox_screen = initial_screen
            local wa = screen[wbox_screen].workarea
            local w = math.ceil(wa.width * 0.618)
            wbox:geometry({
                -- right-align.
                x = math.ceil(wa.x + wa.width - w),
                width = w,
            })
        end
        local wbox_height = 0

        -- Create entry with index, name and screen.
        local display_entry_for_idx_offset = function(offset, c, _idx, displayed_list)  -- {{{
            local preset = awful.util.table.clone(args.default_preset)

            -- Callback.
            local args_for_cb = {
                client=c,
                offset=offset,
                idx=_idx,
                displayed_list=displayed_list }
            local preset_for_offset = args.preset_for_offset
            -- Callback for all.
            if preset_for_offset.default then
                preset_for_offset.default(preset, args_for_cb)
            end
            -- Callback for offset.
            local preset_cb = preset_for_offset[tostring(offset)]
            if preset_cb then
                preset_cb(preset, args_for_cb)
            end

            local entry_layout = wibox.layout.fixed.horizontal()

            if preset.icon_size then
                local icon_widget = get_client_icon_widget(c, preset)
                if icon_widget then
                    entry_layout:add(icon_widget)
                end
            end

            local textbox = wibox.widget.textbox()
            textbox:set_markup(preset.text)
            textbox:set_font(preset.font)
            textbox:set_wrap("word_char")
            textbox:set_ellipsize("middle")
            -- Set height to no wrap with fixed main layout.
            local _, h = textbox:get_preferred_size(c.screen)
            textbox:set_forced_height(h)
            local textbox_margin = wibox.container.margin(textbox)
            textbox_margin:set_margins(dpi(5))

            entry_layout:add(textbox_margin)
            entry_layout = wibox.container.margin(
                entry_layout, dpi(5), dpi(5), dpi(2), dpi(2))
            local entry_with_bg = wibox.container.background(entry_layout)
            if offset == 0 then
                entry_with_bg:set_fg(beautiful.fg_focus)
                entry_with_bg:set_bg(beautiful.bg_focus)
            else
                entry_with_bg:set_fg(beautiful.fg_normal)
                -- entry_with_bg:set_bg(beautiful.bg_normal.."dd")
            end
            layout:add(entry_with_bg)

            -- Add height to outer wibox.
            local context = {dpi=beautiful.xresources.get_dpi(initial_screen)}
            _, h = entry_with_bg:fit(context, wbox.width, 2^20)
            wbox_height = wbox_height + h
        end  -- }}}

        -- Get clients before and after currently selected one.
        local prevnextlist = awful.util.table.clone(history.stack)  -- Use a copy, entries will get nil'ed.
        local _idx = idx

        local dlist = {}  -- A table with offset => stack index.

        dlist[0] = _idx
        prevnextlist[_idx][1] = false

        -- Build dlist for both directions, depending on how many entries should get displayed.
        for _,dir in ipairs({1, -1}) do
            _idx = dlist[0]
            local n = dir == 1 and args.display_next_count or args.display_prev_count
            for i = 1, n do
                local _i = i * dir
                _, _idx = get_next_client(dir, _idx, prevnextlist, false)
                if _ then
                    dlist[_i] = _idx
                end
                prevnextlist[_idx][1] = false
            end
        end

        -- Sort the offsets.
        local offsets = {}
        for n in pairs(dlist) do table.insert(offsets, n) end
        table.sort(offsets)

        -- Display the wibox.
        for _,i in ipairs(offsets) do
            _idx = dlist[i]
            display_entry_for_idx_offset(i, history.stack[_idx][1], _idx, dlist)
        end
        local wa = screen[initial_screen].workarea
        local h = wbox_height + container_margin_top_bottom*2
        wbox:geometry({
            height = h,
            y = wa.y + floor(wa.height/2 - h/2),
        })
        wbox.visible = true
        return true
    end)
end


-- A helper method to wrap awful.key.
function cyclefocus.key(mods, key, startdirection_or_args, args)
    mods = mods or {modkey} or {"Mod4"}
    key = key or "Tab"
    if type(startdirection_or_args) == 'number' then
        awful.util.deprecate('startdirection is not used anymore: pass in mods, key, args', {raw=true})
    else
        args = startdirection_or_args
    end
    args = args and awful.util.table.clone(args) or {}
    if not args.keys then
        if key == "Tab" then
            args.keys = {"Tab", "ISO_Left_Tab"}
        else
            args.keys = {key}
        end
    end
    if not args.modifier then
        -- Convert modifier to key name.
        -- Table from awful.key.
        local conversion = {
            mod4    = "Super_L",
            control = "Control_L",
            shift   = "Shift_L",
            mod1    = "Alt_L",
            -- AltGr (https://github.com/awesomeWM/awesome/pull/2515).
            mod5    = "ISO_Level3_Shift",
        }
        args.modifier = conversion[mods[1]:lower()]
        if not args.modifier then
            args.modifier = mods[1]
        end
    end

    return awful.key(mods, key, function(c)
        args.initiating_client = c  -- only for clientkeys, might be nil!
        cyclefocus.cycle(args)
    end)
end

return cyclefocus
