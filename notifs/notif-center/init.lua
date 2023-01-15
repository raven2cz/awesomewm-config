local wibox = require('wibox')
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local notif_header = wibox.widget {
	markup   = '<b>Notification Center</b>',
	font   = "JetBrains Mono 12",
	align  = 'center',
	valign = 'center',
	widget = wibox.widget.textbox
}

return wibox.widget {
	{
		nil,
		notif_header,
		require("notifs.notif-center.clear-all"),
		expand = "none",
		spacing = dpi(10),
		layout = wibox.layout.align.horizontal,
	},
	require('notifs.notif-center.build-notifbox'),
	spacing = dpi(10),
	layout = wibox.layout.fixed.vertical
}
