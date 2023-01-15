---@diagnostic disable: undefined-global
--[[
     Fishlive Lua Library
     Helper functions

     Licensed under GNU General Public License v2
      * (c) 2013, Luca CPZ
     Licensed under GNU General Public License v2
      * (c) 2021, A.Fischer
--]]

local spawn      = require("awful.spawn")
local timer      = require("gears.timer")
local awful      = require("awful")
local gears      = require("gears")
local beautiful  = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi        = xresources.apply_dpi
local wibox      = require("wibox")
local naughty    = require("naughty")

local debug      = require("debug")
local io         = { lines = io.lines, open  = io.open }
local pairs      = pairs
local rawget     = rawget
local table      = { sort  = table.sort, unpack = table.unpack }
local unpack     = table.unpack -- lua 5.1 retro-compatibility

-- Fishlive helper functions for internal use
-- fishlive.helpers
local helpers = {}

-- {{{ Modules loader

function helpers.wrequire(table, key)
    local module = rawget(table, key)
    return module or require(table._NAME .. '.' .. key)
end

-- }}}

-- {{{ File operations

-- check if the file exists and is readable
function helpers.file_exists(path)
    local file = io.open(path, "rb")
    if file then file:close() end
    return file ~= nil
end

-- get a table with all lines from a file
function helpers.lines_from(path)
    local lines = {}
    for line in io.lines(path) do
        lines[#lines + 1] = line
    end
    return lines
end

-- get a table with all lines from a file matching regexp
function helpers.lines_match(regexp, path)
    local lines = {}
    for line in io.lines(path) do
        if string.match(line, regexp) then
            lines[#lines + 1] = line
        end
    end
    return lines
end

-- get first line of a file
function helpers.first_line(path)
    local file, first = io.open(path, "rb"), nil
    if file then
        first = file:read("*l")
        file:close()
    end
    return first
end

-- get first non empty line from a file
function helpers.first_nonempty_line(path)
    for line in io.lines(path) do
        if #line then return line end
    end
    return nil
end

-- }}}

-- {{{ Timer maker

helpers.timer_table = {}

function helpers.newtimer(name, timeout, fun, nostart, stoppable)
    if not name or #name == 0 then return end
    name = (stoppable and name) or timeout
    if not helpers.timer_table[name] then
        helpers.timer_table[name] = timer({ timeout = timeout })
        helpers.timer_table[name]:start()
    end
    helpers.timer_table[name]:connect_signal("timeout", fun)
    if not nostart then
        helpers.timer_table[name]:emit_signal("timeout")
    end
    return stoppable and helpers.timer_table[name]
end

-- }}}

-- {{{ Pipe operations

-- run a command and execute a function on its output (asynchronous pipe)
-- @param cmd the input command
-- @param callback function to execute on cmd output
-- @return cmd PID
function helpers.async(cmd, callback)
    return spawn.easy_async(cmd,
    function (stdout, stderr, reason, exit_code)
        callback(stdout, exit_code)
    end)
end

-- like above, but call spawn.easy_async with a shell
function helpers.async_with_shell(cmd, callback)
    return spawn.easy_async_with_shell(cmd,
    function (stdout, stderr, reason, exit_code)
        callback(stdout, exit_code)
    end)
end

-- run a command and execute a function on its output line by line
function helpers.line_callback(cmd, callback)
    return spawn.with_line_callback(cmd, {
        stdout = function (line)
            callback(line)
        end,
    })
end

-- }}}

-- {{{ A map utility

helpers.map_table = {}

function helpers.set_map(element, value)
    helpers.map_table[element] = value
end

function helpers.get_map(element)
    return helpers.map_table[element]
end

-- }}}

-- {{{ Misc

-- check if an element exist on a table
function helpers.element_in_table(element, tbl)
    for _, i in pairs(tbl) do
        if i == element then
            return true
        end
    end
    return false
end

-- iterate over table of records sorted by keys
function helpers.spairs(t)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    table.sort(keys)

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function helpers.contains(_table, _c)
	for _, c in ipairs(_table) do
		if _c == c then
			return true
		end
	end
	return false
end

function helpers.find(rule)
    local function matcher(c) return awful.rules.match(c, rule) end
    local clients = client.get()
    local findex = gears.table.hasitem(clients, client.focus) or 1
    local start = gears.math.cycle(#clients, findex + 1)

    local matches = {}
    for c in awful.client.iterate(matcher, start) do
        matches[#matches + 1] = c
    end

    return matches
end

-- create the partition of singletons of a given set
-- example: the trivial partition set of {a, b, c}, is {{a}, {b}, {c}}
function helpers.trivial_partition_set(set)
    local ss = {}
    for _,e in pairs(set) do
        ss[#ss+1] = {e}
    end
    return ss
end

-- create the powerset of a given set
function helpers.powerset(s)
    if not s then return {} end
    local t = {{}}
    for i = 1, #s do
        for j = 1, #t do
            t[#t+1] = {s[i],unpack(t[j])}
        end
    end
    return t
end

-- Rounds a number to any number of decimals
function helpers.round(number, decimals)
    local power = 10 ^ decimals
    return math.floor(number * power) / power
end

-- }}}

-- {{{ GUI/UI helpers

-- Adds a maximized mask to a screen
function helpers.screen_mask(s, bg)
    local mask = wibox({
        visible = false,
        ontop = true,
        type = "splash",
        screen = s
    })
    awful.placement.maximize(mask)
    mask.bg = bg
    return mask
end

-- Create rounded rectangle shape (in one line)
helpers.rrect = function(radius)
    return function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, radius)
    end
end

-- Create pi
helpers.pie = function(width, height, start_angle, end_angle, radius)
    return function(cr)
        gears.shape.pie(cr, width, height, start_angle, end_angle, radius)
    end
end

-- Create parallelogram
helpers.prgram = function(height, base)
    return function(cr, width)
        gears.shape.parallelogram(cr, width, height, base)
    end
end

-- Create partially rounded rect
helpers.prrect = function(radius, tl, tr, br, bl)
    return function(cr, width, height)
        gears.shape.partially_rounded_rect(cr, width, height, tl, tr, br, bl,
                                           radius)
    end
end

-- Create rounded bar
helpers.rbar = function(width, height)
    return function(cr)
        gears.shape.rounded_bar(cr, width, height)
    end
end

-- Markup helper
function helpers.colorize_text(txt, fg)
    return "<span foreground='" .. fg .. "'>" .. txt .. "</span>"
end

function helpers.vertical_pad(height)
    return wibox.widget {
        forced_height = height,
        layout = wibox.layout.fixed.vertical
    }
end

function helpers.horizontal_pad(width)
    return wibox.widget {
        forced_width = width,
        layout = wibox.layout.fixed.horizontal
    }
end

-- Maximizes client and also respects gaps
function helpers.maximize(c)
    c.maximized = not c.maximized
    if c.maximized then
        awful.placement.maximize(c, {
            honor_padding = true,
            honor_workarea = true,
            margins = beautiful.useless_gap * 2
        })

    end
    c:raise()
end

function helpers.move_to_edge(c, direction)
    -- local workarea = awful.screen.focused().workarea
    -- local client_geometry = c:geometry()
    if direction == "up" then
        local old_x = c:geometry().x
        awful.placement.top(c, {
            honor_workarea = true,
            honor_padding = true
        })
        c.x = old_x
        -- c:geometry({ nil, y = workarea.y + beautiful.screen_margin * 2, nil, nil })
    elseif direction == "down" then
        local old_x = c:geometry().x
        awful.placement.bottom(c, {
            honor_workarea = true,
            honor_padding = true
        })
        c.x = old_x
        -- c:geometry({ nil, y = workarea.height + workarea.y - client_geometry.height - beautiful.screen_margin * 2 - beautiful.border_width * 2, nil, nil })
    elseif direction == "left" then
        local old_y = c:geometry().y
        awful.placement.left(c, {
            honor_workarea = true,
            honor_padding = true
        })
        c.y = old_y
        -- c:geometry({ x = workarea.x + beautiful.screen_margin * 2, nil, nil, nil })
    elseif direction == "right" then
        local old_y = c:geometry().y
        awful.placement.right(c, {
            honor_workarea = true,
            honor_padding = true
        })
        c.y = old_y
        -- c:geometry({ x = workarea.width + workarea.x - client_geometry.width - beautiful.screen_margin * 2 - beautiful.border_width * 2, nil, nil, nil })
    end
end

-- Add a hover cursor to a widget by changing the cursor on
-- mouse::enter and mouse::leave
-- You can find the names of the available cursors by opening any
-- cursor theme and looking in the "cursors folder"
-- For example: "hand1" is the cursor that appears when hovering over
-- links
function helpers.add_hover_cursor(w, hover_cursor)
    local original_cursor = "left_ptr"

    w:connect_signal("mouse::enter", function()
        ---@diagnostic disable-next-line: undefined-field
        local w = _G.mouse.current_wibox
        if w then w.cursor = hover_cursor end
    end)

    w:connect_signal("mouse::leave", function()
        ---@diagnostic disable-next-line: undefined-field
        local w = _G.mouse.current_wibox
        if w then w.cursor = original_cursor end
    end)
end

-- Tag back and forth:
-- If you try to focus the tag you are already at, go back to the previous tag.
-- Useful for quick switching after for example checking an incoming chat
-- message at tag 2 and coming back to your work at tag 1 with the same
-- keypress.
-- Also focuses urgent clients if they exist in the tag. This fixes the issue
-- (visual mismatch) where after switching to a tag which includes an urgent
-- client, the urgent client is unfocused but still covers all other windows
-- (even the currently focused window).
function helpers.tag_back_and_forth(tag_index)
    local s = mouse.screen
    local tag = s.tags[tag_index]
    if tag then
        if tag == s.selected_tag then
            awful.tag.history.restore()
        else
            tag:view_only()
        end

        local urgent_clients = function(c)
            return awful.rules.match(c, {urgent = true, first_tag = tag})
        end

        for c in awful.client.iterate(urgent_clients) do
            client.focus = c
            c:raise()
        end
    end
end

-- Move client to screen edge, respecting the screen workarea
function helpers.move_to_edge_workarea(c, direction)
    local workarea = awful.screen.focused().workarea
    if direction == "up" then
        c:geometry({nil, y = workarea.y + beautiful.useless_gap * 2, nil, nil})
    elseif direction == "down" then
        c:geometry({
            nil,
            y = workarea.height + workarea.y - c:geometry().height -
                beautiful.useless_gap * 2 - beautiful.border_width * 2,
            nil,
            nil
        })
    elseif direction == "left" then
        c:geometry({x = workarea.x + beautiful.useless_gap * 2, nil, nil, nil})
    elseif direction == "right" then
        c:geometry({
            x = workarea.width + workarea.x - c:geometry().width -
                beautiful.useless_gap * 2 - beautiful.border_width * 2,
            nil,
            nil,
            nil
        })
    end
end

-- Make client floating and snap to the desired edge
function helpers.float_and_edge_snap(c, direction)
    -- if not c.floating then
    --     c.floating = true
    -- end
    naughty.notify({text = "double tap"})
    c.floating = true
    local workarea = awful.screen.focused().workarea
    if direction == "up" then
        local axis = 'horizontally'
        local f = awful.placement.scale + awful.placement.top +
                      (axis and awful.placement['maximize_' .. axis] or nil)
        local geo = f(client.focus, {
            honor_padding = true,
            honor_workarea = true,
            to_percent = 0.5
        })
    elseif direction == "down" then
        local axis = 'horizontally'
        local f = awful.placement.scale + awful.placement.bottom +
                      (axis and awful.placement['maximize_' .. axis] or nil)
        local geo = f(client.focus, {
            honor_padding = true,
            honor_workarea = true,
            to_percent = 0.5
        })
    elseif direction == "left" then
        local axis = 'vertically'
        local f = awful.placement.scale + awful.placement.left +
                      (axis and awful.placement['maximize_' .. axis] or nil)
        local geo = f(client.focus, {
            honor_padding = true,
            honor_workarea = true,
            to_percent = 0.5
        })
    elseif direction == "right" then
        local axis = 'vertically'
        local f = awful.placement.scale + awful.placement.right +
                      (axis and awful.placement['maximize_' .. axis] or nil)
        local geo = f(client.focus, {
            honor_padding = true,
            honor_workarea = true,
            to_percent = 0.5
        })
    end
end

function helpers.run_or_raise(match, move, spawn_cmd, spawn_args)
    local matcher = function(c) return awful.rules.match(c, match) end

    -- Find and raise
    local found = false
    for c in awful.client.iterate(matcher) do
        found = true
        c.minimized = false
        if move then
            c:move_to_tag(mouse.screen.selected_tag)
            client.focus = c
            c:raise()
        else
            c:jump_to()
        end
        break
    end

    -- Spawn if not found
    if not found then awful.spawn(spawn_cmd, spawn_args) end
end

function helpers.pad(size)
    local str = ""
    for i = 1, size do str = str .. " " end
    local pad = wibox.widget.textbox(str)
    return pad
end

function helpers.float_and_resize(c, width, height)
    c.width = width
    c.height = height
    awful.placement.centered(c, {honor_workarea = true, honor_padding = true})
    awful.client.property.set(c, 'floating_geometry', c:geometry())
    c.floating = true
    c:raise()
end

function helpers.tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function helpers.hover_pointer(widget)
    local old_cursor, old_wibox
    widget:connect_signal("mouse::enter", function()
        -- Hm, no idea how to get the wibox from this signal's arguments...
        local w = mouse.current_wibox
        old_cursor, old_wibox = w.cursor, w
        w.cursor = "hand2"
        widget:get_children_by_id("custom_icon")[1].font = beautiful.icon_font.."31"
    end)
    widget:connect_signal("mouse::leave", function()
        if old_wibox then
            old_wibox.cursor = old_cursor
            old_wibox = nil
        end
        local w = mouse.current_wibox
        widget:get_children_by_id("custom_icon")[1].font = beautiful.icon_font.."26"
    end)
end

--#!/usr/bin/env bash
--cat <<EOF | awesome-client
--require("fishlive.helpers")
--spawn("/usr/bin/firefox", "firefox", screen[1].tags[4], "class")
--spawn("/usr/bin/kwrite", "kwrite", screen[1].tags[5], "class")
--EOF
function helpers.spawn(command, class, tag, test)
    test = test or "class"
    local callback
    callback = function(c)
        if test == "class" then
            if c.class == class then
                awful.client.movetotag(tag, c)
                client.disconnect_signal("manage", callback)
            end
        elseif test == "instance" then
            if c.instance == class then
                awful.client.movetotag(tag, c)
                client.disconnect_signal("manage", callback)
            end
        elseif test == "name" then
               if string.match(c.name, class) then
                   awful.client.movetotag(tag, c)
                client.disconnect_signal("manage", callback)
            end
        end
    end
    client.connect_signal("manage", callback)
    awful.util.spawn_with_shell(command)
end

-- }}}

return helpers
