-- This returns the "Wow, such empty." message.
local beautiful = require("beautiful")
local wibox = require('wibox')

local dpi = require('beautiful').xresources.apply_dpi


local empty_notifbox = wibox.widget {
	{
		layout = wibox.layout.fixed.vertical,
		spacing = dpi(5),
		{
			expand = 'none',
			layout = wibox.layout.align.horizontal,
			nil, 
			{
				image = beautiful.notification_none_icon, 
				resize = true,
				forced_height = dpi(35),
				forced_width = dpi(35),
				widget = wibox.widget.imagebox,
			},
			nil
		},
		{
			markup = '<span strikethrough="true">You have no life</span>\nYou have no notifs!',
			font = 'JetBrains Mono 10',
			align = 'center',
			valign = 'center',
			widget = wibox.widget.textbox
		}
	},
	margins = dpi(20),
	widget = wibox.container.margin

}

-- Make empty_notifbox center
local centered_empty_notifbox = wibox.widget {
	layout = wibox.layout.fixed.vertical,
	expand = 'none',
	empty_notifbox,
}

return centered_empty_notifbox

