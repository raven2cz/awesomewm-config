local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')

local button = require("widgets.button")
local dpi = require('beautiful').xresources.apply_dpi

local config_dir = gears.filesystem.get_configuration_dir()
local widget_icon_dir = config_dir .. 'notifs/notif-center/icons/'

local delete_button = button.create_image_onclick(beautiful.clear_grey_icon, beautiful.clear_icon, function() _G.reset_notifbox_layout() end)


local delete_button_wrapped = wibox.widget {
	nil,
	{
		delete_button,
		widget = wibox.container.background,
		forced_height = dpi(24), 
		forced_width = dpi(24)
	},
	nil,
	expand = 'none',
	layout = wibox.layout.align.vertical
}

return delete_button_wrapped
