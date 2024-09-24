--[[

     Fishlive Lua Library
     Collage Image Extension for Awesome WM

     Licensed under GNU General Public License v2
      * (c) 2022, A.Fischer
--]]

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local surface = require("gears.surface")
local helpers = require("fishlive.helpers")
local capi = {
  screen = screen
}

-- fishlive collage submodule
-- fishlive.collage
local collage = { _NAME = "fishlive.collage" }

function collage.align(align, posx, posy, imgwidth, imgheight, screen)
  if align == "top-left" then uposx = posx; uposy = posy
  elseif align == "top-right" then uposx = posx - imgwidth; uposy = posy
  elseif align == "bottom-left" then uposx = screen.geometry.width - posx + imgwidth; uposy = screen.geometry.height - posy - imgheight
  elseif align == "bottom-right" then uposx = screen.geometry.width - posx - imgwidth; uposy = screen.geometry.height - posy - imgheight
  end
  return uposx, uposy
end

function collage.calcImageRes(imgsrc, reqimgwidth, reqimgheight)
  local image = surface.load(imgsrc)
  local imgwidth = image.width
  local imgheight = image.height
  local imgratio = 1.0

  --too small images - upscale to 75% of reqimgwidth, reqimgheight
  if imgwidth < reqimgwidth * 0.75 and reqimgwidth ~= -1 then
    imgratio = reqimgwidth * 0.75/imgwidth
    imgwidth = reqimgwidth * 0.75
    imgheight = imgheight * imgratio
  end
  if imgheight < reqimgheight * 0.75 and reqimgheight ~= -1 then
    imgratio = reqimgheight * 0.75/imgheight
    imgwidth = imgwidth * imgratio
    imgheight = reqimgheight * 0.75
  end

  -- too big images
  if imgwidth > reqimgwidth and reqimgwidth ~= -1 then
    imgratio = reqimgwidth/imgwidth
    imgwidth = reqimgwidth
    imgheight = imgheight * imgratio
  end
  if imgheight > reqimgheight and reqimgheight ~= -1 then
    imgratio = reqimgheight/imgheight
    imgwidth = imgwidth * imgratio
    imgheight = reqimgheight
  end

  return imgwidth, imgheight, imgratio
end

function collage.calcShadow(imgwidth, imgheight, uposx, uposy)
  local width = imgwidth+50*imgwidth/370
  local height = imgheight+70*imgheight/550
  local x = uposx - 25*imgwidth/370
  local y = uposy - 23*imgheight/550

  return width, height, x, y
end

