---------------------------------------------------------------------------
--- Mirrored "left" tile layout for awful
--
-- This is the same as awful's awful.layout.suit.tile.left but with the
-- secondary columns' order reversed.
--
-- With two columns, awful.layout.suit.tile.left has
--
-- +-----+-----+-----------+
-- |     |     |           |
-- |     |  3  |           |
-- |     |     |           |
-- |  2  +-----+     1     |
-- |     |     |           |
-- |     |  4  |           |
-- |     |     |           |
-- +-----+-----+-----------+
--
-- Whereas this layout has
--
-- +-----+-----+-----------+
-- |     |     |           |
-- |  3  |     |           |
-- |     |     |           |
-- +-----+  2  |     1     |
-- |     |     |           |
-- |  4  |     |           |
-- |     |     |           |
-- +-----+-----+-----------+
--
-- Which properly mirrors awful.layout.suit.tile.right.
--
-- @author Bart Nagel &lt;bart@tremby.net&gt;
--
-- Mostly copied from Tiled layouts module for awful
-- (awful/layout/suit/tile.lua)
--
-- @author Donald Ephraim Curtis &lt;dcurtis@cs.uiowa.edu&gt;
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2009 Donald Ephraim Curtis
-- @copyright 2008 Julien Danjou
---------------------------------------------------------------------------

-- Grab environment we need
local tag = require("awful.tag")
local client = require("awful.client")
local ipairs = ipairs
local math = math
local capi = {
    mouse = mouse,
    screen = screen,
    mousegrabber = mousegrabber,
}

local tile = {}

--- The tile left layout layoutbox icon.
-- @beautiful beautiful.layout_tileleft
-- @param surface
-- @see gears.surface

--- Jump mouse cursor to the client's corner when resizing it.
tile.resize_jump_to_corner = true

local function mouse_resize_handler(c, _, _, _)
    local work_area = c.screen.workarea
    local master_width_factor = c.screen.selected_tag.master_width_factor
    local cursor
    local g = c:geometry()
    local offset = 0
    local corner_coords
    local coordinates_delta = {x=0, y=0}

    cursor = "cross"
    if g.height + 15 >= work_area.height then
        offset = g.height * .5
        cursor = "sb_h_double_arrow"
    elseif not (g.y + g.height + 15 > work_area.y + work_area.height) then
        offset = g.height
    end
    corner_coords = {x = work_area.x + work_area.width * (1 - master_width_factor), y = g.y + offset}
    if tile.resize_jump_to_corner then
        capi.mouse.coords(corner_coords)
    else
        local mouse_coords = capi.mouse.coords()
        coordinates_delta = {
          x = corner_coords.x - mouse_coords.x,
          y = corner_coords.y - mouse_coords.y,
        }
    end

    local prev_coords = {}
    capi.mousegrabber.run(function (_mouse)
        if not c.valid then return false end

        _mouse.x = _mouse.x + coordinates_delta.x
        _mouse.y = _mouse.y + coordinates_delta.y
        for _, v in ipairs(_mouse.buttons) do
            if v then
                prev_coords = {x =_mouse.x, y = _mouse.y}
                local fact_x = (_mouse.x - work_area.x) / work_area.width
                local fact_y = (_mouse.y - work_area.y) / work_area.height
                local new_mwfact

                local geometry = c:geometry()

                -- we have to make sure we're not on the last visible
                -- client where we have to use different settings.
                local wfact
                local wfact_x, wfact_y
                if (geometry.y + geometry.height + 15) > (work_area.y + work_area.height) then
                    wfact_y = (geometry.y + geometry.height - _mouse.y) / work_area.height
                else
                    wfact_y = (_mouse.y - geometry.y) / work_area.height
                end

                if (geometry.x + geometry.width + 15) > (work_area.x + work_area.width) then
                    wfact_x = (geometry.x + geometry.width - _mouse.x) / work_area.width
                else
                    wfact_x = (_mouse.x - geometry.x) / work_area.width
                end

                new_mwfact = 1 - fact_x
                wfact = wfact_y

                c.screen.selected_tag.master_width_factor = math.min(math.max(new_mwfact, 0.01), 0.99)
                client.setwfact(math.min(math.max(wfact, 0.01), 0.99), c)
                return true
            end
        end
        return prev_coords.x == _mouse.x and prev_coords.y == _mouse.y
    end, cursor)
