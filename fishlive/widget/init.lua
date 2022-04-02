--[[

     Fishlive Lua Library
     Layouts, widgets and utilities for Awesome WM

     Widget section

     Licensed under GNU General Public License v2
      * (c) 2022, A.Fischer
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

function widget.wiboxBoxIconUnderline(icon, wbox, colorLine, fgcolor, leftIn, rightIn, underLineSize, wiboxMargin)
  return {
    {
      {
        wibox.container.margin(wibox.widget { icon, wbox, layout = wibox.layout.align.horizontal }, leftIn, rightIn),
        fg = fgcolor,
        widget = wibox.container.background
      },
      bottom = underLineSize,
      color = colorLine,
      fg = fgcolor,
      layout = wibox.container.margin
    },
    left = wiboxMargin,
    right = wiboxMargin,
    bottom = 2,
    layout = wibox.container.margin
  }
end

function widget.wiboxBox0Underline(wbox, colorLine, fgcolor, leftIn, rightIn, underLineSize, wiboxMargin)
  return {
    {
      {
        wibox.container.margin(wibox.widget { wbox, layout = wibox.layout.align.horizontal }, leftIn, rightIn),
        fg = fgcolor,
        widget = wibox.container.background
      },
      bottom = underLineSize,
      color = colorLine,
      fg =fgcolor,
      layout = wibox.container.margin
    },
    left = wiboxMargin,
    right = wiboxMargin,
    bottom = 2,
    layout = wibox.container.margin
  }
end

function widget.wiboxBox2IconUnderline(icon, wbox, wbox2, colorLine, fgcolor, leftIn, rightIn, underLineSize, wiboxMargin)
  return {
    {
      {
        wibox.container.margin(wibox.widget { icon, wbox, wbox2, layout = wibox.layout.align.horizontal }, leftIn, rightIn),
        fg = fgcolor,
        widget = wibox.container.background
      },
      bottom = underLineSize,
      color = colorLine,
      fg = fgcolor,
      layout = wibox.container.margin
    },
    left = wiboxMargin,
    right = wiboxMargin,
    bottom = 2,
    layout = wibox.container.margin
  }
end

-- Click to hide widget Support

local capi = { button = button, mouse = mouse }

function widget.click_to_hide(widget, hide_fct, only_outside)
	only_outside = only_outside or false

	hide_fct = hide_fct or function()
		widget.visible = false
	end

	-- when the widget is visible, we hide it on button press
	widget:connect_signal("property::visible", function(w)
		if not w.visible then
			capi.button.disconnect_signal("press", hide_fct)
		else
			-- the mouse button is pressed here, we have to wait for the release
			local function connect_to_press()
				capi.button.disconnect_signal("release", connect_to_press)
				capi.button.connect_signal("press", hide_fct)
			end
			capi.button.connect_signal("release", connect_to_press)
		end
	end)

	if only_outside then
		-- disable hide on click when the mouse is inside the widget
		widget:connect_signal("mouse::enter", function()
			capi.button.disconnect_signal("press", hide_fct)
		end)

		widget:connect_signal("mouse::leave", function()
			capi.button.connect_signal("press", hide_fct)
		end)
	end
end

function widget.click_to_hide_menu(menu, hide_fct, outside_only)
	hide_fct = hide_fct or function()
		menu:hide()
	end

	widget.click_to_hide(menu.wibox, hide_fct, outside_only)
end

-- initialize util

function widget.initialize(args)
  if args then
    for prop, value in pairs(args) do
      _private[prop] = value
    end
  end
end

return setmetatable(widget, {__call = function(_, ...) return widget.initialize(...) end})
