
--------------------------------------------------------- dependencies  -- ;

local naughty = require('naughty')
local gears = require("gears")
local awful = require("awful")
local beautiful = require('beautiful')
local grect = gears.geometry.rectangle

local tabs = require("machina.tabs")
local geoms = require("machina.geoms")
local helpers = require("machina.helpers")

local get_client_ix = helpers.get_client_ix
local getlowest = helpers.getlowest
local compare = helpers.compare
local tablelength = helpers.tablelength
local set_contains = helpers.set_contains
local clear_tabbar = helpers.clear_tabbar

---------------------------------------------------------------- locals -- ;

local global_client_table = {}
local global_widget_table = {}

function double_click_event_handler(double_click_event)
    if double_click_timer then
        double_click_timer:stop()
        double_click_timer = nil
        double_click_event()
        return
    end
    beautiful.layout_machi = machi.get_icon()
    double_click_timer = gears.timer.start_new(0.20, function()
        double_click_timer = nil
        return false
    end)
end


function get_global_clients()
   return global_client_table
end

function update_global_clients(c)
   global_client_table[c.window] = c
end

----------------------------------------------------- reset_client_meta -- ;

local function reset_client_meta(c)
   c.maximized = false
   c.maximized_horizontal = false
   c.maximized_vertical = false
   c.direction = nil
   return c
end

--------------------------------------------------- reset_all_clients() -- ;

local function reset_all_clients(s)
   local s = s or awful.screen.focused()
   for i,c in pairs(s.clients) do
      reset_client_meta(c)
   end
end

---------------------------------------------------------- set_region() -- ;

local function set_region(region, c)
   local c = c or client.focus or nil
   if c then 
      c.region = region end
end

------------------------------------------ get_visible_floating_clients -- ;

