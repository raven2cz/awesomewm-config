--- Provides functionality to share tags across all screens in awesome WM.
-- @module sharedtags
-- @author Albert Diserholt
-- @copyright 2016 Albert Diserholt
-- @license MIT

-- Grab environment we need
local awful = require("awful")
local capi = {
    screen = screen
}

local sharedtags = {
    _VERSION = "sharedtags v1.0.0 for v4.0",
    _DESCRIPTION = "Share tags for awesome window manager v4.0",
    _URL = "https://github.com/Drauthius/awesome-sharedtags",
    _LICENSE = [[
        MIT LICENSE

        Copyright (c) 2017 Albert Diserholt

        Permission is hereby granted, free of charge, to any person obtaining a
        copy of this software and associated documentation files (the "Software"),
        to deal in the Software without restriction, including without limitation
        the rights to use, copy, modify, merge, publish, distribute, sublicense,
        and/or sell copies of the Software, and to permit persons to whom the
        Software is furnished to do so, subject to the following conditions:

        The above copyright notice and this permission notice shall be included in
        all copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
        FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
        IN THE SOFTWARE.
    ]]
}

--- Attempts to salvage a tag when a screen is removed.
-- @param tag The tag to salvage.
local function salvage(tag)
    -- The screen to move the orphaned tag to.
    local newscreen = capi.screen.primary
    -- the primary screen may be the one that is being
    -- removed, so try to find a different screen if possible.
    for s in capi.screen do
        if s ~= tag.screen then
            newscreen = s
        end
    end

    -- Make sure the tag isn't selected when moved to the new screen.
    tag.selected = false

    sharedtags.movetag(tag, newscreen)

    capi.screen[newscreen]:emit_signal("tag::history::update")
end

--- Create one new tag with sharedtags metadata.
-- This is mostly useful for setups with dynamic tag adding.
-- @tparam number i The tag (global/shared) index
-- @tparam table t The tag definition table for awful.tag.add
-- @treturn table The created tag.
function sharedtags.add(i, t)
   t = awful.util.table.clone(t, false) -- shallow copy for modification
   t.screen = (t.screen and t.screen <= capi.screen.count()) and t.screen or capi.screen.primary
   t.sharedtagindex = i
   local tag = awful.tag.add(t.name or i, t)

   -- If no tag is selected for this screen, then select this one.
   if not tag.screen.selected_tag then
      tag:view_only() -- Updates the history as well.
   end

   -- Make sure to salvage the tag in case the screen disappears.
   tag:connect_signal("request::screen", salvage)

   return tag
end

--- Create new tag objects.
-- The first tag defined for each screen will be automatically selected.
-- @tparam table def A list of tables with the optional keys `name`, `layout`
-- and `screen`. The `name` value is used to name the tag and defaults to the
-- list index. The `layout` value sets the starting layout for the tag and
-- defaults to the first layout. The `screen` value sets the starting screen
-- for the tag and defaults to the first screen. The tags will be sorted in this
-- order in the default taglist.
-- @treturn table A list of all created tags. Tags are assigned numeric values
-- corresponding to the input list, and all tags with non-numerical names are
-- also assigned to a key with the same name.
-- @usage local tags = sharedtags(
--   -- "main" is the first tag starting on screen 2 with the tile layout.
--   { name = "main", layout = awful.layout.suit.tile, screen = 2 },
--   -- "www" is the second tag on screen 1 with the floating layout.
--   { name = "www" },
--   -- Third tag is named "3" on screen 1 with the floating layout.
--   {})
-- -- tags[2] and tags["www"] both refer to the same tag.
function sharedtags.new(def)
    local tags = {}

    for i,t in ipairs(def) do
        tags[i] = sharedtags.add(i, t)

        -- Create an alias between the index and the name.
        if t.name and type(t.name) ~= "number" then
            tags[t.name] = tags[i]
        end
    end

    return tags
end

--- Move the specified tag to a new screen, if necessary.
-- @param tag The tag to move.
-- @tparam[opt=awful.screen.focused()] number screen The screen to move the tag to.
-- @treturn bool Whether the tag was moved.
function sharedtags.movetag(tag, screen)
    screen = screen or awful.screen.focused()
    local oldscreen = tag.screen

    -- If the specified tag is allocated to another screen, we need to move it,
    -- or if the tag no longer belongs to a screen.
    if oldscreen ~= screen or not oldscreen then
        -- Try to find a new tag to show on the previous screen if the currently
        -- selected tag is the one that was moved away.
        if oldscreen then
            local oldsel = oldscreen.selected_tag
            tag.screen = screen

            if oldsel == tag then
                -- The tag has been moved away. In most cases the tag history
                -- function will find the best match, but if we really want we can
                -- try to find a fallback tag as well.
                if not oldscreen.selected_tag then
                    local newtag = awful.tag.find_fallback(oldscreen)
                    if newtag then
                        newtag:view_only()
                    end
                end
            end
        end

        -- Also sort the tag in the taglist, by reapplying the index. This is just a nicety.
        local unpack = unpack or table.unpack
        for _,s in ipairs({ screen, oldscreen or { tags = {} } }) do
            local tags = { unpack(s.tags) } -- Copy
            table.sort(tags, function(a, b) return a.sharedtagindex < b.sharedtagindex end)
            for i,t in ipairs(tags) do
                t.index = i
            end
        end

        return true
    end

    return false
end

--- View the specified tag on the specified screen.
-- @param tag The only tag to view.
-- @tparam[opt=awful.screen.focused()] number screen The screen to view the tag on.
function sharedtags.viewonly(tag, screen)
    sharedtags.movetag(tag, screen)
    tag:view_only()
end

--- Move focus to screen containing tag and view the tag on that screen
-- @param tag The tag to jump to.
function sharedtags.jumpto(tag)
    awful.screen.focus(tag.screen)
    tag:view_only()
end

--- Toggle the specified tag on the specified screen.
-- The tag will be selected if the screen changes, and toggled if it does not
-- change the screen.
-- @param tag The tag to toggle.
-- @tparam[opt=awful.screen.focused()] number screen The screen to toggle the tag on.
function sharedtags.viewtoggle(tag, screen)
    local oldscreen = tag.screen

    if sharedtags.movetag(tag, screen) then
        -- Always mark the tag selected if the screen changed. Just feels a lot
        -- more natural.
        tag.selected = true
        -- Update the history on the old and new screens.
        oldscreen:emit_signal("tag::history::update")
        tag.screen:emit_signal("tag::history::update")
    else
        -- Only toggle the tag unless the screen moved.
        awful.tag.viewtoggle(tag)
    end
end

return setmetatable(sharedtags, { __call = function(...) return sharedtags.new(select(2, ...)) end })

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
