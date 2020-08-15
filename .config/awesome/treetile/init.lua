
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan



    treetile: Binary Tree-based tiling layout for Awesome v4

    URL:     https://github.com/alfunx/treetile
    Fork of: https://github.com/RobSis/treesome
             https://github.com/guotsuan/treetile



    Because the the split of space is depending on the parent node, which is
    current focused client.  Therefore it is necessary to set the correct
    focus option, "treetile.new_focus".

    If the new created client will automatically gain the focus, for exmaple
    in rc.lua with the settings:

    ...
    awful.rules.rules = {
        { rule = { },
          properties = { focus = awful.client.focus.filter,
    ...

    You need to set "treetile.new_focus = true"
    Otherwise, set "treetile.new_focus = false"

--]]

local awful        = require("awful")
local beautiful    = require("beautiful")
local gdebug       = require("gears.debug")
local gtable       = require("gears.table")
local naughty      = require("naughty")

local bintree      = require("treetile.bintree")
local os           = os
local math         = math
local ipairs       = ipairs
local pairs        = pairs
local table        = table
local tonumber     = tonumber
local tostring     = tostring
local type         = type

local capi = {
    client       = client,
    tag          = tag,
    mouse        = mouse,
    screen       = screen,
    mousegrabber = mousegrabber,
}

local treetile = {
    name             = "treetile",
    new_focus        = true,
    new_ratio        = 0.5,
    new_split        = "vertical",
    new_vertical     = "right",
    new_horizontal   = "bottom",
    rotate_on_remove = false,
    debug            = false,
}

-- globals
local force_split = nil
local trees       = { }

-- TODO
-- layout icon
beautiful.layout_treetile = os.getenv("HOME") .. "/.config/awesome/treetile/layout_icon.png"

-- {{{ helpers

local function debug_info(message)
    if type(message) == "table" then
        local text = { }
        for k, v in pairs(message) do
            table.insert(text, { "key: ", k, " value: ", tostring(v), "\n" })
        end
        naughty.notify { text = table.concat(text) }
    else
        naughty.notify { text = tostring(message) }
    end
end

-- Diff clients. Ugly but optimized.
local function full_diff(old, new)
    local added, moved, removed = { }, { }, { }
    for i = 1, #old do
        local new_index = gtable.hasitem(new, old[i])
        if new[i] ~= old[i] and new_index then
            table.insert(moved, old[i])
        elseif not new_index then
            table.insert(removed, old[i])
        end
    end
    for i = 1, #new do
        if not gtable.hasitem(old, new[i]) then
            table.insert(added, new[i])
        end
    end
    return added, moved, removed
end

-- Split geometry into two geometries.
local function calculate_geometry(geometry, split, ratio)
    local vertical = split == "vertical"
    local width, height = geometry.width, geometry.height
    if vertical then
        geometry.width = width * ratio
    else
        geometry.height = height * ratio
    end
    return geometry, {
        x      = vertical and geometry.x + width * ratio or geometry.x,
        y      = not vertical and geometry.y + height * ratio or geometry.y,
        width  = vertical and width * (1 - ratio) or width,
        height = not vertical and height * (1 - ratio) or height,
    }
end

local function match(c)
    return function(node)
        return node.data.id == c
    end
end

local function cleanup(node)
    node.data.id = nil
end

local function rotate(split)
    return split == "vertical" and "horizontal" or "vertical"
end

-- }}}

-- {{{ bintree enhancement

function bintree:apply_geometry(geometry, gaps)
    assert((self.left and self.right and not self.data.id)
            or (not self.left and not self.right and self.data.id))

    if self.left and self.right then
        local g1, g2 = calculate_geometry(geometry, self.data.split, self.data.ratio)
        self.left:apply_geometry(g1, gaps)
        self.right:apply_geometry(g2, gaps)
        return
    else
        local c = self.data.id
        geometry.width  = geometry.width  - 2 * gaps - 2 * c.border_width
        geometry.height = geometry.height - 2 * gaps - 2 * c.border_width
        c:geometry(geometry)
    end
end

function bintree:rotate()
    if not self.data.split then return end
    self.data.split = self.data.split == "vertical" and "horizontal" or "vertical"
end

function bintree:rotate_all()
    if not self.data.split then return end
    self:apply(bintree.rotate)
end

function bintree:show_detailed()
    self:apply_levels(function(node, level)
        if node.data.id then
            print(table.concat {
                string.rep(" ", 4 * level),
                node.parent and (node.parent.left == node and "┌" or "└") or " ",
                " ● [",
                "x:", tostring(node.data.id.x),      " ",
                "y:", tostring(node.data.id.y),      " ",
                "w:", tostring(node.data.id.width),  " ",
                "h:", tostring(node.data.id.height), "] [",
                tostring(node.data.id),              "]",
            })
        else
            print(table.concat {
                string.rep(" ", 4 * level),
                node.parent and (node.parent.left == node and "┌" or "└") or " ",
                " ● [",
                tostring(node.data.ratio), "] [",
                tostring(node.data.split), "]",
            })
        end
    end)
end

-- }}}

-- {{{ implementation

-- One or more clients are added. Put them in the tree.
local function add_clients(t, clients, focus)
    if #clients == 0 then return end

    local node = trees[t].root and trees[t].root:find_if(match(focus))

    for _, c in pairs(clients) do
        if node then
            node.data.ratio = treetile.new_ratio
            node.data.split = force_split
                    or (node.parent and rotate(node.parent.data.split))
                    or treetile.new_split
            if node.data.split == "vertical" and treetile.new_vertical == "left"
                    or node.data.split == "horizontal" and treetile.new_vertical == "top" then
                node:set_new_right { id = node.data.id }
                node.data.id = nil
                node = node:set_new_left { id = c }
            else
                node:set_new_left { id = node.data.id }
                node.data.id = nil
                node = node:set_new_right { id = c }
            end
        else
            assert(not trees[t].root)
            trees[t].root = bintree.new { id = c }
            node = trees[t].root
        end
        focus = c
    end

    if focus and not focus.floating then
        trees[t].last_focus = focus
    end
    force_split = nil
end

-- Some client removed. Update the trees.
local function prune_clients(t, clients)
    if not trees[t].root then return end

    for _, c in pairs(clients) do
        local node = trees[t].root:find_if(match(c))
        assert(node)
        if node.parent then
            local parent = node.parent
            local sibling = node:get_sibling()

            parent.data, sibling.data = sibling.data, parent.data
            parent:set_left(sibling.left)
            parent:set_right(sibling.right)

            node:remove(cleanup)
            sibling:remove(cleanup)

            if treetile.rotate_on_remove then
                trees[t].root:rotate_all()
            end

            trees[t].last_focus = parent.data.id
                    -- or parent:get_leftmost() or parent:get_rightmost()
        else
            trees[t].root:remove(cleanup)
            trees[t].root = nil
            trees[t].last_focus = nil
            return
        end
    end
end

-- Update the geometries of all clients.
local function update_clients(t, geometry)
    if not trees[t].root then return end
    trees[t].root:apply_geometry({
        x      = geometry.x + t.gap,
        y      = geometry.y + t.gap,
        width  = geometry.width,
        height = geometry.height,
    }, t.gap)
end

local function resize(inc, split)
    -- inc: percentage of change: 0.01, 0.99 with +/-
    local c = capi.client.focus
    local t = (capi.screen[c.screen].selected_tag
            or awful.tag.selected(capi.mouse.screen))
    if not trees[t].root then return end

    local node = trees[t].root:find_if(match(c)).parent
    while node and node.data.split ~= split do
        node = node.parent
    end
    if not node then return end

    node.data.ratio = math.min(math.max(node.data.ratio + inc, 0.1), 0.9)

    if treetile.debug then
        print("tree:", t.name)
        trees[t].root:show_detailed()
    end

    update_clients(t, trees[t].params.workarea)
end

function treetile.arrange(params)
    local t = (params.tag
            or capi.screen[params.screen].selected_tag
            or awful.tag.selected(capi.mouse.screen))

    -- Create a new root.
    if not trees[t] then
        trees[t] = {
            root = nil,
            last_focus = nil,
            params = {
                clients = { },
            },
        }
    end

    -- Calculate diff.
    local added, moved, removed = full_diff(trees[t].params.clients, params.clients)
    if treetile.debug then
        print(string.format("\ndiff: +%d ~%d -%d", #added, #moved, #removed))
    end

    -- Swap two (!) clients.
    if #moved == 2 and #params.clients == #trees[t].params.clients then
        local node1 = trees[t].root:find_if(match(moved[1]))
        local node2 = trees[t].root:find_if(match(moved[2]))
        node1.data.id, node2.data.id = node2.data.id, node1.data.id
    end

    -- Prune clients from the tree that are not tagged anymore.
    if #removed > 0 and trees[t].root then
        prune_clients(t, removed)
    end

    -- Add clients that are not in the tree yet.
    if #added > 0 then
        -- TODO: find a better to handle this
        local focus = treetile.new_focus
                and awful.client.focus.history.get(params.screen, 1)
                or capi.client.focus

        if not focus or focus.floating then
            focus = trees[t].last_focus
        end

        add_clients(t, added, focus)
    end

    -- Update all client geometries.
    update_clients(t, params.workarea)

    if treetile.debug and trees[t].root and #added + #moved + #removed > 0 then
        print("tree:", t.name)
        trees[t].root:show_detailed()
    end

    -- Store params.
    trees[t].params = params
end

-- function treetile.mouse_resize_handler(c, corner, x, y)
--     local t = (capi.screen[c.screen].selected_tag
--             or awful.tag.selected(capi.mouse.screen))
--     if not trees[t].root then return end
--
--     local node = trees[t].root:find_if(match(c))
--     local cl = node.data.id
--     cl.x = x
--     cl.y = y
-- end

-- -- TODO
-- -- Not implimented yet, do not use it!
-- -- Resizing should only happen between the siblings?
-- local function mouse_resize_handler(c, _, _, _)
--     local t = c.screen.selected_tag or awful.tag.selected(c.screen)
--     local g = c:geometry()
--     local cursor
--     local corner_coords
--
--     local parent_c = trees[t].root:get_parent_if(match(c))
--     local parent_geo
--
--     local new_y = nil
--     local new_x = nil
--
--     local sib_node = parent_c:get_sibling_if(match(c))
--     local sib_node_geo
--     if type(sib_node.data.id) == "number" then
--         sib_node_geo = trees[t].geo[sib_node.data.id]
--     else
--         sib_node_geo = sib_node.data.geometry
--     end
--
--     if parent_c then
--         parent_geo = parent_c.data.geometry
--     else
--         return
--     end
--
--     if parent_c then
--         if parent_c.data.split == "vertical" then
--             cursor = "sb_v_double_arrow"
--             new_y = math.max(g.y, sib_node_geo.y)
--             new_x = g.x + g.width / 2
--         end
--
--         if parent_c.data.split == "horizontal" then
--             cursor = "sb_h_double_arrow"
--             new_x = math.max(g.x, sib_node_geo.x)
--             new_y = g.y + g.height / 2
--         end
--     end
--
--     corner_coords = { x = new_x, y = new_y }
--
--     capi.mouse.coords(corner_coords)
--
--     local prev_coords = { }
--     capi.mousegrabber.run(function(m)
--         for _, v in pairs(m.buttons) do
--             if v then
--                 prev_coords = { x = m.x, y = m.y }
--                 local fact_x = (m.x - corner_coords.x)
--                 local fact_y = (m.y - corner_coords.y)
--
--                 local new_geo = { }
--                 local new_sib = { }
--
--                 local min_x = 15.0
--                 local min_y = 15.0
--
--                 new_geo.x = g.x
--                 new_geo.y = g.y
--                 new_geo.width = g.width
--                 new_geo.height = g.height
--
--                 if parent_c.data.split == "vertical" then
--                     if g.y > sib_node_geo.y then
--                         new_geo.height = clip(g.height - fact_y, min_y, parent_geo.height - min_y)
--                         new_geo.y= clip(m.y, sib_node_geo.y + min_y, parent_geo.y + parent_geo.height - min_y)
--
--                         new_sib.x = parent_geo.x
--                         new_sib.y = parent_geo.y
--                         new_sib.width = parent_geo.width
--                         new_sib.height = parent_geo.height - new_geo.height
--                     else
--                         new_geo.y = g.y
--                         new_geo.height = clip(g.height + fact_y,  min_y, parent_geo.height - min_y)
--
--                         new_sib.x = new_geo.x
--                         new_sib.y = new_geo.y + new_geo.height
--                         new_sib.width = parent_geo.width
--                         new_sib.height = parent_geo.height - new_geo.height
--                     end
--                 end
--
--                 if parent_c.data.split == "horizontal" then
--                     if g.x  > sib_node_geo.x  then
--                         new_geo.width = clip(g.width - fact_x, min_x, parent_geo.width - min_x)
--                         new_geo.x = clip(m.x, sib_node_geo.x + min_x, parent_geo.x + parent_geo.width - min_x)
--
--                         new_sib.y = parent_geo.y
--                         new_sib.x = parent_geo.x
--                         new_sib.height = parent_geo.height
--                         new_sib.width = parent_geo.width - new_geo.width
--                     else
--                         new_geo.x = g.x
--                         new_geo.width = clip(g.width + fact_x, min_x, parent_geo.width - min_x)
--
--                         new_sib.y = parent_geo.y
--                         new_sib.x = parent_geo.x + new_geo.width
--                         new_sib.height = parent_geo.height
--                         new_sib.width = parent_geo.width - new_geo.width
--                     end
--                 end
--
--                 trees[t].geo[hash(c)] = new_geo
--
--                 if sib_node then
--                     sib_node:update_nodes_geo(new_sib, trees[t].geo)
--                 end
--
--                 for _, cl in pairs(trees[t].clients) do
--                     local geo = trees[t].geo[hash(cl)]
--                     if type(geo) == 'table' then
--                         cl:geometry(geo)
--                     else
--                         gdebug.print_error("treetile: faulty geometry")
--                     end
--                 end
--
--                 return true
--             end
--         end
--         return prev_coords.x == m.x and prev_coords.y == m.y
--     end, cursor)
-- end
--
-- function treetile.mouse_resize_handler(c, corner, x, y)
--     mouse_resize_handler(c, corner,x,y)
-- end

-- }}}

-- {{{ public functions

function treetile.resize_horizontal(inc)
    return resize(inc, "vertical")
end

function treetile.resize_vertical(inc)
    return resize(inc, "horizontal")
end

function treetile.horizontal()
    force_split = "horizontal"
    if treetile.debug then debug_info('Next split is horizontal.') end
end

function treetile.vertical()
    force_split = "vertical"
    if treetile.debug then debug_info('Next split is vertical.') end
end

function treetile.rotate(c)
    local t = c and c.screen.selected_tag
            or awful.screen.focused().selected_tag
    local node = c and trees[t].root:find_if(match(c)).parent
    if node then
        node:rotate()
        update_clients(t, trees[t].params.workarea)
    end
end

function treetile.rotate_all(c)
    local t = c and c.screen.selected_tag
            or awful.screen.focused().selected_tag
    local node = c and trees[t].root:find_if(match(c)).parent
    if node then
        node:rotate_all()
        update_clients(t, trees[t].params.workarea)
    end
end

function treetile.swap(c)
    local t = c and c.screen.selected_tag
            or awful.screen.focused().selected_tag
    local node = c and trees[t].root:find_if(match(c)).parent
    if node then
        node:swap_children()
        update_clients(t, trees[t].params.workarea)
    end
end

function treetile.swap_all(c)
    local t = c and c.screen.selected_tag
            or awful.screen.focused().selected_tag
    local node = c and trees[t].root:find_if(match(c)).parent
    if node then
        node:apply(function(n)
            if not n.parent or n.parent.right == n then n:swap_children() end
        end)
        update_clients(t, trees[t].params.workarea)
    end
end

-- }}}

return treetile
