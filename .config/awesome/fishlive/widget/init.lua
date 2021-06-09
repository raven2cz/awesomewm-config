--[[

     Fishlive Lua Library
     Layouts, widgets and utilities for Awesome WM

     Widget section

     Licensed under GNU General Public License v2
      * (c) 2021, A.Fischer
--]]

local awful = require("awful")
local wibox = require("wibox")

-- fishlive widget submodule
-- fishlive.widget
local widget = { _NAME = "fishlive.widget" }

-- => Defaults
-- ============================================================
local _private = {}
_private.max_width = 0
_private.max_height = 0

function widget.wiboxBoxIconUnderline(icon, wbox, colorLine, leftIn, rightIn, underLineSize, wiboxMargin)
  return {
    {
      wibox.container.margin(wibox.widget { icon, wbox, layout = wibox.layout.align.horizontal }, leftIn, rightIn),
      bottom=underLineSize,
      color=colorLine,
      widget=wibox.container.margin
    },
    left = wiboxMargin,
    right = wiboxMargin,
    layout = wibox.container.margin
  }
end

function widget.wiboxBox0Underline(wbox, colorLine, leftIn, rightIn, underLineSize, wiboxMargin)
  return {
    {
      wibox.container.margin(wibox.widget { wbox, layout = wibox.layout.align.horizontal }, leftIn, rightIn),
      bottom=underLineSize,
      color=colorLine,
      widget=wibox.container.margin
    },
    left = wiboxMargin,
    right = wiboxMargin,
    layout = wibox.container.margin
  }
end

function widget.wiboxBox2IconUnderline(icon, wbox, wbox2, colorLine, leftIn, rightIn, underLineSize, wiboxMargin)
  return {
    {
      wibox.container.margin(wibox.widget { icon, wbox, wbox2, layout = wibox.layout.align.horizontal }, leftIn, rightIn),
      bottom=underLineSize,
      color=colorLine,
      widget=wibox.container.margin
    },
    left = wiboxMargin,
    right = wiboxMargin,
    layout = wibox.container.margin
  }
end

function widget.initialize(args)
  if args then
    for prop, value in pairs(args) do
      _private[prop] = value
    end
  end
end

return setmetatable(
           widget, {__call = function(_, ...) return widget.initialize(...) end})
