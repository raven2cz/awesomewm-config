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

-- fishlive collage submodule
-- fishlive.collage
local collage = { _NAME = "fishlive.collage" }

function collage.align(align, posx, posy, imgwidth, imgheight)
  if align == "top-left" then uposx = posx; uposy = posy
  elseif align == "top-right" then uposx = posx - imgwidth; uposy = posy
  elseif align == "bottom-left" then uposx = posx + imgwidth; uposy = posy - imgheight
  elseif align == "bottom-right" then uposx = posx - imgwidth; uposy = posy - imgheight
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

function collage.placeCollageImage(reqimgwidth, reqimgheight, posx, posy, align, imgsrcs, imgidx, ontop)
  local homeDir = os.getenv("HOME")
  local shadowsrc = homeDir .. "/.config/awesome/fishlive/collage/shadow.png"
  local imgsrc = imgsrcs[imgidx]

  local imgwidth, imgheight, imgratio = collage.calcImageRes(imgsrc, reqimgwidth, reqimgheight)
  local uposx, uposy = collage.align(align, posx, posy, imgwidth, imgheight)
  local shwWidth, shwHeight, shwX, shwY = collage.calcShadow(imgwidth, imgheight, uposx, uposy)
  local ontop = ontop or false and true

  local imgboxShw = wibox({
      type = "desktop",
      width = shwWidth,
      height = shwHeight,
      x = shwX,
      y = shwY,
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
      type = "desktop",
      width = imgwidth,
      height = imgheight,
      x = uposx,
      y = uposy,
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
      uposx, uposy = collage.align(align, posx, posy, imgwidth, imgheight)
      shwWidth, shwHeight, shwX, shwY = collage.calcShadow(imgwidth, imgheight, uposx, uposy)

      imgboxShw.x = shwX
      imgboxShw.y = shwY
      imgboxShw.width = shwWidth
      imgboxShw.height = shwHeight
      shwWibox = imgboxShw:get_children_by_id("shadow")[1]
      shwWibox.image = gears.surface.load_uncached(shadowsrc)
      shwWibox.forced_width = shwWidth
      shwWibox.forced_height = shwHeight
      shwWibox.horizontal_fit_policy = "fit"
      shwWibox.vertical_fit_policy = "fit"
      self.width = imgwidth
      self.height = imgheight
      self.x = uposx
      self.y = uposy
      self:get_children_by_id("img")[1].image = gears.surface.load_uncached(imgsrc)
  end)

  return { image = imgbox, shadow = imgboxShw }
end

-- Tag Collage Changer
function collage.registerTagCollage(t)
  local screen = t.screen
  local collage_template = t.collage_template
  local imgsources = t.imgsources
  local tagids = t.tagids
  local imgboxes = nil

  -- For each screen
  for scr in screen do
    -- Go over each tag
    for t = 1,#tagids do
      local tag = scr.tags[tagids[t]]
      if tag == nil then goto continue end
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
      ::continue::
    end
  end
end

return collage
