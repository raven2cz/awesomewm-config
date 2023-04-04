--[[

     Fishlive Lua Library
     Layouts, widgets and utilities for Awesome WM

     Widget section

     Licensed under GNU General Public License v2
      * (c) 2022, A.Fischer
--]]

local awful = require("awful")
local wibox = require("wibox")
local wrequire = require("fishlive.helpers").wrequire
local setmetatable = setmetatable

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

    hide_fct = hide_fct or function(object)
        if only_outside and object == widget then
            return
        end
        if widget.get_active_menu then
          if only_outside and object == widget:get_active_menu() then
            return
          end
        end
        if widget.hide then
          widget:hide()
        else
          widget.visible = false
        end
    end

    local click_bind = awful.button({}, 1, hide_fct)

    -- when the widget is visible, we hide it on button press
    widget:connect_signal('property::visible', function(w)
            if not w.visible then
                wibox.disconnect_signal("button::press", hide_fct)
                client.disconnect_signal("button::press", hide_fct)
                awful.mouse.remove_global_mousebinding(click_bind)
            else
                awful.mouse.append_global_mousebinding(click_bind)
                client.connect_signal("button::press", hide_fct)
                wibox.connect_signal("button::press", hide_fct)
            end
    end)
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

return setmetatable(widget, { __index = wrequire, __call = function(_, ...) return widget.initialize(...) end })

