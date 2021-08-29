
---------------------------------------------------------- dependencies -- ;

local capi = {root=root}
local naughty = require('naughty')
local gears = require("gears")
local awful = require("awful")
local beautiful = require('beautiful')
local modkey = "Mod4"
local altkey = "Mod1"

local machina = require("machina.methods")
local backham = require("machina.backham")
local focus_by_direction = machina.focus_by_direction
local shift_by_direction = machina.shift_by_direction
local expand_horizontal = machina.expand_horizontal
local shuffle = machina.shuffle
local my_shifter = machina.my_shifter
local expand_vertical = machina.expand_vertical
local move_to = machina.move_to
local toggle_always_on = machina.toggle_always_on
local teleport_client = machina.teleport_client
local get_client_info = machina.get_client_info
local focus_by_index = machina.focus_by_index
local focus_by_number = machina.focus_by_number
local set_region = machina.set_region
local align_floats = machina.align_floats

---------------------------------------------------------- key bindings -- ;

local bindings = {
   awful.key({altkey},"Tab", shuffle("backward")),
   awful.key({altkey, "Shift"}, "Tab", shuffle("forward")),

   -- awful.key({modkey}, "#10", focus_by_number(1)),
   -- awful.key({modkey}, "#11", focus_by_number(2)),
   -- awful.key({modkey}, "#12", focus_by_number(3)),
   -- awful.key({modkey}, "#13", focus_by_number(4)),
   -- awful.key({modkey}, "#14", focus_by_number(5)),
   
   awful.key({modkey}, "[", shuffle("backward")),
   awful.key({modkey}, "]", shuffle("forward")),
   --▨ move

   -- awful.key({modkey}, "Tab", focus_by_index("backward")),
   -- awful.key({modkey, "Shift"}, "Tab", focus_by_index("forward")),

   awful.key({modkey}, ";", align_floats("right")),
   awful.key({modkey, "Shift"}, ";", align_floats("left")),
   --▨ alignment
   
   awful.key({modkey}, "x", function ()
      c = client.focus or nil
      if not c then return end
      if c.floating then c.minimized = true return end
      shuffle("backward")(c)
   end),

   awful.key({modkey, "Shift"}, "x", function ()
      c = client.focus or nil
      if not c then return end
      if c.floating then c.minimized = true return end
      shuffle("forward")(c)
   end),
   --▨ shuffle

   awful.key({modkey, "Shift"}, "[", my_shifter("backward")),
   awful.key({modkey, "Shift"}, "]", my_shifter("forward")),
   --▨ move

   awful.key({modkey, "Control"}, "[", my_shifter("backward", "swap")),
   awful.key({modkey, "Control"}, "]", my_shifter("forward", "swap")),
   --▨ swap

   awful.key({modkey}, "'", function ()
   naughty.notify({text=inspect(client.focus.transient_for)})
   end),
   --▨ shuffle

   awful.key({modkey}, "j", focus_by_direction("left")),
   awful.key({modkey}, "k", focus_by_direction("down")),
   awful.key({modkey}, "l", focus_by_direction("right")),
   awful.key({modkey}, "i", focus_by_direction("up")),
   --▨ focus

   awful.key({modkey, "Shift"}, "j", shift_by_direction("left")),
   awful.key({modkey, "Shift"}, "l", shift_by_direction("right")),
   awful.key({modkey, "Shift"}, "k", shift_by_direction("down")),
   awful.key({modkey, "Shift"}, "i", shift_by_direction("up")),
   --▨ move

   awful.key({modkey, "Control"}, "j", shift_by_direction("left", "swap")),
   awful.key({modkey, "Control"}, "l", shift_by_direction("right", "swap")),
   awful.key({modkey, "Control"}, "k", shift_by_direction("down", "swap")),
   awful.key({modkey, "Control"}, "i", shift_by_direction("up","swap")),
   --▨ swap

   awful.key({modkey}, "Insert", move_to("top-left")),
   awful.key({modkey}, "Delete", move_to("bottom-left")),
   awful.key({modkey}, "u", expand_horizontal("center")),
   awful.key({modkey}, "Home", expand_horizontal("center")),
   awful.key({modkey}, "Page_Up", move_to("top-right")),
   awful.key({modkey}, "Page_Down", move_to("bottom-right")),
   --▨ move (positional)

   awful.key({modkey, "Shift"}, "Insert", expand_horizontal("left")),
   awful.key({modkey, "Shift"}, "End", toggle_always_on),
   awful.key({modkey, "Shift"}, "Home", move_to("center")),
   awful.key({modkey, "Shift"}, "Page_Up", expand_horizontal("right")),
   awful.key({modkey, "Shift"}, "Page_Down", expand_vertical),
   --▨ expand (neighbor)

   awful.key({modkey}, "End", function(c) 
      client.focus.maximized_vertical = false
      client.focus.maximized_horizontal = false
      awful.client.floating.toggle()
   end), --|toggle floating status

   awful.key({modkey}, "Left", focus_by_direction("left")),
   awful.key({modkey}, "Down", focus_by_direction("down")),
   awful.key({modkey}, "Right", focus_by_direction("right")),
   awful.key({modkey}, "Up", focus_by_direction("up")),
   --▨ focus

   awful.key({modkey,}, "o", teleport_client), --|client teleport to other screen

}

--------------------------------------------------------------- signals -- ;

tag.connect_signal("property::selected", function(t)
   if client.focus == nil then
      local s = awful.screen.focused()
      client.focus = awful.client.focus.history.get(s, 0)
   end
end) --|ensure there is always a selected client during tag
     --|switching or logins


client.connect_signal("manage", function(c)
   c.maximized = false
   c.maximized_horizontal = false
   c.maximized_vertical = false
end) --|during reload maximized clients get messed up, as machi
     --|also tries to best fit the windows. this resets the
     --|maximized state during a reload problem is with our hack
     --|to use maximized, we should look into using machi
     --|resize_handler instead

client.connect_signal("request::activate", function(c) 
   c.hidden = false
   -- c.minimized = false
   c:raise()
   client.focus = c
end) --|this is needed to ensure floating stuff becomes
     --|visible when invoked through run_or_raise.

client.connect_signal("focus", function(c)
if not (c.bypass or c.always_on) then
   if not c.floating then
      for _, tc in ipairs(screen[awful.screen.focused()].all_clients) do
         if tc.floating and not tc.always_on then
            tc.hidden = true
         end
      end
      return
   end

   if c.floating then
      for _, tc in ipairs(screen[awful.screen.focused()].all_clients) do
         if tc.floating and not tc.role then
            tc.hidden = false
         end
      end
      return
   end
end
end)
--[[+]
   hide all floating windows when the user switches to a tiled
   client. This is handy when you have a floating browser
   open. Unless, client is set to always_on or bypass through
   rules. ]]


--------------------------------------------------------------- exports -- ;

module = {
   bindings = bindings
}

local function new(arg)
   capi.root.keys(awful.util.table.join(capi.root.keys(), table.unpack(bindings)))
   return module
end

return setmetatable(module, { __call = function(_,...) return new({...}) end })