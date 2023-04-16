local fishlive = require("fishlive")

-- load last colorscheme
local theme = fishlive.colorscheme.last

-- extended color base16 palette for urgent and focus events
theme.base10 = theme.base10 or theme.base00
theme.base18 = theme.base18 or theme.base08
theme.base1A = theme.base1A or theme.base0A

-- random shuffle foreground colors, 8 colors
theme.baseColors = {
  theme.base08,
  theme.base09,
  theme.base0A,
  theme.base0E,
  theme.base0C,
  theme.base0D,
  theme.base0B,
  theme.base18,
  theme.base1A,
}
fishlive.helpers.shuffle(theme.baseColors)
-- }}}

-- {{{ Styles
theme.fg_normal  = theme.fg_normal or theme.base06
theme.fg_focus   = theme.fg_focus or theme.base1A
theme.fg_urgent  = theme.fg_urgent or theme.base0E
theme.fg_minimize = theme.fg_minimize or theme.base07

theme.bg_normal  = theme.bg_normal or theme.base10
theme.bg_focus   = theme.bg_focus or theme.base00
theme.bg_urgent  = theme.bg_urgent or theme.base18
theme.bg_systray = theme.bg_systray or theme.base10
theme.bg_minimize = theme.bg_minimize or theme.base03
theme.bg_underline = theme.bg_underline or theme.base0C

theme.taglist_fg_focus = theme.taglist_fg_focus or theme.fg_normal

theme.layout_fg = theme.layout_fg or theme.fg_normal

theme.bg_systray = theme.bg_systray or theme.bg_normal

theme.notification_bg = theme.notification_bg or theme.bg_normal
theme.notification_fg = theme.notification_fg or theme.fg_focus
-- }}}

-- {{{ Borders
theme.border_color_normal = theme.border_color_normal or theme.base10
theme.border_color_active = theme.border_color_active or theme.base0A
theme.border_color_marked = theme.border_color_marked or theme.base0E
-- }}}

-- {{{ Titlebars
theme.titlebar_bg_focus  = theme.titlebar_bg_focus or theme.base02
theme.titlebar_bg_normal = theme.titlebar_bg_normal or theme.base02
-- }}}

-- {{{ Widgets
theme.widgetbar_fg  = theme.widgetbar_fg or theme.base05
theme.fg_widget     = theme.fg_widget or theme.base05
--theme.fg_center_widget = theme.fg_center_widget or "#88A175"
--theme.fg_end_widget    = theme.fg_end_widget or "#FF5656"
--theme.bg_widget        = theme.bg_widget or "#494B4F"
--theme.border_widget    = theme.border_widget or "#3F3F3F"
-- }}}

-- {{{ Awesome Icon and others specific widgets
theme.awesome_icon_bg = theme.awesome_icon_bg or theme.base0C
theme.awesome_icon_fg = theme.awesome_icon_fg or theme.base00
theme.clock_fg = theme.clock_fg or theme.base0A
-- }}}

-- {{{ Mouse finder
theme.mouse_finder_color = theme.mouse_finder_color or theme.base0E
-- }}}

-- {{{ Notification Center
theme.xcolor0 = theme.xcolor0 or theme.base02
theme.groups_bg  = theme.groups_bg or theme.base01
theme.xbackground = theme.xbackground or theme.base01
theme.bg_very_light = theme.bg_very_light or theme.base03
theme.bg_light = theme.bg_light or theme.base02
-- }}}

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
