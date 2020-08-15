
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan



    Bindings for the treetile layout

--]]

local awful = require("awful")
local gtable = require("gears.table")
local treetile = require("treetile")

local k = {
    m = "Mod4",
    c = "Mod1",
    a = "Control",
    s = "Shift",
    l = "j",
    r = "l",
    u = "i",
    d = "k",
}

local bindings = { }

function bindings.init(args)

    args = gtable.crush({
        stop_key           = 'Escape',
        start_callback     = function()
            require("naughty").notify {text="treetile editor start"}
        end,
        stop_callback      = function()
            require("naughty").notify {text="treetile editor stop"}
        end,
        root_keybindings = {
            { { k.m }, ",", function() end },
        },
        keybindings = {

            -- Focus (by direction)
            { {     }, k.u, function() awful.client.focus.bydirection("up") end },
            { {     }, k.d, function() awful.client.focus.bydirection("down") end },
            { {     }, k.l, function() awful.client.focus.bydirection("left") end },
            { {     }, k.r, function() awful.client.focus.bydirection("right") end },

            -- Move
            { { k.m }, k.u, function() awful.client.swap.global_bydirection("up") end },
            { { k.m }, k.d, function() awful.client.swap.global_bydirection("down") end },
            { { k.m }, k.l, function() awful.client.swap.global_bydirection("left") end },
            { { k.m }, k.r, function() awful.client.swap.global_bydirection("right") end },

            -- Resize
            { { k.s }, string.upper(k.u), function() awful.client.swap.global_bydirection("up") end },
            { { k.s }, string.upper(k.d), function() awful.client.swap.global_bydirection("down") end },
            { { k.s }, string.upper(k.l), function() awful.client.swap.global_bydirection("left") end },
            { { k.s }, string.upper(k.r), function() awful.client.swap.global_bydirection("right") end },

            -- Rotate
            { {     }, "r", function() treetile.rotate(client.focus) end },
            { { k.s }, "R", function() treetile.rotate_all(client.focus) end },

            -- Swap
            { {     }, "s", function() treetile.swap(client.focus) end },
            { { k.s }, "S", function() treetile.swap_all(client.focus) end },

            -- -- Layout manipulation
            -- { { k.m                }, " ", function()
            --     awful.layout.inc(1)
            --     awful.screen.focused()._layout_popup:show()
            -- end,
            --   { description = "select next layout", group = "layout" } },
            -- { { k.m, k.s           }, " ", function()
            --     awful.layout.inc(-1)
            --     awful.screen.focused()._layout_popup:show()
            -- end,
            --   { description = "select previous layout", group = "layout" } },

            -- -- Useless gaps
            -- { { k.a                }, k.d, function() awful.tag.incgap(beautiful.useless_gap/2) end,
            --   { description = "increase useless gap", group = "command mode" } },
            -- { { k.a                }, k.u, function() awful.tag.incgap(-beautiful.useless_gap/2) end,
            --   { description = "decrease useless gap", group = "command mode" } },
            --
            -- -- Useless gaps (precise)
            -- { { k.a, k.c           }, k.d, function() awful.tag.incgap(1) end,
            --   { description = "increase useless gap (percise)", group = "command mode" } },
            -- { { k.a, k.c           }, k.u, function() awful.tag.incgap(-1) end,
            --   { description = "increase useless gap (percise)", group = "command mode" } },
            --
            -- -- Client manipulation
            -- { {                    }, " ", function()
            --     if client.focus then
            --         client.focus.floating = not client.focus.floating
            --     end
            -- end },
            -- { {                    }, "z", function()
            --     if client.focus then client.focus:kill() end
            -- end },
            -- { {                    }, "o", function()
            --     if client.focus then client.focus:move_to_screen() end
            -- end },
            -- { {                    }, "t", function()
            --     if client.focus then client.focus.ontop = not client.focus.ontop end
            -- end },
            -- { {                    }, "s", function()
            --     if client.focus then client.focus.sticky = not client.focus.sticky end
            -- end },
            -- { {                    }, "n", function()
            --     if client.focus then client.focus.minimized = true end
            -- end },
            -- { {                    }, "m", function()
            --     if client.focus then util.toggle_maximized(client.focus) end
            -- end },
            -- { {                    }, "f", function()
            --     if client.focus then util.toggle_fullscreen(client.focus) end
            -- end },
            -- { { k.s                }, string.upper("n"), function()
            --     local c = awful.client.restore()
            --     if c then
            --         client.focus = c
            --         c:raise()
            --     end
            -- end },
            --
            -- -- Resize (ratio)
            -- { {                    }, "1", function() set_width_factor((1 / 2 + 2.5) / 10) end, },
            -- { {                    }, "2", function() set_width_factor((2 / 2 + 2.5) / 10) end, },
            -- { {                    }, "3", function() set_width_factor((3 / 2 + 2.5) / 10) end, },
            -- { {                    }, "4", function() set_width_factor((4 / 2 + 2.5) / 10) end, },
            -- { {                    }, "5", function() set_width_factor((5 / 2 + 2.5) / 10) end, },
            -- { {                    }, "6", function() set_width_factor((6 / 2 + 2.5) / 10) end, },
            -- { {                    }, "7", function() set_width_factor((7 / 2 + 2.5) / 10) end, },
            -- { {                    }, "8", function() set_width_factor((8 / 2 + 2.5) / 10) end, },
            -- { {                    }, "9", function() set_width_factor((9 / 2 + 2.5) / 10) end, },

        },
    }, args or { })

    return awful.keygrabber(args)

end

return bindings
