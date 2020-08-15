local api = {
   beautiful  = require("beautiful"),
   wibox      = require("wibox"),
   awful      = require("awful"),
   screen     = require("awful.screen"),
   layout     = require("awful.layout"),
   naughty    = require("naughty"),
   gears      = require("gears"),
   gfs        = require("gears.filesystem"),
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

local function with_alpha(col, alpha)
   local r, g, b
   _, r, g, b, _ = col:get_rgba()
   return api.lgi.cairo.SolidPattern.create_rgba(r, g, b, alpha)
end

local function max(a, b)
   if a < b then return b else return a end
end

local function is_tiling(c)
   return
      not (c.tomb_floating or c.floating or c.maximized_horizontal or c.maximized_vertical or c.maximized or c.fullscreen)
end

local function set_tiling(c)
   c.floating = false
   c.maximized = false
   c.maximized_vertical = false
   c.maximized_horizontal = false
   c.fullscreen = false
end

local function parse_arg_string(s, default)
   local ret = {}
   if #s == 0 then return ret end
   local index = 1
   local comma_mode = s:find(",") ~= nil

   local p = index
   while index <= #s do
      if comma_mode then
         if s:sub(index, index) == "," then
            local r = tonumber(s:sub(p, index - 1))
            if r == nil then
               ret[#ret + 1] = default
            else
               ret[#ret + 1] = r
            end
            p = index + 1
         end
      else
         local r = tonumber(s:sub(index, index))
         if r == nil then
            ret[#ret + 1] = default
         else
            ret[#ret + 1] = r
         end
      end
      index = index + 1
   end

   if comma_mode then
      local r = tonumber(s:sub(p, index - 1))
      if r == nil then
         ret[#ret + 1] = default
      else
         ret[#ret + 1] = r
      end
      p = index + 1
   end

   return ret
end

local function test_parse_arg_string()
   local x = parse_arg_string("12a3", "aha")
   assert(#x == 4 and x[1] == 1 and x[2] == 2 and x[3] == "aha" and x[4] == 3)
   local x = parse_arg_string("12,a3,4", "aha")
   assert(#x == 3 and x[1] == 12 and x[2] == "aha" and x[3] == 4)
end

-- test_parse_arg_string()

local function fair_split(total, shares, shares_sum)
   local ret = {}
   local acc = 0
   local acc_ret = 0
   if shares_sum == nil then
      shares_sum = 0
      for i = 1, #shares do shares_sum = shares_sum + shares[i] end
   end
   for i = 1, #shares do
      acc = acc + shares[i]
      ret[i] = i < #shares and math.floor(total / shares_sum * acc - acc_ret + 0.5) or total - acc_ret
      acc_ret = acc_ret + ret[i]
   end
   return ret
end

local function min(a, b)
   if a < b then return a else return b end
end

local function max(a, b)
   if a < b then return b else return a end
end

local function _area_tostring(wa)
   return "{x:" .. tostring(wa.x) .. ",y:" .. tostring(wa.y) .. ",w:" .. tostring(wa.width) .. ",h:" .. tostring(wa.height) .. "}"
end

local function shrink_area_with_gap(a, inner_gap, outer_gap)
   return { x = a.x + (a.bl and outer_gap or inner_gap / 2), y = a.y + (a.bu and outer_gap or inner_gap / 2),
            width = a.width - (a.bl and outer_gap or inner_gap / 2) - (a.br and outer_gap or inner_gap / 2),
            height = a.height - (a.bu and outer_gap or inner_gap / 2) - (a.bd and outer_gap or inner_gap / 2) }
end

function module.restore_data(data)
   if data.history_file then
      local file, err = io.open(data.history_file, "r")
      if err then
         log(INFO, "cannot read history from " .. data.history_file)
      else
         data.cmds = {}
         data.last_cmd = {}
         local last_layout_name
         for line in file:lines() do
            if line:sub(1, 1) == "+" then
               last_layout_name = line:sub(2, #line)
            else
               if last_layout_name ~= nil then
                  log(DEBUG, "restore last cmd " .. line .. " for " .. last_layout_name)
                  data.last_cmd[last_layout_name] = line
                  last_layout_name = nil
               else
                  log(DEBUG, "restore cmd " .. line)
                  data.cmds[#data.cmds + 1] = line
               end
            end
         end
         file:close()
      end
   end

   return data
end

function module.create(data)
   if data == nil then
      data = module.restore_data({
            history_file = api.gfs.get_cache_dir() .. "/history_machi",
            history_save_max = 100,
      })
   end

   if data.cmds == nil then
      data.cmds = {}
   end

   if data.last_cmd == nil then
      data.last_cmd = {}
   end

   local init_max_depth = 2

   local closed_areas
   local open_areas
   local history
   local arg_str
   local max_depth
   local current_info
   local current_cmd
   local pending_op
   local to_exit
   local to_apply

   local function init(init_area, extend)
      closed_areas = {}
      open_areas = {
         {
            x = init_area.x - extend,
            y = init_area.y - extend,
            width = init_area.width + extend * 2,
            height = init_area.height + extend * 2,
            depth = 0,
            group_id = 0,
            bl = true, br = true, bu = true, bd = true,
         }
      }
      history = {}
      arg_str = ""
      max_depth = init_max_depth
      current_info = ""
      current_cmd = ""
      pending_op = nil
      to_exit = false
      to_apply = false
   end

   local function push_history()
      if history == nil then return end
      history[#history + 1] = {#closed_areas, #open_areas, {}, current_info, current_cmd, pending_op, max_depth, arg_str}
   end

   local function discard_history()
      if history == nil then return end
      table.remove(history, #history)
   end

   local function pop_history()
      if history == nil or #history == 0 then return end
      for i = history[#history][1] + 1, #closed_areas do
         table.remove(closed_areas, #closed_areas)
      end

      for i = history[#history][2] + 1, #open_areas do
         table.remove(open_areas, #open_areas)
      end

      for i = 1, #history[#history][3] do
         open_areas[history[#history][2] - i + 1] = history[#history][3][i]
      end

      current_info = history[#history][4]
      current_cmd = history[#history][5]
      pending_op = history[#history][6]
      max_depth = history[#history][7]
      arg_str = history[#history][8]

      table.remove(history, #history)
   end

   local function pop_open_area()
      local a = open_areas[#open_areas]
      table.remove(open_areas, #open_areas)
      if history == nil or #history == 0 then return a end

      local idx = history[#history][2] - #open_areas
      -- only save when the position has been firstly poped
      if idx > #history[#history][3] then
         history[#history][3][#history[#history][3] + 1] = a
      end
      return a
   end

   local function push_area()
      closed_areas[#closed_areas + 1] = pop_open_area()
   end

   local function push_children(c)
      for i = #c, 1, -1 do
         if c[i].x ~= math.floor(c[i].x)
            or c[i].y ~= math.floor(c[i].y)
            or c[i].width ~= math.floor(c[i].width)
            or c[i].height ~= math.floor(c[i].height)
         then
            log(WARNING, "splitting yields floating area " .. _area_tostring(c[i]))
         end
         open_areas[#open_areas + 1] = c[i]
      end
   end

   local op_count = 0

   local function handle_op(method)
      op_count = op_count + 1

      local l = method:lower()
      local alt = method ~= l
      method = l

      log(DEBUG, "op " .. method .. " " .. tostring(alt) .. " " .. arg_str)
      if method == "h" or method == "v" then

         local a = pop_open_area()
         local args = parse_arg_string(arg_str, 0)
         if #args == 0 then
            args = {1, 1}
         elseif #args == 1 then
            args[2] = 1
         end

         local total = 0
         local shares = { }
         for i = 1, #args do
            local arg
            if not alt then
               arg = args[i]
            else
               arg = args[#args - i + 1]
            end
            if arg < 1 then arg = 1 end
            total = total + arg
            shares[i] = arg
         end
         local children = {}

         if method == "h" then
            shares = fair_split(a.width, shares, total)
            for i = 1, #shares do
               local child = {
                  x = i == 1 and a.x or children[#children].x + children[#children].width,
                  y = a.y,
                  width = shares[i],
                  height = a.height,
                  depth = a.depth + 1,
                  group_id = op_count,
                  bl = i == 1 and a.bl or false,
                  br = i == #shares and a.br or false,
                  bu = a.bu,
                  bd = a.bd,
               }
               children[#children + 1] = child
            end
         else
            shares = fair_split(a.height, shares, total)
            for i = 1, #shares do
               local child = {
                  x = a.x,
                  y = i == 1 and a.y or children[#children].y + children[#children].height,
                  width = a.width,
                  height = shares[i],
                  depth = a.depth + 1,
                  group_id = op_count,
                  bl = a.bl,
                  br = a.br,
                  bu = i == 1 and a.bu or false,
                  bd = i == #shares and a.bd or false,
               }
               children[#children + 1] = child
            end
         end

         push_children(children)

      elseif method == "w" then

         local a = pop_open_area()
         local args = parse_arg_string(arg_str, 0)
         if #args == 0 then
            args = {1, 1}
         elseif #args == 1 then
            args[2] = 1
         end

         local h_split, v_split
         if alt then
            h_split = args[2]
            v_split = args[1]
         else
            h_split = args[1]
            v_split = args[2]
         end
         if h_split < 1 then h_split = 1 end
         if v_split < 1 then v_split = 1 end

         local x_shares = {}
         local y_shares = {}
         for i = 1, h_split do x_shares[i] = 1 end
         for i = 1, v_split do y_shares[i] = 1 end

         x_shares = fair_split(a.width, x_shares, h_split)
         y_shares = fair_split(a.height, y_shares, v_split)

         local children = {}
         for y_index = 1, v_split do
            for x_index = 1, h_split do
               local r = {
                  x = x_index == 1 and a.x or children[#children].x + children[#children].width,
                  y = y_index == 1 and a.y or (x_index == 1 and children[#children].y + children[#children].height or children[#children].y),
                  width = x_shares[x_index],
                  height = y_shares[y_index],
                  depth = a.depth + 1,
                  group_id = op_count,
               }
               if x_index == 1 then r.bl = a.bl else r.bl = false end
               if x_index == h_split then r.br = a.br else r.br = false end
               if y_index == 1 then r.bu = a.bu else r.bu = false end
               if y_index == v_split then r.bd = a.bd else r.bd = false end
               children[#children + 1] = r
            end
         end

         local merged_children = {}
         local start_index = 1
         for i = 3, #args - 1, 2 do
            -- find the first index that is not merged
            while start_index <= #children and children[start_index] == false do
               start_index = start_index + 1
            end
            if start_index > #children or children[start_index] == false then
               break
            end
            local x = (start_index - 1) % h_split
            local y = math.floor((start_index - 1) / h_split)
            local w = args[i]
            local h = args[i + 1]
            if w < 1 then w = 1 end
            if h == nil or h < 1 then h = 1 end
            if alt then
               local tmp = w
               w = h
               h = tmp
            end
            if x + w > h_split then w = h_split - x end
            if y + h > v_split then h = v_split - y end
            local end_index = start_index
            for ty = y, y + h - 1 do
               local succ = true
               for tx = x, x + w - 1 do
                  if children[ty * h_split + tx + 1] == false then
                     succ = false
                     break
                  elseif ty == y then
                     end_index = ty * h_split + tx + 1
                  end
               end

               if not succ then
                  break
               elseif ty > y then
                  end_index = ty * h_split + x + w
               end
            end

            local r = {
               x = children[start_index].x, y = children[start_index].y,
               width = children[end_index].x + children[end_index].width - children[start_index].x,
               height = children[end_index].y + children[end_index].height - children[start_index].y,
               bu = children[start_index].bu, bl = children[start_index].bl,
               bd = children[end_index].bd, br = children[end_index].br,
               depth = a.depth + 1,
               group_id = op_count
            }
            merged_children[#merged_children + 1] = r

            for ty = y, y + h - 1 do
               local succ = true
               for tx = x, x + w - 1 do
                  local index = ty * h_split + tx + 1
                  if index <= end_index then
                     children[index] = false
                  else
                     break
                  end
               end
            end
         end

         -- clean up children, remove all `false'
         local j = 1
         for i = 1, #children do
            if children[i] ~= false then
               children[j] = children[i]
               j = j + 1
            end
         end
         for i = #children, j, -1 do
            table.remove(children, i)
         end

         push_children(merged_children)
         push_children(children)

      elseif method == "d" then

         local a = pop_open_area()
         local shares = parse_arg_string(arg_str, 0)
         local x_shares = {}
         local y_shares = {}

         local current = x_shares
         for i = 1, #shares do
            if not alt then
               arg = shares[i]
            else
               arg = shares[#shares - i + 1]
            end
            if arg < 1 then
               if current == x_shares then current = y_shares else break end
            else
               current[#current + 1] = arg
            end
         end

         if #x_shares == 0 then
            open_areas[#open_areas + 1] = a
            return
         elseif #y_shares == 0 then
            y_shares = {1}
         end

         x_shares = fair_split(a.width, x_shares)
         y_shares = fair_split(a.height, y_shares)

         local children = {}
         for y_index = 1, #y_shares do
            for x_index = 1, #x_shares do
               local r = {
                  x = x_index == 1 and a.x or children[#children].x + children[#children].width,
                  y = y_index == 1 and a.y or (x_index == 1 and children[#children].y + children[#children].height or children[#children].y),
                  width = x_shares[x_index],
                  height = y_shares[y_index],
                  depth = a.depth + 1,
                  group_id = op_count,
               }
               if x_index == 1 then r.bl = a.bl else r.bl = false end
               if x_index == #x_shares then r.br = a.br else r.br = false end
               if y_index == 1 then r.bu = a.bu else r.bu = false end
               if y_index == #y_shares then r.bd = a.bd else r.bd = false end
               children[#children + 1] = r
            end
         end

         push_children(children)

      elseif method == "s" then

         if #open_areas > 0 then
            local times = arg_str == "" and 1 or tonumber(arg_str)
            local t = {}
            while #open_areas > 0 do
               t[#t + 1] = pop_open_area()
            end
            for i = #t, 1, -1 do
               open_areas[#open_areas + 1] = t[(i + times - 1) % #t + 1]
            end
         end

      elseif method == "t" then

         local n = tonumber(arg_str)
         if n ~= nil then
            max_depth = n
         end

      elseif method == "-" then

         push_area()

      elseif method == "." then

         while #open_areas > 0 do
            push_area()
         end

      elseif method == "/" then

         pop_open_area()

      elseif method == ";" then

         -- nothing

      end

      while #open_areas > 0 and open_areas[#open_areas].depth >= max_depth do
         push_area()
      end

      arg_str = ""
   end

   local key_translate_tab = {
      ["Return"] = ".",
      [" "] = "-",
   }

   -- 3 for taking the arg string and an open area
   -- 2 for taking an open area
   -- 1 for taking nothing
   -- 0 for args
   local ch_info = {
      ["h"] = 3, ["H"] = 3,
      ["v"] = 3, ["V"] = 3,
      ["w"] = 3, ["W"] = 3,
      ["d"] = 3, ["D"] = 3,
      ["s"] = 3, ["S"] = 3,
      ["t"] = 3, ["T"] = 3,
      ["-"] = 2,
      ["/"] = 2,
      ["."] = 1,
      [";"] = 1,
      ["0"] = 0, ["1"] = 0, ["2"] = 0, ["3"] = 0, ["4"] = 0,
      ["5"] = 0, ["6"] = 0, ["7"] = 0, ["8"] = 0, ["9"] = 0,
      [","] = 0,
   }

   local function handle_ch(key)
      if key_translate_tab[key] ~= nil then
         key = key_translate_tab[key]
      end
      local t = ch_info[key]
      if t == nil then
         return nil
      elseif t == 3 then
         if pending_op ~= nil then
            handle_op(pending_op)
            pending_op = nil
         end
         if #open_areas == 0 then return nil end
         if arg_str == "" then
            pending_op = key
         else
            handle_op(key)
         end
      elseif t == 2 or t == 1 then
         if pending_op ~= nil then
            handle_op(pending_op)
            pending_op = nil
         end
         if #open_areas == 0 and t == 2 then return nil end
         handle_op(key)
      elseif t == 0 then
         arg_str = arg_str .. key
      end

      return key
   end

   local function set_gap(inner_gap, outer_gap)
      data.inner_gap = inner_gap
      data.outer_gap = outer_gap
   end

   local function start_interactive(screen, layout)
      local outer_gap = data.outer_gap or data.gap or api.beautiful.useless_gap * 2 or 0
      local inner_gap = data.inner_gap or data.gap or api.beautiful.useless_gap * 2 or 0
      local label_font_family = api.beautiful.get_font(
         api.beautiful.font):get_family()
      local label_size = api.dpi(30)
      local info_size = api.dpi(60)
      -- colors are in rgba
      local border_color = with_alpha(api.gears.color(api.beautiful.border_focus), 0.75)
      local active_color = with_alpha(api.gears.color(api.beautiful.bg_focus), 0.5)
      local open_color   = with_alpha(api.gears.color(api.beautiful.bg_normal), 0.5)
      local closed_color = open_color

      screen = screen or api.screen.focused()
      layout = layout or api.layout.get(screen)
      local tag = screen.selected_tag

      if layout.machi_set_cmd == nil then
         api.naughty.notify({
            text = "The layout to edit is not machi",
            timeout = 3,
         })
         return
      end

      local cmd_index = #data.cmds + 1
      data.cmds[cmd_index] = ""

      local start_x = screen.workarea.x
      local start_y = screen.workarea.y

      local kg
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

      local function cleanup()
         infobox.visible = false
      end

      local function draw_info(context, cr, width, height)
         cr:set_source_rgba(0, 0, 0, 0)
         cr:rectangle(0, 0, width, height)
         cr:fill()

         local msg, ext

         for i, a in ipairs(closed_areas) do
            local sa = shrink_area_with_gap(a, inner_gap, inner_gap / 2)
            local to_highlight = false
            if pending_op ~= nil then
               to_highlight = a.group_id == op_count
            end
            cr:rectangle(sa.x - start_x, sa.y - start_y, sa.width, sa.height)
            cr:clip()
            if to_highlight then
               cr:set_source(active_color)
            else
               cr:set_source(closed_color)
            end
            cr:rectangle(sa.x - start_x, sa.y - start_y, sa.width, sa.height)
            cr:fill()
            cr:set_source(border_color)
            cr:rectangle(sa.x - start_x, sa.y - start_y, sa.width, sa.height)
            cr:set_line_width(10.0)
            cr:stroke()
            cr:reset_clip()
         end

         for i, a in ipairs(open_areas) do
            local sa = shrink_area_with_gap(a, inner_gap, inner_gap / 2)
            local to_highlight = false
            if pending_op == nil then
               to_highlight = i == #open_areas
            else
               to_highlight = a.group_id == op_count
            end
            cr:rectangle(sa.x - start_x, sa.y - start_y, sa.width, sa.height)
            cr:clip()
            if i == #open_areas then
               cr:set_source(active_color)
            else
               cr:set_source(open_color)
            end
            cr:rectangle(sa.x - start_x, sa.y - start_y, sa.width, sa.height)
            cr:fill()

            cr:set_source(border_color)
            cr:rectangle(sa.x - start_x, sa.y - start_y, sa.width, sa.height)
            cr:set_line_width(10.0)
            if to_highlight then
               cr:stroke()
            else
               cr:set_dash({5, 5}, 0)
               cr:stroke()
               cr:set_dash({}, 0)
            end
            cr:reset_clip()
         end

         cr:select_font_face(label_font_family, "normal", "normal")
         cr:set_font_size(info_size)
         cr:set_font_face(cr:get_font_face())
         msg = current_info
         ext = cr:text_extents(msg)
         cr:move_to(width / 2 - ext.width / 2 - ext.x_bearing, height / 2 - ext.height / 2 - ext.y_bearing)
         cr:text_path(msg)
         cr:set_source_rgba(1, 1, 1, 1)
         cr:fill()
         cr:move_to(width / 2 - ext.width / 2 - ext.x_bearing, height / 2 - ext.height / 2 - ext.y_bearing)
         cr:text_path(msg)
         cr:set_source_rgba(0, 0, 0, 1)
         cr:set_line_width(2.0)
         cr:stroke()
      end

      local function refresh()
         log(DEBUG, "closed areas:")
         for i, a in ipairs(closed_areas) do
            log(DEBUG, "  " .. _area_tostring(a))
         end
         log(DEBUG, "open areas:")
         for i, a in ipairs(open_areas) do
            log(DEBUG, "  " .. _area_tostring(a))
         end
         infobox.bgimage = draw_info
      end

      log(DEBUG, "interactive layout editing starts")

      init(screen.workarea, inner_gap / 2 - outer_gap)
      refresh()

      kg = api.awful.keygrabber.run(
         function (mod, key, event)
            if event == "release" then
               return
            end

            local ok, err = pcall(
               function ()
                  if pending_op ~= nil then
                     pop_history()
                  end

                  if key == "BackSpace" then
                     pop_history()
                  elseif key == "Escape" then
                     table.remove(data.cmds, #data.cmds)
                     to_exit = true
                  elseif key == "Up" or key == "Down" then
                     if current_cmd ~= data.cmds[cmd_index] then
                        data.cmds[#data.cmds] = current_cmd
                     end

                     if key == "Up" and cmd_index > 1 then
                        cmd_index = cmd_index - 1
                     elseif key == "Down" and cmd_index < #data.cmds then
                        cmd_index = cmd_index + 1
                     end

                     log(DEBUG, "restore history #" .. tostring(cmd_index) .. ":" .. data.cmds[cmd_index])
                     init(screen.workarea, inner_gap / 2 - outer_gap)
                     for i = 1, #data.cmds[cmd_index] do
                        local cmd = data.cmds[cmd_index]:sub(i, i)

                        push_history()
                        local ret = handle_ch(cmd)

                        if ret == nil then
                           log(WARNING, "ret is nil")
                        else
                           current_info = current_info .. ret
                           current_cmd = current_cmd .. ret
                        end
                     end

                     if #open_areas == 0 then
                        current_info = current_info .. " (enter to save)"
                     end
                  elseif #open_areas > 0 then
                     push_history()
                     local ret = handle_ch(key)
                     if ret ~= nil then
                        current_info = current_info .. ret
                        current_cmd = current_cmd .. ret
                     else
                        pop_history()
                     end

                     if #open_areas == 0 then
                        current_info = current_info .. " (enter to apply)"
                     end
                  else
                     if key == "Return" then
                        table.remove(data.cmds, #data.cmds)
                        -- remove duplicated entries
                        local j = 1
                        for i = 1, #data.cmds do
                           if data.cmds[i] ~= current_cmd then
                              data.cmds[j] = data.cmds[i]
                              j = j + 1
                           end
                        end
                        for i = #data.cmds, j, -1 do
                           table.remove(data.cmds, i)
                        end
                        -- bring the current cmd to the front
                        data.cmds[#data.cmds + 1] = current_cmd

                        local instance_name, persistent = layout.machi_get_instance_info(tag)
                        if persistent then
                           data.last_cmd[instance_name] = current_cmd
                           if data.history_file then
                              local file, err = io.open(data.history_file, "w")
                              if err then
                                 log(ERROR, "cannot save history to " .. data.history_file)
                              else
                                 for i = max(1, #data.cmds - data.history_save_max + 1), #data.cmds do
                                    log(DEBUG, "save cmd " .. data.cmds[i])
                                    file:write(data.cmds[i] .. "\n")
                                 end
                                 for name, cmd in pairs(data.last_cmd) do
                                    log(DEBUG, "save last cmd " .. cmd .. " for " .. name)
                                    file:write("+" .. name .. "\n" .. cmd .. "\n")
                                 end
                              end
                              file:close()
                           end
                           current_info = "Saved!"
                        else
                           current_info = "Applied!"
                        end

                        to_exit = true
                        to_apply = true
                     end
                  end

                  if not to_exit and pending_op ~= nil then
                     push_history()
                     handle_op(pending_op)
                  end

                  refresh()

                  if to_exit then
                     log(DEBUG, "interactive layout editing ends")
                     if to_apply then
                        layout.machi_set_cmd(current_cmd, tag)
                        api.layout.arrange(screen)
                        api.gears.timer{
                           timeout = 1,
                           autostart = true,
                           singleshot = true,
                           callback = cleanup,
                        }
                     else
                        cleanup()
                     end
                  end
            end)

            if not ok then
               log(ERROR, "Getting error in keygrabber: " .. err)
               to_exit = true
               cleanup()
            end

            if to_exit then
               api.awful.keygrabber.stop(kg)
            end
         end
      )
   end

   local function run_cmd(init_area, cmd)
      local outer_gap = data.outer_gap or data.gap or api.beautiful.useless_gap * 2 or 0
      local inner_gap = data.inner_gap or data.gap or api.beautiful.useless_gap * 2 or 0
      init(init_area, inner_gap / 2 - outer_gap)

      for i = 1, #cmd do
         handle_ch(cmd:sub(i, i))
      end

      local areas_with_gap = {}
      for _, a in ipairs(closed_areas) do
         areas_with_gap[#areas_with_gap + 1] = shrink_area_with_gap(a, inner_gap, inner_gap / 2)
      end
      table.sort(
         areas_with_gap,
         function (a1, a2)
            local s1 = a1.width * a1.height
            local s2 = a2.width * a2.height
            if math.abs(s1 - s2) < 0.01 then
               return (a1.x + a1.y) < (a2.x + a2.y)
            else
               return s1 > s2
            end
         end
      )

      return areas_with_gap
   end

   local function get_last_cmd(name)
      return data.last_cmd[name]
   end

   return {
      start_interactive = start_interactive,
      run_cmd = run_cmd,
      get_last_cmd = get_last_cmd,
      set_gap = set_gap,
   }
end

module.default_editor = module.create()

return module
