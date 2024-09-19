local awful = require("awful")
local sharedtags = require("sharedtags")

local shared_taglist = {}
local tags

function shared_taglist.init_environment(dsconfig)
    -- Define layouts and shared tags with dynamic screen assignment
    tags = sharedtags({
        { bidx = 1,   name = "1",                      screen = 1, layout = awful.layout.layouts[13] },
        { bidx = 2,   name = "2",                      screen = 1, layout = awful.layout.layouts[2] },
        { bidx = 3,   name = "3",                      screen = 1, layout = awful.layout.layouts[2] },
        { bidx = 4,   name = "4",                      screen = 1, layout = awful.layout.suit.floating },
        { bidx = 5,   name = "5",                      screen = 2, layout = awful.layout.layouts[12] },
        { bidx = 6,   name = "6",                      screen = 2, layout = awful.layout.layouts[12] },
        { bidx = 7,   name = "7",                      screen = 2, layout = awful.layout.layouts[2] },
        { bidx = 8,   name = "8",                      screen = 2, layout = awful.layout.layouts[2] },
        { bidx = 9,   name = "9",                      screen = 1, layout = awful.layout.layouts[9] },
    })
end

function shared_taglist.create(s)
    -- Create the shared taglist widget
    return awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = {
            awful.button({}, 1, function(t) t:view_only() end),
            awful.button({ modkey }, 1, function(t)
                if client.focus then
                    client.focus:move_to_tag(t)
                end
            end),
            awful.button({}, 3, awful.tag.viewtoggle),
            awful.button({ modkey }, 3, function(t)
                if client.focus then
                    client.focus:toggle_tag(t)
                end
            end),
            awful.button({}, 4, function(t) awful.tag.viewprev(t.screen) end),
            awful.button({}, 5, function(t) awful.tag.viewnext(t.screen) end),
        }
    }
end

-- Optional Shared Tags Shortcuts
function shared_taglist.keys(s)
    -- Shared Tags Keybindings
    for i = 1, 9 do
        awful.keyboard.append_global_keybindings({
            -- View tag only.
            awful.key({ modkey }, "#" .. i + 9,
                function()
                    local screen = awful.screen.focused()
                    local tag = tags[i]
                    if tag then
                        sharedtags.viewonly(tag, screen)
                    end
                end,
                { description = "view tag #" .. i, group = "tag" }),
            -- Toggle tag display.
            awful.key({ modkey, ctrlkey }, "#" .. i + 9,
                function()
                    local screen = awful.screen.focused()
                    local tag = tags[i]
                    if tag then
                        sharedtags.viewtoggle(tag, screen)
                    end
                end,
                { description = "toggle tag #" .. i, group = "tag" }),
            -- Move client to tag.
            awful.key({ modkey, "Shift" }, "#" .. i + 9,
                function()
                    if client.focus then
                        local tag = tags[i]
                        if tag then
                            client.focus:move_to_tag(tag)
                        end
                    end
                end,
                { description = "move focused client to tag #" .. i, group = "tag" }),
            -- Toggle tag on focused client.
            awful.key({ modkey, ctrlkey, "Shift" }, "#" .. i + 9,
                function()
                    if client.focus then
                        local tag = tags[i]
                        if tag then
                            client.focus:toggle_tag(tag)
                        end
                    end
                end,
                { description = "toggle focused client on tag #" .. i, group = "tag" })
        })
    end
end

return shared_taglist