end

local function tile_group(geometries, clients, work_area, window_factors, group)
    -- This is modified to take a right edge coordinate as group.right rather
    -- than a left edge coordinate as group.coord

    -- Find our total values
    local total_factor = 0
    local min_fact = 1
    local width = group.width
    for c = group.first, group.last do
        -- Determine the width based on the size_hint
        local i = c - group.first + 1
        local size_hints = clients[c].size_hints
        local size_hint = size_hints.min_width or size_hints.base_width or 0
        width = math.max(size_hint, width)

        -- calculate the height
        if not window_factors[i] then
            window_factors[i] = min_fact
        else
            min_fact = math.min(window_factors[i], min_fact)
        end
        total_factor = total_factor + window_factors[i]
    end
    width = math.max(1, math.min(width, group.right - work_area.x))

    local top = work_area.y
    local used_size = 0
    local unused_height = work_area.height
    for c = group.first, group.last do
        local geometry = {}
        local hints = {}
        local i = c - group.first + 1
        geometry.width = width
        geometry.height = math.max(1, math.floor(unused_height * window_factors[i] / total_factor))
        geometry.x = group.right - geometry.width
        geometry.y = top
        geometries[clients[c]] = geometry
        hints.width, hints.height = clients[c]:apply_size_hints(geometry.width, geometry.height)
        top = top + hints.height
        unused_height = unused_height - hints.height
        total_factor = total_factor - window_factors[i]
        used_size = math.max(used_size, hints.width)
    end

    return used_size
end

local function do_tile(param)
    local t = param.tag or capi.screen[param.screen].selected_tag

    local geometries = param.geometries
    local clients = param.clients
    local num_masters = math.min(t.master_count, #clients)
    local num_others = math.max(#clients - num_masters, 0)

    local master_width_factor = t.master_width_factor
    local work_area = param.workarea
    local column_count = t.column_count

    local window_factors = tag.getdata(t).windowfact

    if not window_factors then
        window_factors = {}
        tag.getdata(t).windowfact = window_factors
    end

    local grow_master = t.master_fill_policy == "expand"

    -- Start from right edge of our available space
    local available_width = work_area.width
    local right = work_area.x + work_area.width

    if num_masters > 0 then
        local target_width
        if grow_master and num_others == 0 then
            target_width = work_area.width
        else
            target_width = work_area.width * master_width_factor
            if not grow_master and num_others == 0 then
                right = right - (work_area.width - target_width) / 2
            end
        end
        if not window_factors[0] then
            window_factors[0] = {}
        end
        local used_width = tile_group(geometries, clients, work_area, window_factors[0],
            {first = 1, last = num_masters, right = right, width = target_width})
        available_width = available_width - used_width
        right = right - used_width
    end

    if num_others > 0 then
        local last = num_masters

        for current_column_index = 1, column_count do
            -- Try to get equal width among remaining columns
            local columns_to_tile = column_count - current_column_index + 1
            local width = available_width / columns_to_tile
            local first = last + 1

            -- What's the last client we should tile in this column (and how
            -- many clients shall be in this column?)
            last = last + math.floor((#clients - last) / columns_to_tile)

            -- tile the column and update our current x coordinate
            if not window_factors[current_column_index] then
                window_factors[current_column_index] = {}
            end
            local used_width = tile_group(geometries, clients, work_area, window_factors[current_column_index],
                {first = first, last = last, right = right, width = width})
            available_width = available_width - used_width
            right = right - used_width
        end
    end

end

--- The main tile algo, on the left, but with the secondary columns mirrored
-- compared to awful's one.
-- @param screen The screen number to tile.
tile.left = {}
tile.left.name = "tileleft"
function tile.left.arrange(p)
    return do_tile(p)
end
function tile.left.mouse_resize_handler(c, corner, x, y)
    return mouse_resize_handler(c, corner, x, y)
end

tile.arrange = tile.left.arrange
tile.mouse_resize_handler = tile.left.mouse_resize_handler
tile.name = tile.left.name

return tile

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
