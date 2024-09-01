local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local lain = require("lain")
local markup = lain.util.markup
local capi = {
    awesome = awesome,
    screen = screen,
    client = client
}

local standard_taglist = {}
local theme
local tags
local update_tag

function standard_taglist.init_environment(dsconfig)
    theme = dsconfig.theme
    tags = {
        icons = {
            "", "", "", "", "懲", "", "󰈸", "󰇧", ""
        },
        names = { "/main", "/w3", "/apps", "/dev", "/water", "/air", "/fire", "/earth", "/love" },
        layouts = {
            awful.layout.layouts[13],   --main
            awful.layout.layouts[2],    --www (machi)
            awful.layout.layouts[2],    --apps (machi)
            awful.layout.suit.floating, --idea
            awful.layout.layouts[11],   --water (machi to empty placement)
            awful.layout.layouts[8],    --air
            awful.layout.layouts[5],    --fire (center-work)
            awful.layout.layouts[6],    --earth (termfair)
            awful.layout.layouts[9]     --love
        }
    }

    -- Each screen has its own tag table.
    local tagCount = dsconfig.isFullhd and 4 or #tags.names
    for ss = 1, capi.screen.count() do
        tags[ss] = awful.tag({ table.unpack(tags.names, 1, tagCount) }, ss, { table.unpack(tags.layouts, 1, tagCount) })
        -- Set additional optional parameters for each tag
        --tags[s][1].column_count = 2
    end

    -- Taglist Callbacks
    update_tag = function(self, c3, index, objects)
        local focused = false
        for _, x in pairs(awful.screen.focused().selected_tags) do
            if x.index == index then
                focused = true
                break
            end
        end
        local color
        if focused then
            color = theme.bg_underline
        else
            color = theme.bg_normal
        end
        local tagBox = self:get_children_by_id("overline")[1]
        local iconBox = self:get_children_by_id("icon_text_role")[1]
        iconBox:set_markup(markup.fontfg(theme.font_larger, theme.baseColors[index], tags.icons[index]))
        tagBox.bg = color
    end
end

function standard_taglist.create(s)
    -- TAGLIST COMPONENT
    -- Create a taglist widget
    return awful.widget.taglist {
        screen          = s,
        filter          = awful.widget.taglist.filter.all,
        buttons         = {
            awful.button({}, 1, function(t) t:view_only() end),
            awful.button({ modkey }, 1, function(t)
                if capi.client.focus then
                    capi.client.focus:move_to_tag(t)
                end
            end),
            awful.button({}, 3, awful.tag.viewtoggle),
            awful.button({ modkey }, 3, function(t)
                if capi.client.focus then
                    capi.client.focus:toggle_tag(t)
                end
            end),
            awful.button({}, 4, function(t) awful.tag.viewprev(t.screen) end),
            awful.button({}, 5, function(t) awful.tag.viewnext(t.screen) end),
        },
        widget_template = {
            {
                {
                    layout = wibox.layout.fixed.vertical,
                    {
                        layout = wibox.layout.fixed.horizontal,
                        {
                            {
                                id = 'icon_text_role',
                                widget = wibox.widget.textbox
                            },
                            left = 7,
                            right = 0,
                            top = 0,
                            bottom = -2,
                            widget = wibox.container.margin
                        },
                        {
                            {
                                id = 'text_role',
                                widget = wibox.widget.textbox
                            },
                            top = 0,
                            right = 7,
                            bottom = -2,
                            widget = wibox.container.margin
                        }
                    },
                    {
                        {
                            top = 0,
                            bottom = 3,
                            widget = wibox.container.margin
                        },
                        id = 'overline',
                        bg = theme.bg_normal,
                        shape = gears.shape.rectangle,
                        widget = wibox.container.background
                    }
                },
                widget = wibox.container.margin
            },
            id = 'background_role',
            bg = theme.bg_normal,
            fg = theme.fg_normal,
            widget = wibox.container.background,
            shape = gears.shape.rectangle,
            create_callback = update_tag,
            update_callback = update_tag
        },
    }
end

-- Optional Standard Tags Shortcuts
function standard_taglist.keys(s)
end

return standard_taglist