local function get_all_floating_clients(s)
   local s = s or awful.screen.focused(s)
   local les_visibles = {}

   for i,p in pairs(s.all_clients) do
      if p.floating then
         les_visibles[#les_visibles+1] = p
      end
   end

   return les_visibles
end


local function get_visible_floating_clients(s)
   local s = s or awful.screen.focused(s)
   local les_visibles = {}

   for i,p in pairs(s.all_clients) do
      if p.floating and (p.always_on or p.bypass) and p:isvisible() then
         les_visibles[#les_visibles+1] = p
      end
   end

   return les_visibles
end

---------------------------------------------------- get_space_around() -- ;

local function get_space_around(c)
   if not c then return nil end

   local c = c or nil
   local s = awful.screen.focused()

   local space_around = {
      left=c.x,
      right=s.workarea.width - (c.x + c.width),
      top=s.workarea.height - (c.y),
      bottom=s.workarea.height - (c.y + c.height),
   }

   return space_around
end

-------------------------------------------------------- align_floats() -- ;

local function align_floats(direction)
   return function (c)
      local s = s or awful.screen.focused()
      local c = client.focus or nil
      local direction = direction or "right"

      local space_around = get_space_around(c)
      local cs = get_all_floating_clients(s)

      if not c then return end
      --|flow control

      if space_around.right < 300 
         and space_around.left < 300 then
         return
      end --|flow control


      for i,p in pairs(cs) do
         if p.window == c.window then goto next end
         --|if c itself if it is actually floating
          
         if space_around.right < 300 and direction == "right" then 
            direction = "left"
         end

         if space_around.left < 300 and direction == "left" then 
            direction = "right"
         end --|flow control, nothing to do

         if direction == "right" then
            if (p.width) > space_around.right then
               p.width = space_around.right
            end
            --|resize if necessary
            
            p:geometry({x=c.x+c.width, y=c.y})
            --|place x on the right
         end

         if direction == "left" then
            if p.width > space_around.left then
               p.width = space_around.left
            end
            --|resize if necessary

            p:geometry({x=space_around.left - p.width, y=c.y})
            --|place x on the left
         end

         if direction == "left" then direction = "right" end
         if direction == "right" then direction = "left" end

         p.hidden = false
         p:raise()
         -- p:emit_signal("request::activate")
         --|bring float up


         awful.placement.no_offscreen(p)
         --|ensure everything is visible

         ::next::
      end
      
      client.focus = c
      --|keep focus at the originating client
   end
end
--|this will spread out floating clients to the left or
--|right of the focused client, can refactor most of this later.
--|perhaps it is better to limit this to visible floats only.
--|perhaps it would be better to keep the position and geometry
--|of the floats prior to aligning them, so that they can appear
--|where they used to be later.

------------------------------------------------------------- go_edge() -- ;

local function go_edge(direction, regions, current_box)
   test_box = true
   edge_pos = nil

   while test_box do
      test_box = grect.get_in_direction(direction, regions, current_box)

      if test_box then
         current_box = regions[test_box]
         edge_pos = test_box
      end
   end

   return edge_pos
end --|
    --|figures out the beginning of each row on the layout.

----------------------------------------------------------- always_on() -- ;

local function toggle_always_on()
   always_on = nil or client.focus.always_on
   client.focus.always_on = not always_on
end

--------------------------------------------------------- screen_info() -- ;

local function screen_info(s)
   local s = s or awful.screen.focused()
   local focused_screen = s or nil
   local workarea = s.workarea or nil
   local selected_tag = s.selected_tag or nil
   local layout = awful.layout.get(s) or nil
   local focused_client = client.focus or nil

   return focused_screen,
      workarea,
      selected_tag,
      layout,
      focused_client
end


---------------------------------------------------------- get_region() -- ;

local function get_region(region_ix, s)
   local s = s or awful.screen.focused()
   local focused_screen,
         workarea,
         selected_tag,
         layout,
         focused_client = screen_info(s)

   local machi_fn = nil
   local machi_data = nil
   local machi_regions = nil

   if layout.machi_get_regions then
      machi_fn = layout.machi_get_regions
      machi_data = machi_fn(workarea, selected_tag)
      machi_regions = machi_data
   end --|version 1

   if layout.machi_get_instance_data then
      machi_fn = layout.machi_get_instance_data
      machi_geom = layout.machi_set_geometry
      machi_data = {machi_fn(screen[focused_screen], selected_tag)}
      machi_regions = machi_data[3]
   
      for i=#machi_regions,1,-1 do
         if machi_regions[i].habitable == false  then
            table.remove(machi_regions, i)
         end
      end --|remove unhabitable regions

      table.sort(
         machi_regions,
         function (a1, a2)
            return a1.id > a2.id
         end
      ) --|v2 returns unordered region list and needs sorting.
   end --|version 2/NG

   return machi_regions[region_ix]
end

--------------------------------------------------------- get_regions() -- ;

local function get_regions(s)
   local s = s or awful.screen.focused()
   local focused_screen,
         workarea,
         selected_tag,
         layout,
         focused_client = screen_info(s)

   local machi_fn = nil
   local machi_data = nil
   local machi_regions = nil

   if layout.machi_get_regions then
      machi_fn = layout.machi_get_regions
      machi_data = machi_fn(workarea, selected_tag)
      machi_regions = machi_data
   end --|version 1

   if layout.machi_get_instance_data then
      machi_fn = layout.machi_get_instance_data
      machi_geom = layout.machi_set_geometry
      machi_data = {machi_fn(screen[focused_screen], selected_tag)}
      machi_regions = machi_data[3]
   
      for i=#machi_regions,1,-1 do
         if machi_regions[i].habitable == false  then
            table.remove(machi_regions, i)
         end
      end --|remove unhabitable regions

      table.sort(
         machi_regions,
         function (a1, a2)
            return a1.id > a2.id
         end
      ) --|v2 returns unordered region list and needs sorting.
   end --|version 2/NG

   return machi_regions, machi_fn
end

------------------------------------------------------- get_client_info -- ;

local function get_client_info(c)
   local c = c or client.focus or nil
   local s = s or c.screen or nil
   local source_client = c
   local active_region = nil
   local outofboundary = nil
   local proximity = {}

   if not source_client then return {} end
   --|flow control

   if source_client.x < 0 or source_client.y < 0 
      then outofboundary = true 
   end --| negative coordinates always mean out of boundary

   local regions = get_regions(s)
   --|get regions on the screen
   
   if not regions then return {} end
   --|flow control

   for i, a in ipairs(regions) do
      local px = a.x - source_client.x
      local py = a.y - source_client.y

      if px == 0 then px = 1 end
      if py == 0 then py = 1 end

      proximity[i] = {
         index = i,
         v = math.abs(px * py)
      } --│keep track of proximity in case nothing matches in
        --│this block.

   end --│figures out focused client's region under normal
       --│circumstances.

   if not active_region then
      table.sort(proximity, compare)       --| sort to get the smallest area
      active_region = proximity[1].index   --| first item should be the right choice

      if source_client.floating then
         if regions[active_region].width - source_client.width ~= 0
            or regions[active_region].height - source_client.height ~= 0
         then
            outofboundary = true
         end
      end --|when client is not the same size as the located
          --|region, we should still consider this as out of
          --|boundary
   end --|user is probably executing get_active_regions on a
       --|floating window.

   if not active_region then
      active_region = 1
   end --|at this point, we are out of options, set the index
       --|to one and hope for the best.


   -- refactor
   if active_region and source_client.width > regions[active_region].width then
      outofboundary = true
   end --|machi sometimes could auto expand the client, consider
       --|that as out of boundary.

   if active_region and source_client.height > regions[active_region].height then
      outofboundary = true
   end --|machi sometimes could auto expand the client, consider
       --|that as out of boundary.
   -- refactor

   active_region_geom = {
      width=regions[active_region].width-regions[active_region].width/2,
      height=regions[active_region].height-regions[active_region].height/2
   }

   return {
      active_region = active_region,
      active_region_geom = active_region_geom,
      regions = regions,
      outofboundary = outofboundary,
      tags = c:tags()
   }
end

------------------------------------------------------------- move_to() -- ;

local function move_to(location)
   return function()
      local c = client.focus or nil

      if not c then return end
      --▨ flow control

      local c = reset_client_meta(client.focus)
      local ci = get_client_info(c)
      local useless_gap = nil
      local regions = get_regions()
      local edges = {x={},y={}}
      
      local is = {
         region=ci.active_region,
         region_geom=ci.active_region_geom
      }

      for i,region in ipairs(regions) do
         edges.x[region.x] = region.x + region.width
         edges.y[region.y] = region.y + region.height
      end
      
      useless_gap = getlowest(edges.x)

      if client.focus.floating then
         client.focus:geometry(geoms[location](useless_gap))
      end

      if not client.focus.floating then

         -- todo: set actual destination region geometry
         -- this is not okay and buggy
         -- or at least set it up to use directional shifting
         -- to match left, right, center

         local tobe_geom = geoms[location](useless_gap)
         tobe_geom.width = 300
         tobe_geom.height = 600

         local tobe = {
            region=get_client_info(client.focus).active_region,
         }

         client.focus:geometry(tobe_geom)

         resize_region_to_index(is.region, is.region_geom, true)

         draw_tabbar(is.region)

         gears.timer.delayed_call(function ()
            client.focus.region = tobe.region
            draw_tabbar(tobe.region)
         end)
      end --| redraw tabs and update meta

      return
   end
end

----------------------------------------- focus_by_direction(direction) -- ;

local function focus_by_direction(direction)
   return function()
      if not client.focus then return false end
      awful.client.focus.global_bydirection(direction, nil,true)
      client.focus:raise()
   end
end

----------------------------------------------- get_clients_in_region() -- ;

local function get_punched_clients(region_ix, s)
   local s = s or awful.screen.focused()
   local active_region = region_ix or nil
   local region = get_region(region_ix, s)
   local region_clients = {}

   if #region_clients == 0 then
      for i, w in ipairs(s.clients) do
         if not w.floating then
            if w.region == region_ix then
               region_clients[#region_clients + 1] = w
            end
         end
      end --|try to get clients based on simple coordinates
   end

   return region_clients
end --|try to get clients in a region using three different
    --|algorithms.


local function get_clients_in_region(region_ix, c, s)
   local c = c or client.focus or nil
   local s = s or c.screen or awful.screen.focused()
   local source_client = c or client.focus or nil
   local source_screen = s or (source_client and source_client.screen)
   local active_region = region_ix or nil
   local regions = get_regions(s)
   local region_clients = {}

   if not active_region then
      for i, a in ipairs(regions) do
         if a.x <= source_client.x and source_client.x < a.x + a.width and
            a.y <= source_client.y and source_client.y < a.y + a.height
         then
            active_region = i
         end
      end
   end --|if no region index was provided, find the 
       --|region of the focused_client.

   
   if not active_region then
      return
   end

   if #region_clients == 0 then
      for i, w in ipairs(s.clients) do
         if not (w.floating) then
            if (
                  math.abs(regions[active_region].x - w.x) <= 5 and
                  math.abs(regions[active_region].y - w.y) <= 5
               )
               -- or 
               -- ( 
               --    regions[active_region].x ~= w.x and
               --    w.region == region_ix 
               -- ) --|handle resizing left expanded regions
            then
               region_clients[#region_clients + 1] = w
               w.region = region_ix
               --|this basically will fix any inconsistency
               --|along the way.
            end
         end
      end --|try to get clients based on simple coordinates
   end

   -- if #region_clients == 0 then
   --    for i, cc in pairs(s.clients) do
   --       if cc.region == active_region 
   --          and regions[active_region].x == cc.x 
   --          and regions[active_region].y == cc.y 
   --          then
   --          region_clients[#region_clients + 1] = cc
   --       end
   --    end 
   -- end --| this logic compares c.region to global client index.
   --     --| if we somehow fail to update c.region somewhere
   --     --| shuffle shortcuts won't work with this one.


   -- if #region_clients == 0 then
   --    for _, cc in ipairs(s.clients) do
   --       if not (cc.floating) then
   --          if regions[active_region].x <= cc.x + cc.width + cc.border_width * 2 
   --             and cc.x <= (regions[active_region].x + regions[active_region].width) 
   --             and regions[active_region].y <= (cc.y + cc.height + cc.border_width * 2)
   --             and cc.y <= (regions[active_region].y + regions[active_region].height)
   --          then
   --             region_clients[#region_clients + 1] = cc
   --          end
   --       end
   --    end 
   -- end --|this logic works with coordinates more throughly but
   --     --|it also causes issues with overflowing
   --     --|(expanded) clients.

   return region_clients
end --|try to get clients in a region using three different
    --|algorithms.

----------------------------------------------------- expand_horizontal -- ;

local function expand_horizontal(direction)
   return function ()
      local c = client.focus
      local geom = nil

      if c.maximized_horizontal then 
         c.maximized_horizontal = false
      end --|reset toggle maximized state

      if c.direction == direction then
         c.direction = nil
         c.maximized_horizontal = false
         c.maximized_vertical = false

         if not c.floating then
            resize_region_to_index(c.region, true, true)
            draw_tabbar(c.region)

            gears.timer.weak_start_new(0.1,function ()
               client_under_mouse = mouse.current_client

               if client_under_mouse then
                  client.focus = mouse.current_client   
               end
            end) --|when toggling leave the focus
                 --|to the client under the pointer
         end

         return
      end --|reset toggle when sending the same
          --|shortcut consequitively.

      local stuff = get_client_info()
      local target = grect.get_in_direction(direction, stuff.regions, client.focus:geometry())
      
      if not target and direction ~= "center" then return end -- flow control

      --▨▨▨
      if direction == "right" then
         tobe = {
            x=c.x,
            width=math.abs(stuff.regions[target].x + stuff.regions[target].width - c.x - 4),
            height=c.height,
            y=c.y
         }

         c.direction = direction
         c.maximized_horizontal = true
         c.maximixed_vertical = false

         gears.timer.delayed_call(function (c)
            c:geometry(tobe)
            resize_region_to_client(c, {horizontal=true,vertical=false,direction=direction})
         end,c)
         return
      end

      --▨▨▨
      if direction == "left" then
         tobe = {
            x=stuff.regions[target].x,
            width=c.x + c.width - stuff.regions[target].x,
            height=c.height,
            y=c.y
         }

         c.direction = direction
         c.maximized_horizontal = true
         c.maximixed_vertical = false

         gears.timer.delayed_call(function (c) 
            c:geometry(tobe)
            resize_region_to_client(c, {horizontal=true,vertical=false,direction=direction})
         end,c)
         return
      end
     
      --▨▨▨
      if direction == "center" then
         c.maximized = false
         c.maximixed_vertical = false
         fixedchoice = geoms.clients[c.class] or nil

         if c.floating then
            c.maximized_horizontal = false
            geom = geoms.crt43()
         end

         if not c.floating then
            c.direction = "center"
            c.maximized_horizontal = true
            geom = geoms.p1080()
         end

         if fixedchoice and not c.floating then
            c.direction = "center"
            c.maximized_horizontal = true
            geom = fixedchoice()
         end

         c:geometry(geom)
         awful.placement.centered(c)

         client.focus = nil
         --|allow micky to move the mouse

         gears.timer.delayed_call(function (c)
            client.focus = c
            --|allow micky to move the mouse
            
            c:raise()
            client.emit_signal("tabbar_draw", c.region)
            clear_tabbar(c)
         end,c) --|give it time in case maximize_horizontal is
              --|adjusted before centering
         return
      end
   end
end
--|c.direction is used to create a fake toggling effect.
--|tiled clients require an internal maximized property to
--|be set, otherwise they won't budge.

----------------------------------------------------- expand_vertical() -- ;

local function expand_vertical()
   local c = client.focus
   local going = "down"

   if c.maximized_vertical then 
      
      if not c.floating then
         -- draw_tabbar(c.region)
         resize_region_to_index(c.region, true, true)
      end

      return
   end --|reset toggle when sending same shortcut
       --|consequitively

   local stuff = get_client_info()
   local target = grect.get_in_direction("down", stuff.regions, client.focus:geometry())
   
   if target and stuff.regions[target].x ~= c.x then
      return
   end --|flow control
       --|ensure we are operating in the same X axis,
       --|vertical directions jump around

   if not target then
      going = "up"
      target = grect.get_in_direction("up", stuff.regions, client.focus:geometry())
   end --|flow control
       --|try reverse direction

   if not target then return end
   --|flow control
   
   if going == "down" then
      tobe = {
         y=c.y,
         x=c.x,
         width=c.width,
         height=stuff.regions[target].y + stuff.regions[target].height - c.y
      }
   end

   if going == "up" then
      tobe = {
         x=c.x,
         width=c.width,
         y=stuff.regions[target].y,
         height= c.height + c.y - stuff.regions[target].y
      }
   end

   c.maximized_vertical = true

   gears.timer.delayed_call(function () 
      client.focus:raise()
      client.focus:geometry(tobe)   
      resize_region_to_client(c, {horizontal=false,vertical=true,direction=direction})
   end)

   return
end

------------------------------------------------------------- shuffle() -- ;

local function shuffle(direction)
   return function()
      if not client.focus then return end
      --▨ flow control

      local tablist = get_piled_clients(client.focus.region)
      --|this is the ordered list

      if not #tablist then return end
      --▨ flow control

      focused_client_ix = get_client_ix(client.focus.window, tablist)
      --|find the index position of the focused client

      if not focused_client_ix then return end
      --▨ flow control

      prev_ix = focused_client_ix - 1
      next_ix = focused_client_ix + 1
      --|calculate target indexes

      if next_ix > #tablist then next_ix = 1 end
      if prev_ix < 1 then prev_ix = #tablist end
      --|check for validity of the index

      if direction == "backward" then
         tablist[prev_ix]:emit_signal("request::activate", "mouse_enter",{raise = true})
         return
      end

      if direction == "forward" then
         tablist[next_ix]:emit_signal("request::activate", "mouse_enter",{raise = true})
         return
      end
   end
end

---------------------------------------------------------- get_swapee() -- ;

local function get_swapee(target_region_ix)
   local regions = get_regions()
   --| all regions

   local cltbl = awful.client.visible(client.focus.screen, true)
   --| all visible clients on all regions
   --| but we don't know which regions they are at
   
   local swap_map = {}

   for a,region in ipairs(regions) do
      for i,c in ipairs(cltbl) do
         if c.x == region.x and c.y == region.y then
            swap_map[a] = i
            break --|avoid stacked regions
         end
      end
   end --|iterate over regions, and match the client objects in
       --|each region.

   local swapee = cltbl[swap_map[target_region_ix]]
   return swapee
end
--[[
   returns the client object at a specific region. we can
   also use signals to keep track of this but we are trying
   to avoid exessive use of signals.
--]]

---------------------------------------------------------- my_shifter() -- ;

local function focus_by_number(region_ix,s)
   return function()
      local s = s or awful.screen.focused()
      local regions = get_regions(s)

      local target_region_ix
      local target_region

      local swapee = get_swapee(region_ix)
      --|visible client at the target region

      swapee:emit_signal("request::activate", "mouse_enter",{raise = true})
   end   
end

local function focus_by_index(direction)
   return function()

      if direction == "left" then direction = "backward" end
      if direction == "right" then direction = "forward" end

      local c = client.focus
      local stuff = get_client_info()
      local client_region_ix = stuff.active_region
      local source_region
      local target_region_ix
      local target_region

      c = reset_client_meta(c)
      --|clean artifacts in case client was expanded.
   
      if direction == "backward" then
         if (client_region_ix + 1) > #stuff.regions then 
            target_region_ix = 1
         else
            target_region_ix = client_region_ix+1
         end
      end --|go next region by index, 
          --|if not reset to first

      if direction == "forward" then
         if (client_region_ix - 1) < 1 then 
            target_region_ix = #stuff.regions
         else
            target_region_ix = client_region_ix - 1
         end
      end --|go previous region by index,
          --|if not reset to last
     
      local swapee = get_swapee(target_region_ix)
      --|visible client at the target region

      swapee:emit_signal("request::activate", "mouse_enter",{raise = true})
   end   
end


local function my_shifter(direction, swap)
   return function()

      if direction == "left" then direction = "backward" end
      if direction == "right" then direction = "forward" end

      local c = client.focus
      local stuff = get_client_info()
      local client_region_ix = stuff.active_region
      local source_region
      local target_region_ix
      local target_region

      c = reset_client_meta(c)
      --|clean artifacts in case client was expanded.
   
      if direction == "backward" then
         if (client_region_ix + 1) > #stuff.regions then 
            target_region_ix = 1
         else
            target_region_ix = client_region_ix+1
         end
      end --|go next region by index, 
          --|if not reset to first

      if direction == "forward" then
         if (client_region_ix - 1) < 1 then 
            target_region_ix = #stuff.regions
         else
            target_region_ix = client_region_ix - 1
         end
      end --|go previous region by index,
          --|if not reset to last

      if stuff.outofboundary then
         target_region_ix = client_region_ix
      end --|ignore previous when out of boundary
          --|probably floating or expanded client
          --|push inside the boundary instead

      source_region = stuff.regions[client_region_ix]
      target_region = stuff.regions[target_region_ix]
      --|target regions geometry

      local swapee = get_swapee(target_region_ix)
      --|visible client at the target region

      c:geometry(target_region)
      --|relocate client

      c.region = target_region_ix
      --|update client property

      if not swap then c:raise() end
      --|raise

      if swap and swapee then
         swapee:geometry(source_region)
         swapee:emit_signal("request::activate", "mouse_enter",{raise = true})
      end --|perform swap

      draw_tabbar(target_region_ix)
      resize_region_to_index(target_region_ix, target_region, true)
      --|update tabs in target region
      
      draw_tabbar(client_region_ix)
      resize_region_to_index(client_region_ix, source_region, true)
      --|update tabs in source region
   end   
end

---------------------------------------------------- shift_by_direction -- ;

local function shift_by_direction(direction, swap)
   return function ()

      local c = client.focus
      local stuff = get_client_info()
      local target_region_ix = nil
      local client_region_ix = stuff.active_region

      if stuff.outofboundary == true then
         return my_shifter(direction)()
      end --|my_shifter handles this situation better.

      local candidate = {
         up = grect.get_in_direction("up", stuff.regions, client.focus:geometry()),
         down = grect.get_in_direction("down", stuff.regions, client.focus:geometry()),
         left = grect.get_in_direction("left", stuff.regions, client.focus:geometry()),
         right = grect.get_in_direction("right", stuff.regions, client.focus:geometry())
      }

      target_region_ix = candidate[direction]
      --|try to get a candidate region if possible

      if not target_region_ix then
         if direction == "right" then try = "left" end
         if direction == "left" then try = "right" end
         if direction == "down" then try = "up" end
         if direction == "up" then try = "down" end

         target_region_ix = go_edge(try, stuff.regions, client.focus:geometry())
      end --|go the beginning or the end if there is no
          --|candidate
      
      source_region = stuff.regions[client_region_ix]
      target_region = stuff.regions[target_region_ix]

      local swapee = get_swapee(target_region_ix)
      --|visible client at the target region

      c:geometry(target_region)
      --|relocate client

      c.region = target_region_ix
      --|update client property

      if not swap then c:raise() end
      --|raise

      if swap and swapee then
         swapee:geometry(source_region)
         swapee:emit_signal("request::activate", "mouse_enter",{raise = true})
         swapee.region = client_region_ix
      end --|perform swap, update meta

      draw_tabbar(target_region_ix)
      resize_region_to_index(target_region_ix, target_region, true)
      --|update tabs in target region
      
      draw_tabbar(client_region_ix)
      resize_region_to_index(client_region_ix, source_region, true)
      --|update tabs in source region
   end
end

----------------------------------------------------- get_tiled_clients -- ;

function get_piled_clients(region_ix, s)
   local s = s or client.focus.screen or awful.screen.focused()
   local tablist = get_punched_clients(region_ix, s)
   local all_clients = get_global_clients()
   local tiled_clients = {}
   local myorder = {}
   local window_ix = {}

   for i,t in ipairs(tablist) do
      window_ix[t.window] = true
   end

   local po = 1
   for i,c in pairs(all_clients) do
      if not c.floating and window_ix[c.window] then
            tiled_clients[po] = c
         po = po + 1
      end
   end

   return tiled_clients
end --[23]


function get_tiled_clients(region_ix, s)
   local s = s or client.focus.screen or awful.screen.focused()
   local tablist = get_clients_in_region(region_ix, c, s)
   local all_clients = get_global_clients()
   local tiled_clients = {}
   local myorder = {}
   local window_ix = {}

   for i,t in ipairs(tablist) do
      window_ix[t.window] = true
   end

   local po = 1
   for i,c in pairs(all_clients) do
      if not c.floating and window_ix[c.window] then
            tiled_clients[po] = c
         po = po + 1
      end
   end

   return tiled_clients
end --[23]

-------------------------------------------------------- draw_tabbar() -- ;

function draw_tabbar(region_ix, s)
   local s = s or awful.screen.focused()
   local flexlist = tabs.layout()
   local tablist = get_tiled_clients(region_ix, s)
   
   if tablelength(tablist) == 0 then
      return
   end --|this should only fire on an empty region

   if tablelength(tablist) == 1 then
      clear_tabbar(tablist[1])
      return
   end --|reset tabbar titlebar when only
       --|one client is in the region.

   for cl_ix, cl in ipairs(tablist) do
      local flexlist = tabs.layout()
      global_widget_table[cl.window] = {}

      for cc_ix, cc in ipairs(tablist) do
         local buttons = gears.table.join(
            awful.button({}, 1, function(_) 

                double_click_event_handler(function()
                    cc.floating = not cc.floating
                end)

               gears.timer.delayed_call(function(p) 
                  client.emit_signal("riseup", p)
               end, cc)
            end),
            awful.button({}, 3, function(_)
               cc:kill()
            end))

         global_widget_table[cl.window][cc_ix] = tabs.create(cc, (cc == cl), buttons, cl_ix)
         flexlist:add(global_widget_table[cl.window][cc_ix])
         flexlist.max_widget_size = 120
      end

      local titlebar = awful.titlebar(cl, {
         bg = tabs.bg_normal,
         size = tabs.size,
         position = tabs.position,
      })

      titlebar:setup{layout = wibox.layout.flex.horizontal, flexlist}
      awful.titlebar(cl, {size=8, position = "top"})
      awful.titlebar(cl, {size=0, position = "left"})
      awful.titlebar(cl, {size=0, position = "right"})
   end
end

------------------------------------------------------ resize_region_to -- ;

-- todo: can merge these later, this will have side effects
-- when using multipler monitors.

function resize_region_to_client(c, reset)
   local c = c or client.focus or nil

   if c.floating then return end
   --|we don't wan't interference

   local tablist = get_tiled_clients(c.region)

   for i, w in ipairs(tablist) do
      if reset == true then 
         reset_client_meta(w)
      else
         w.maximized_horizontal = reset.horizontal
         w.maximized_vertical = reset.vertical
         w.direction = reset.direction
      end

      w:geometry(c:geometry())
   end
end

function resize_region_to_index(region_ix, geom, reset)
   local tablist = get_punched_clients(region_ix)
   local region_info = get_region(region_ix)

   for c_ix, c in ipairs(tablist) do
      if reset == true then 
         reset_client_meta(c) 
      else
         c.maximized_horizontal = reset.horizontal
         c.maximized_vertical = reset.vertical
         c.direction = reset.direction
      end
      c:geometry(region_info)
   end
end

----------------------------------------------------- teleport_client() -- ;

local function teleport_client(c,s)
   local c = c or client.focus
   local s = s or c.screen or awful.screen.focused()

   if not c then return true end
   --|flow control

   local is = {
      region=c.region or get_client_info(c).active_region,
      geom=c:geometry(),
      screen=c.screen
   } --|parameters before teleport

   if not c.floating then
      c:geometry({width=300, height=300})
   end --|to avoid machi's auto expansion (lu,rd) of tiled
       --|clients, resize them temporarily. they will be auto
       --|expanded to the region anyway.

   c:move_to_screen()
   --|teleport

   gears.timer.delayed_call(function (c) 
      local tobe = {
         region=get_client_info(c).active_region,
      }
      c.region = tobe.region
      draw_tabbar(c.region, c.screen)
      draw_tabbar(is.region, is.screen)
      c:emit_signal("request::activate", "mouse_enter",{raise = true})
   end,c)
end

------------------------------------------------------ signal helpers -- ;

local function manage_signal(c)
   -- reset_all_clients(s)
   --|reset hack, we shouldn't need this in the second write
   --|up.

   if c.data.awful_client_properties then
      local ci = get_client_info(c)
      --|client info

      global_client_table[c.window] = c
      --|add window.id to client index

      if ci.active_region and not c.floating then
         gears.timer.delayed_call(function(cinfo, p)
            if p.data.awful_client_properties then --[20]
               p.region = cinfo.region
               draw_tabbar(cinfo.active_region, p.screen)
               p:geometry(cinfo.active_region_geom)
            end
         end, ci, c)
      end --|in case new client appears tiled
          --|we must update the regions tabbars.

      if c.transient_for then
         c:move_to_screen(c.transient_for.screen)
         c:move_to_tag(awful.screen.focused().selected_tag)
         client.focus = c
      end --|when clients have a preset screen index with the rules,
          --|transient windows always open in that screen even if we
          --|moved it to the other one. this takes care of that.
   end
end --[6] 

----------------------------------------------------;

local function unmanage_signal(c)
   if c then
      global_client_table[c.window] = nil
      --|remove window.id from client index

      global_widget_table[c.window] = nil
      --|remove window.id from widget index

      if not c.floating then
         local ci = get_client_info(c)
         if ci.active_region then 
            draw_tabbar(ci.active_region, c.screen)
         end
      end
   end
end --[7]

----------------------------------------------------;

local function selected_tag_signal(t)
   gears.timer.delayed_call(function(t)
      local regions = get_regions(t.screen)
         if regions and #regions then
            for i, region in ipairs(regions) do
               draw_tabbar(i, t.screen)
            end
         end
   end,t)
end --[8]

----------------------------------------------------;

local function floating_signal(c)
   if not global_client_table[c.window] then return end
   --|possibly to optimize config reload
   --|floating signal kicks in before manage
   --|this should bypass weird things happening during reload if any.

   if c.floating then
      if c.region then
         gears.timer.delayed_call(function(active_region,c)
            clear_tabbar(c)
            draw_tabbar(c.region)
            c.region = nil
         end, active_region,c)
      end
   end --|window became floating

   if not c.floating then
      local ci = get_client_info(c)
      if ci.active_region then
         c.region = ci.active_region
         gears.timer.delayed_call(function(active_region)
            draw_tabbar(active_region)
         end, ci.active_region)
      end
   end --|window became tiled
end --[9]

----------------------------------------------------;

local function focus_signal(c)
   if global_widget_table[c.window] then
      for i, p in pairs(global_widget_table[c.window]) do
         if p.focused then
            local widget = global_widget_table[c.window][i]:get_children_by_id(c.window)[1]
            widget.bg = "#43417a"
         end
      end
   end
end

----------------------------------------------------;

local function unfocus_signal(c)
   if global_widget_table[c.window] then
      for i, p in pairs(global_widget_table[c.window]) do
         if p.focused then
            p.bg = "#292929"
            break
         end
      end
   end
end

----------------------------------------------------;

local function minimized_signal(c)
   if c.minimized then unmanage_signal(c) end
   if not c.minimized then manage_signal(c) end 
end --[[ manage minimized and not minimized ]]

----------------------------------------------------;

local function name_signal(c)
   if widget_ix[c.window] then
      for i, p in pairs(widget_ix[c.window]) do
         if p.focused then
            widget = widget_ix[c.window][i]:get_children_by_id(c.window)[1]
            widget.widget.markup = c.name
         end
      end
   end
end -- todo: need to update the other clients in the region here as well
    -- this may not even be worth it as the client names kind of pollute the
    -- tabs a lot making it harder to distinguish what is what.
    -- client.connect_signal("property::name", name_signal)

----------------------------------------------------;

local function riseup_signal(c)
   client.focus = c; c:raise()
   -- c:emit_signal("request::activate", "mouse_enter",{raise = true})
end

----------------------------------------------------;

-- awful.titlebar.widget.connect_signal("mouse::enter", function()
--    log('here')
-- end)

--------------------------------------------------------------- signals -- ;

client.connect_signal("riseup", riseup_signal)
client.connect_signal("focus", focus_signal)
client.connect_signal("unfocus", unfocus_signal)
client.connect_signal("property::minimized", minimized_signal)
client.connect_signal("property::floating", floating_signal)
client.connect_signal("tabbar_draw", draw_tabbar)
client.connect_signal("unmanage", unmanage_signal) 
client.connect_signal("manage", manage_signal)
tag.connect_signal("property::selected", selected_tag_signal)

-- client.connect_signal("mouse::enter", function ()
-- log(mouse.current_widget)
-- end)

--------------------------------------------------------------- exports -- ;

module = {
   focus_by_direction = focus_by_direction,
   get_active_regions = get_client_info,
   shift_by_direction = shift_by_direction,
   expand_horizontal = expand_horizontal,
   shuffle = shuffle,
   old_shuffle = old_shuffle,
   my_shifter = my_shifter,
   expand_vertical = expand_vertical,
   move_to = move_to,
   get_regions = get_regions,
   toggle_always_on = toggle_always_on,
   draw_tabbar = draw_tabbar,
   get_global_clients = get_global_clients,
   update_global_clients = update_global_clients,
   get_client_info = get_client_info,
   teleport_client = teleport_client,
   focus_by_index = focus_by_index,
   focus_by_number = focus_by_number,
   set_region = set_region,
   align_floats = align_floats,
}

return module


--[[ ------------------------------------------------- NOTES ]

  [99] order of signals, manage_signal executes the last,
  not the first.

  [0] todo: rewrite the whole thing, but plan ahead this
  time.

      - get regions from machi, this will give us indexes
      - manage signal will mark the global index and punch
        the region_id to the client.
      - it will then draw tabs to the region

  region_expansions:

      - regions can be expanded using the maximixed trick.
      - it will change the geometry of all the clients in
        that region.
      - redrawing the tabbar is not necessary.
      - when toggling, region geometry will also change.


  functions needed:
   
      - get_region(region_id, screen)
      
      - get_regions(screen)

      - get_clients_in_region(region_id, screen): this would
        need to return the ordered list of all the clients
        in the region from the global client list.

        there are multiple strategies that can be used:
        
        c.region_id:
        this wil flap during reload

        geometric comparison: we can compare all client
        geometry to regions geometry. but it will fail for
        expanded/overflowing clients.

      - draw_tabbar(region, screen): it will draw tabbars
        for all the clients in the region.

      - expand_region(direction, region, screen): it will
        expand all the clients in the region. same shortcut
        will reset the expansions. expansions will happen
        in multiple directions, and "center".

  MPV: it appears client flashing could also be an issue.
  MPV for instance starts large briefly and causes an
  update in the wrong region. We need a region.id lookup
  only it seems. We should also consider reading awm rules
  for a region id for placement.

  [4] machi's own region expansion has issues on
  awesome-reload. if we were to expand a region, and then
  do reload, machi-layout would insist to keep the expanded
  layout in its own accord.

  [5] to avoid this, we temporarily set the non floating
  clients region geometry. 

  [4] when the clients become float, we restore this
  geometry. Do note, there is something awkward here, it
  appears no matter what all clients start as float then
  get tiled, so there is a flaw in this logic.

  [9] when windows switch between float and tiled we must
  perform necessary maintenance on the destination and
  source regions. a delayed call was necessary when clients
  become tiled to give awm enough time to draw the widgets
  properly. (*)this floating signal acts weird during
  configuration reloads.

  [8] property::selected gets called the last, by the time
  we are here, we already have the global_client_list to
  draw tabbars. This may appear redundant here, but it's
  good to have this fire up in case the user switches
  tags.

  [7] when removing a tiled client we must update the
  tabbars of others. floating clients do not require any
  cleanup.


  [6] global_client_table is the milestone the tabbars rely
  on. whenever a new client appears we must add to it, and
  when a client is killed we must make sure it is
  removed. 

  [23] global_client_index stores the ordered list of all
  clients available and it is used as a blueprint to keep
  the order of our tablist intact, without this, tabbars
  would go out of order when user focuses via shortcuts
  (run_or_raise).

  [20] cudatext had an awkward issue, I suppose it's the way
  it's rendering its window causing it to register multiple
  times and it would make client.lua throw an invalid
  object error at line 1195. So, it's handled now.

--]]