function collage.placeCollageImage(s, reqimgwidth, reqimgheight, posx, posy, align, imgsrcs, imgidx, ontop)
  local homeDir = os.getenv("HOME")
  local shadowsrc = homeDir .. "/.config/awesome/fishlive/collage/shadow.png"
  local imgsrc = imgsrcs[imgidx]

  local imgwidth, imgheight, imgratio = collage.calcImageRes(imgsrc, reqimgwidth, reqimgheight)
  local uposx, uposy = collage.align(align, posx, posy, imgwidth, imgheight, s)
  local shwWidth, shwHeight, shwX, shwY = collage.calcShadow(imgwidth, imgheight, uposx, uposy)
  local ontop = ontop or false and true

  local geom = s.geometry

  local imgboxShw = wibox({
      screen = s,
      type = "desktop",
      width = shwWidth,
      height = shwHeight,
      x = geom.x + shwX,
      y = geom.y + shwY,
      visible = true,
      ontop = ontop,
      opacity = 1.00,
      bg = "#00000000",
  })
  imgboxShw:setup{
      layout = wibox.layout.fixed.vertical,
      {
          id = "shadow",
          widget = wibox.widget.imagebox,
          forced_width = shwWidth,
          forced_height = shwHeight,
          horizontal_fit_policy = "fit",
          vertical_fit_policy = "fit",
          resize = true,
          image = gears.surface.load_uncached(shadowsrc)
      }
  }
  local imgbox = wibox({
      screen = s,
      type = "desktop",
      width = imgwidth,
      height = imgheight,
      x = geom.x + uposx,
      y = geom.y + uposy,
      visible = true,
      ontop = ontop,
      opacity = 1.0,
      bg = "#00000000",
  })
  imgbox:setup{
      {
          id = "img",
          clip_shape = gears.shape.rounded_rect,
          widget = wibox.widget.imagebox,
      },
      layout = wibox.layout.fixed.vertical
  }
  imgbox:get_children_by_id("img")[1].image = gears.surface.load_uncached(imgsrc)
  imgbox:connect_signal('button::press', function(self, _, _, button)
      if button == 5 then imgidx = imgidx + 1
      elseif button == 4 then imgidx = imgidx - 1
      elseif button == 3 then
        awesome.emit_signal("dashboard::close")
        awful.spawn.with_shell('qimgv "'..imgsrcs[imgidx]..'"')
      elseif button == 2 then
        awesome.emit_signal("dashboard::close")
        awful.spawn.with_line_callback("zenity --file-selection --directory --filename="..helpers.getPathFrom(imgsrcs[imgidx]), {
          stdout = function(dir)
            _, imgsrcs = helpers.getImgsFromDir(dir)
            imgidx = 1
          end
        })
      else return
      end

      if imgidx == 0 then imgidx = #imgsrcs end
      if imgidx > #imgsrcs then imgidx = 1 end
      imgsrc = imgsrcs[imgidx]
      imgwidth, imgheight, imgratio = collage.calcImageRes(imgsrc, reqimgwidth, reqimgheight)
      uposx, uposy = collage.align(align, posx, posy, imgwidth, imgheight, s)
      shwWidth, shwHeight, shwX, shwY = collage.calcShadow(imgwidth, imgheight, uposx, uposy)

      imgboxShw.screen = s
      imgboxShw.x = geom.x + shwX
      imgboxShw.y = geom.y + shwY
      imgboxShw.width = shwWidth
      imgboxShw.height = shwHeight
      shwWibox = imgboxShw:get_children_by_id("shadow")[1]
      shwWibox.image = gears.surface.load_uncached(shadowsrc)
      shwWibox.forced_width = shwWidth
      shwWibox.forced_height = shwHeight
      shwWibox.horizontal_fit_policy = "fit"
      shwWibox.vertical_fit_policy = "fit"
      self.screen = s
      self.width = imgwidth
      self.height = imgheight
      self.x = geom.x + uposx
      self.y = geom.y + uposy
      self:get_children_by_id("img")[1].image = gears.surface.load_uncached(imgsrc)
  end)

  return { image = imgbox, shadow = imgboxShw }
end

-- function for search and find tag according to bidx or index
local function find_tag_by_ids(id)
  for scr in capi.screen do
      -- check if bidx is used bidx (for shared tags)
      local use_bidx = scr.tags[1] and scr.tags[1].bidx ~= nil

      for _, tag in ipairs(scr.tags) do
              if (use_bidx and tag.bidx == id) or (not use_bidx and tag.index == id) then
                  return tag, scr  -- return found tag and its screen
              end
      end
  end
  return nil
end

-- Tag Collage Changer
function collage.registerTagCollage(t)
  local collage_template = t.collage_template
  local imgsources = t.imgsources
  local tagids = t.tagids
  local imgboxes = nil

  for t = 1,#tagids do
    local tag = find_tag_by_ids(tagids[t])
    if tag then
      tag:connect_signal("property::selected", function (tag)
        -- if not selected, hide collage
        if not tag.selected and imgboxes ~= nil then
          for i = 1,#imgboxes do
            imgboxes[i].image.visible = false
            imgboxes[i].shadow.visible = false
            imgboxes[i].image:get_children_by_id("img")[1].visible = false
            imgboxes[i].shadow:get_children_by_id("shadow")[1].visible = false
          end
          return
        end
        -- if not created, create it
        if imgboxes == nil then
          imgboxes = {}
          for i = 1,#collage_template do
            imgboxes[i] = collage.placeCollageImage(
              tag.screen,
              collage_template[i].max_width or -1,
              collage_template[i].max_height or -1,
              collage_template[i].posx or 0,
              collage_template[i].posy or 0,
              collage_template[i].align or "top-left",
              imgsources,
              i
            )
          end
        else
          -- already created, just show it
          for i = 1,#imgboxes do
            imgboxes[i].shadow.visible = true
            imgboxes[i].image.visible = true
            imgboxes[i].shadow:get_children_by_id("shadow")[1].visible = true
            imgboxes[i].image:get_children_by_id("img")[1].visible = true
          end
        end
      end)
    end
  end
end

return collage
