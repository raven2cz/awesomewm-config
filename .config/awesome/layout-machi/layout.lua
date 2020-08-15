local machi = {
   editor = require((...):match("(.-)[^%.]+$") .. "editor"),
}

local api = {
   screen = screen,
   awful = require("awful"),
}

local ERROR = 2
local WARNING = 1
local INFO = 0
local DEBUG = -1

local module = {
   log_level = WARNING,
   global_default_cmd = "dw66.",
   allowing_shrinking_by_mouse_moving = false,
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

local function get_screen(s)
    return s and api.screen[s]
end

api.awful.mouse.resize.add_enter_callback(
   function (c)
      c.full_width_before_move = c.width + c.border_width * 2
      c.full_height_before_move = c.height + c.border_width * 2
   end, 'mouse.move')

--- find the best region for the area-like object
-- @param c       area-like object - table with properties x, y, width, and height
-- @param regions array of area-like objects
-- @return the index of the best region
local function find_region(c, regions)
   local choice = 1
   local choice_value = nil
   local c_area = c.width * c.height
   for i, a in ipairs(regions) do
      local x_cap = max(0, min(c.x + c.width, a.x + a.width) - max(c.x, a.x))
      local y_cap = max(0, min(c.y + c.height, a.y + a.height) - max(c.y, a.y))
      local cap = x_cap * y_cap
      -- -- a cap b / a cup b
      -- local cup = c_area + a.width * a.height - cap
      -- if cup > 0 then
      --    local itx_ratio = cap / cup
      --    if choice_value == nil or choice_value < itx_ratio then
      --       choice_value = itx_ratio
      --       choice = i
      --    end
      -- end
      -- a cap b
      if choice_value == nil or choice_value < cap then
         choice = i
         choice_value = cap
      end
   end
   return choice
end

local function distance(x1, y1, x2, y2)
   -- use d1
   return math.abs(x1 - x2) + math.abs(y1 - y2)
end

local function find_lu(c, regions, rd)
   local lu = nil
   for i, a in ipairs(regions) do
      if rd == nil or (a.x < regions[rd].x + regions[rd].width and a.y < regions[rd].y + regions[rd].height) then
         if lu == nil or distance(c.x, c.y, a.x, a.y) < distance(c.x, c.y, regions[lu].x, regions[lu].y) then
            lu = i
         end
      end
   end
   return lu
end

local function find_rd(c, regions, lu)
   local x, y
   x = c.x + c.width + (c.border_width or 0)
   y = c.y + c.height + (c.border_width or 0)
   local rd = nil
   for i, a in ipairs(regions) do
      if lu == nil or (a.x + a.width > regions[lu].x and a.y + a.height > regions[lu].y) then
         if rd == nil or distance(x, y, a.x + a.width, a.y + a.height) < distance(x, y, regions[rd].x + regions[rd].width, regions[rd].y + regions[rd].height) then
            rd = i
         end
      end
   end
   return rd
end

function module.set_geometry(c, region_lu, region_rd, useless_gap, border_width)
   -- We try to negate the gap of outer layer
   if region_lu ~= nil then
      c.x = region_lu.x - useless_gap
      c.y = region_lu.y - useless_gap
   end

   if region_rd ~= nil then
      c.width = region_rd.x + region_rd.width - c.x + useless_gap - border_width * 2
      c.height = region_rd.y + region_rd.height - c.y + useless_gap - border_width * 2
   end
end

function module.create(args_or_name, editor, default_cmd)
    local args
    if type(args_or_name) == "string" then
        args = {
            name = args_or_name
        }
    elseif type(args_or_name) == "function" then
        args = {
            name_func = args_or_name
        }
    elseif type(args_or_name) == "table" then
        args = args_or_name
    else
        return nil
    end
    args.editor = args.editor or editor or machi.editor.default_editor
    args.default_cmd = args.default_cmd or default_cmd or global_default_cmd
    args.persistent = args.persistent == nil or args.persistent

    local instances = {}

    local function get_instance_info(tag)
        return (args.name_func and args.name_func(tag) or args.name), args.persistent
    end

   local function get_instance_(tag)
       local name, persistent = get_instance_info(tag)
       if instances[name] == nil then
           instances[name] = {
               cmd = persistent and args.editor.get_last_cmd(name) or nil,
               regions_cache = {},
           }
         if instances[name].cmd == nil then
             instances[name].cmd = default_cmd
         end
      end
      return instances[name]
   end

   local function get_regions(workarea, tag)
      local instance = get_instance_(tag)
      local cmd = instance.cmd or module.global_default_cmd
      if cmd == nil then return {}, false end

      local key = tostring(workarea.width) .. "x" .. tostring(workarea.height) .. "+" .. tostring(workarea.x) .. "+" .. tostring(workarea.y)
      if instance.regions_cache[key] == nil then
         instance.regions_cache[key] = args.editor.run_cmd(workarea, cmd)
      end
      return instance.regions_cache[key], cmd:sub(1,1) == "d"
   end

   local function set_cmd(cmd, tag)
      local instance = get_instance_(tag)
      if instance.cmd ~= cmd then
         instance.cmd = cmd
         instance.regions_cache = {}
      end
   end

   local function arrange(p)
      local useless_gap = p.useless_gap
      local wa = get_screen(p.screen).workarea -- get the real workarea without the gap (instead of p.workarea)
      local cls = p.clients
      local regions, draft_mode = get_regions(wa, get_screen(p.screen).selected_tag)

      if #regions == 0 then return end

      if draft_mode then
         for i, c in ipairs(cls) do
            if c.floating then
            else
               local skip = false
               if c.machi_lu ~= nil and c.machi_rd ~= nil and
                  c.machi_lu <= #regions and c.machi_rd <= #regions
               then
                  if regions[c.machi_lu].x == c.x and
                     regions[c.machi_lu].y == c.y and
                     regions[c.machi_rd].x + regions[c.machi_rd].width - c.border_width * 2 == c.x + c.width and
                     regions[c.machi_rd].y + regions[c.machi_rd].height - c.border_width * 2 == c.y + c.height
                  then
                     skip = true
                  end
               end

               local lu = nil
               local rd = nil
               if not skip then
                  log(DEBUG, "Compute regions for " .. (c.name or ("<untitled:" .. tostring(c) .. ">")))
                  lu = find_lu(c, regions)
                  if lu ~= nil then
                     c.x = regions[lu].x
                     c.y = regions[lu].y
                     rd = find_rd(c, regions, lu)
                  end
               end

               if lu ~= nil and rd ~= nil then
                  c.machi_lu, c.machi_rd = lu, rd
                  p.geometries[c] = {}
                  module.set_geometry(p.geometries[c], regions[lu], regions[rd], useless_gap, 0)
               end
            end
         end
      else
         for i, c in ipairs(cls) do
            if c.floating then
               log(DEBUG, "Ignore client " .. tostring(c))
            else
               if c.machi_region ~= nil and
                  regions[c.machi_region].x == c.x and
                  regions[c.machi_region].y == c.y and
                  regions[c.machi_region].width - c.border_width * 2 == c.width and
                  regions[c.machi_region].height - c.border_width * 2 == c.height
               then
               else
                  log(DEBUG, "Compute regions for " .. (c.name or ("<untitled:" .. tostring(c) .. ">")))
                  local region = find_region(c, regions)
                  c.machi_region = region
                  p.geometries[c] = {}
                  module.set_geometry(p.geometries[c], regions[region], regions[region], useless_gap, 0)
               end
            end
         end
      end
   end

   local function resize_handler (c, context, h)
      local workarea = c.screen.workarea
      local regions, draft_mode = get_regions(workarea, c.screen.selected_tag)

      if #regions == 0 then return end

      if draft_mode then
         local lu = find_lu(h, regions)
         local rd = nil
         if lu ~= nil then
            if context == "mouse.move" then
               -- Use the initial width and height since it may change in undesired way.
               local hh = {}
               hh.x = regions[lu].x
               hh.y = regions[lu].y
               hh.width = c.full_width_before_move
               hh.height = c.full_height_before_move
               rd = find_rd(hh, regions, lu)

               if rd ~= nil and not module.allowing_shrinking_by_mouse_moving and
                  (regions[rd].x + regions[rd].width - regions[lu].x < c.full_width_before_move or
                   regions[rd].y + regions[rd].height - regions[lu].y < c.full_height_before_move) then
                     hh.x = regions[rd].x + regions[rd].width - c.full_width_before_move
                     hh.y = regions[rd].y + regions[rd].height - c.full_height_before_move
                     lu = find_lu(hh, regions, rd)
               end
            else
               local hh = {}
               hh.x = h.x
               hh.y = h.y
               hh.width = h.width
               hh.height = h.height
               hh.border_width = c.border_width
               rd = find_rd(hh, regions, lu)
            end

            if lu ~= nil and rd ~= nil then
               c.machi_lu = lu
               c.machi_rd = rd
               module.set_geometry(c, regions[lu], regions[rd], 0, c.border_width)
            end
         end
      else
         if context ~= "mouse.move" then return end

         local workarea = c.screen.workarea
         local regions = get_regions(workarea, c.screen.selected_tag)

         if #regions == 0 then return end

         local center_x = h.x + h.width / 2
         local center_y = h.y + h.height / 2

         local choice = 1
         local choice_value = nil

         for i, r in ipairs(regions) do
            local r_x = r.x + r.width / 2
            local r_y = r.y + r.height / 2
            local dis = (r_x - center_x) * (r_x - center_x) + (r_y - center_y) * (r_y - center_y)
            if choice_value == nil or choice_value > dis then
               choice = i
               choice_value = dis
            end
         end

         if c.machi_region ~= choice then
            c.machi_region = choice
            module.set_geometry(c, regions[choice], regions[choice], 0, c.border_width)
         end
      end
   end

   return {
      name = "machi",
      arrange = arrange,
      resize_handler = resize_handler,
      machi_get_instance_info = get_instance_info,
      machi_set_cmd = set_cmd,
      machi_get_regions = get_regions,
   }
end

return module
