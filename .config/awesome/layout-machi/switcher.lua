local machi = {
   layout = require((...):match("(.-)[^%.]+$") .. "layout"),
}

local api = {
   client     = client,
   beautiful  = require("beautiful"),
   wibox      = require("wibox"),
   awful      = require("awful"),
   screen     = require("awful.screen"),
   layout     = require("awful.layout"),
   naughty    = require("naughty"),
   gears      = require("gears"),
   lgi        = require("lgi"),
   dpi        = require("beautiful.xresources").apply_dpi,
}

local ERROR = 2
local WARNING = 1
local INFO = 0
local DEBUG = -1

local module = {
   log_level = WARNING,
}

local function log(level, msg)
   if level > module.log_level then
      print(msg)
   end
end

local function min(a, b)
   if a < b then return a else return b end
end

local function max(a, b)
   if a < b then return b else return a end
end

local function with_alpha(col, alpha)
   local r, g, b
   _, r, g, b, _ = col:get_rgba()
   return api.lgi.cairo.SolidPattern.create_rgba(r, g, b, alpha)
end

function module.start(c, exit_keys)
   local tablist_font_desc = api.beautiful.get_merged_font(
      api.beautiful.font, api.dpi(10))
   local font_color = with_alpha(api.gears.color(api.beautiful.fg_normal), 1)
   local font_color_hl = with_alpha(api.gears.color(api.beautiful.fg_focus), 1)
   local label_size = api.dpi(30)
   local border_color = with_alpha(api.gears.color(api.beautiful.border_focus), 0.25)
   local fill_color = with_alpha(api.gears.color(api.beautiful.bg_normal), 0.25)
   local box_bg = with_alpha(api.gears.color(api.beautiful.bg_normal), 0.85)
   local fill_color_hl = with_alpha(api.gears.color(api.beautiful.bg_focus), 1)
   -- for comparing floats
   local threshold = 0.1
   local traverse_radius = api.dpi(5)

   local screen = c and c.screen or api.screen.focused()
   local start_x = screen.workarea.x
   local start_y = screen.workarea.y

   local layout = api.layout.get(screen)
   if (c ~= nil and c.floating) or layout.machi_get_regions == nil then return end

   local regions, draft_mode = layout.machi_get_regions(screen.workarea, screen.selected_tag)
   if regions == nil or #regions == 0 then
      return
   end

   local infobox = api.wibox({
         screen = screen,
         x = screen.workarea.x,
         y = screen.workarea.y,
         width = screen.workarea.width,
         height = screen.workarea.height,
         bg = "#ffffff00",
         opacity = 1,
         ontop = true,
         type = "dock",
   })
   infobox.visible = true

   local tablist_region = nil
   local tablist = nil
   local tablist_index = nil

   local traverse_x, traverse_y
   if c then
      traverse_x = c.x + traverse_radius
      traverse_y = c.y + traverse_radius
   else
      traverse_x = screen.workarea.x + screen.workarea.width / 2
      traverse_y = screen.workarea.y + screen.workarea.height / 2
   end

   local function maintain_tablist()
      if tablist == nil then
         tablist = {}

         for _, tc in ipairs(screen.tiled_clients) do
            if not (tc.floating or tc.maximized or tc.maximized_horizontal or tc.maximized_vertical)
            then
               if tc.x <= traverse_x and traverse_x < tc.x + tc.width + tc.border_width * 2 and
                  tc.y <= traverse_y and traverse_y < tc.y + tc.height + tc.border_width * 2
               then
                  tablist[#tablist + 1] = tc
               end
            end
         end

         tablist_index = 1

      else

         local j = 0
         for i = 1, #tablist do
            if tablist[i].valid then
               j = j + 1
               tablist[j] = tablist[i]
            elseif i <= tablist_index and tablist_index > 0 then
               tablist_index = tablist_index - 1
            end
         end

         for i = #tablist, j + 1, -1 do
            table.remove(tablist, i)
         end
      end

      if c and not c.valid then c = nil end
      if c == nil and #tablist > 0 then
         c = tablist[tablist_index]
      end
   end

   local function draw_info(context, cr, width, height)
      maintain_tablist()

      cr:set_source_rgba(0, 0, 0, 0)
      cr:rectangle(0, 0, width, height)
      cr:fill()

      local msg, ext, active_region
      for i, a in ipairs(regions) do

         cr:rectangle(a.x - start_x, a.y - start_y, a.width, a.height)
         cr:clip()
         cr:set_source(fill_color)
         cr:rectangle(a.x - start_x, a.y - start_y, a.width, a.height)
         cr:fill()
         cr:set_source(border_color)
         cr:rectangle(a.x - start_x, a.y - start_y, a.width, a.height)
         cr:set_line_width(10.0)
         cr:stroke()
         cr:reset_clip()

         if a.x <= traverse_x and traverse_x < a.x + a.width and
            a.y <= traverse_y and traverse_y < a.y + a.height
         then
            active_region = i
         end
      end

      if #tablist > 0 then
         local a = regions[active_region]
         local pl = api.lgi.Pango.Layout.create(cr)
         pl:set_font_description(tablist_font_desc)

         local vpadding = api.dpi(10)
         local list_height = vpadding
         local list_width = 2 * vpadding
         local exts = {}

         for index, tc in ipairs(tablist) do
            local label = tc.name
            pl:set_text(label)
            local w, h
            w, h = pl:get_size()
            w = w / api.lgi.Pango.SCALE
            h = h / api.lgi.Pango.SCALE
            local ext = { width = w, height = h, x_bearing = 0, y_bearing = 0 }
            exts[#exts + 1] = ext
            list_height = list_height + ext.height + vpadding
            list_width = max(list_width, w + 2 * vpadding)
         end

         local x_offset = a.x + a.width / 2 - start_x
         local y_offset = a.y + a.height / 2 - list_height / 2 + vpadding - start_y

         -- cr:rectangle(a.x - start_x, y_offset - vpadding - start_y, a.width, list_height)
         -- cover the entire region
         cr:rectangle(a.x - start_x, a.y - start_y, a.width, a.height)
         cr:set_source(fill_color)
         cr:fill()

         cr:rectangle(a.x + (a.width - list_width) / 2 - start_x, a.y + (a.height - list_height) / 2 - start_y, list_width, list_height)
         cr:set_source(box_bg)
         cr:fill()

         for index, tc in ipairs(tablist) do
            local label = tc.name
            local ext = exts[index]
            if index == tablist_index then
               cr:rectangle(x_offset - ext.width / 2 - vpadding / 2, y_offset - vpadding / 2, ext.width + vpadding, ext.height + vpadding)
               cr:set_source(fill_color_hl)
               cr:fill()
               pl:set_text(label)
               cr:move_to(x_offset - ext.width / 2 - ext.x_bearing, y_offset - ext.y_bearing)
               cr:set_source(font_color_hl)
               cr:show_layout(pl)
            else
               pl:set_text(label)
               cr:move_to(x_offset - ext.width / 2 - ext.x_bearing, y_offset - ext.y_bearing)
               cr:set_source(font_color)
               cr:show_layout(pl)
            end

            y_offset = y_offset + ext.height + vpadding
         end
      end

      -- show the traverse point
      cr:rectangle(traverse_x - start_x - traverse_radius, traverse_y - start_y - traverse_radius, traverse_radius * 2, traverse_radius * 2)
      cr:set_source_rgba(1, 1, 1, 1)
      cr:fill()
   end

   infobox.bgimage = draw_info

   local key_translate_tab = {
      ["w"] = "Up",
      ["a"] = "Left",
      ["s"] = "Down",
      ["d"] = "Right",
   }

   api.awful.client.focus.history.disable_tracking()

   local kg
   local function exit()
      api.awful.client.focus.history.enable_tracking()
      if api.client.focus then
         api.client.emit_signal("focus", api.client.focus)
      end
      infobox.visible = false
      api.awful.keygrabber.stop(kg)
   end

   local function handle_key(mod, key, event)
      if event == "release" then
         if exit_keys and exit_keys[key] then
            exit()
         end
         return
      end
      if key_translate_tab[key] ~= nil then
         key = key_translate_tab[key]
      end

      maintain_tablist()
      assert(tablist ~= nil)

      if key == "Tab" then
         if #tablist > 0 then
            tablist_index = tablist_index % #tablist + 1
            c = tablist[tablist_index]
            c:emit_signal("request::activate", "mouse.move", {raise=false})
            c:raise()

            infobox.bgimage = draw_info
         end
      elseif key == "Up" or key == "Down" or key == "Left" or key == "Right" then
         local shift = false
         local ctrl = false
         for i, m in ipairs(mod) do
            if m == "Shift" then shift = true
            elseif m == "Control" then ctrl = true
            end
         end

         local current_region = nil

         if c and (shift or ctrl) then
            for i, a in ipairs(regions) do
               if a.x <= traverse_x and traverse_x < a.x + a.width and
                  a.y <= traverse_y and traverse_y < a.y + a.height
               then
                  current_region = i
                  break
               end
            end

            if shift then
               if current_region == nil or
                  regions[current_region].x ~= c.x or
                  regions[current_region].y ~= c.y
               then
                  traverse_x = c.x + traverse_radius
                  traverse_y = c.y + traverse_radius
                  current_region = nil
               end
            elseif ctrl then
               local ex = c.x + c.width + c.border_width * 2
               local ey = c.y + c.height + c.border_width * 2
               if current_region == nil or
                  regions[current_region].x + regions[current_region].width ~= ex or
                  regions[current_region].y + regions[current_region].height ~= ey
               then
                  traverse_x = ex - traverse_radius
                  traverse_y = ey - traverse_radius
                  current_region = nil
               end
            end
         end

         local choice = nil
         local choice_value

         for i, a in ipairs(regions) do
            if a.x <= traverse_x and traverse_x < a.x + a.width and
               a.y <= traverse_y and traverse_y < a.y + a.height
            then
               current_region = i
            end

            local v
            if key == "Up" then
               if a.x < traverse_x + threshold
               and traverse_x < a.x + a.width + threshold then
                  v = traverse_y - a.y - a.height
               else
                  v = -1
               end
            elseif key == "Down" then
               if a.x < traverse_x + threshold
               and traverse_x < a.x + a.width + threshold then
                  v = a.y - traverse_y
               else
                  v = -1
               end
            elseif key == "Left" then
               if a.y < traverse_y + threshold
               and traverse_y < a.y + a.height + threshold then
                  v = traverse_x - a.x - a.width
               else
                  v = -1
               end
            elseif key == "Right" then
               if a.y < traverse_y + threshold
               and traverse_y < a.y + a.height + threshold then
                  v = a.x - traverse_x
               else
                  v = -1
               end
            end

            if (v > threshold) and (choice_value == nil or choice_value > v) then
               choice = i
               choice_value = v
            end
         end

         if choice == nil then
            choice = current_region
            if key == "Up" then
               traverse_y = screen.workarea.y
            elseif key == "Down" then
               traverse_y = screen.workarea.y + screen.workarea.height
            elseif key == "Left" then
               traverse_x = screen.workarea.x
            else
               traverse_x = screen.workarea.x + screen.workarea.width
            end
         end

         if choice ~= nil then
            traverse_x = max(regions[choice].x + traverse_radius, min(regions[choice].x + regions[choice].width - traverse_radius, traverse_x))
            traverse_y = max(regions[choice].y + traverse_radius, min(regions[choice].y + regions[choice].height - traverse_radius, traverse_y))
            tablist = nil

            if c and ctrl and draft_mode then
               local lu = c.machi_lu
               local rd = c.machi_rd

               if shift then
                  lu = choice
                  if regions[rd].x + regions[rd].width <= regions[lu].x or
                     regions[rd].y + regions[rd].height <= regions[lu].y
                  then
                     rd = nil
                  end
               else
                  rd = choice
                  if regions[rd].x + regions[rd].width <= regions[lu].x or
                     regions[rd].y + regions[rd].height <= regions[lu].y
                  then
                     lu = nil
                  end
               end

               if lu ~= nil and rd ~= nil then
                  machi.layout.set_geometry(c, regions[lu], regions[rd], 0, c.border_width)
               elseif lu ~= nil then
                  machi.layout.set_geometry(c, regions[lu], nil, 0, c.border_width)
               elseif rd ~= nil then
                  c.x = min(c.x, regions[rd].x)
                  c.y = min(c.y, regions[rd].y)
                  machi.layout.set_geometry(c, nil, regions[rd], 0, c.border_width)
               end
               c.machi_lu = lu
               c.machi_rd = rd

               c:emit_signal("request::activate", "mouse.move", {raise=false})
               c:raise()
               api.layout.arrange(screen)
            elseif c and shift then
               -- move the window
               if draft_mode then
                  c.x = regions[choice].x
                  c.y = regions[choice].y
               else
                  machi.layout.set_geometry(c, regions[choice], regions[choice], 0, c.border_width)
                  c.machi_region = choice
               end
               c:emit_signal("request::activate", "mouse.move", {raise=false})
               c:raise()
               api.layout.arrange(screen)

               tablist = nil
            else
               maintain_tablist()
               -- move the focus
               if #tablist > 0 and tablist[1] ~= c then
                  c = tablist[1]
                  api.client.focus = c
               end
            end

            infobox.bgimage = draw_info
         end
      elseif key == "Escape" or key == "Return" then
         exit()
      else
         log(DEBUG, "Unhandled key " .. key)
      end
   end

   kg = api.awful.keygrabber.run(
      function (...)
         ok, _ = pcall(handle_key, ...)
         if not ok then exit() end
      end
   )
end

return module
