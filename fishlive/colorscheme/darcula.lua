-- base16-darcula
-- color palatte definition
local theme = {}

-- {{{ Colors
theme.scheme = "Darcula"
theme.scheme_id = "darcula"
theme.scheme_author = "jetbrains"
theme.scheme_type = "dark"
theme.base00 = "#2b2b2b" --# background
theme.base01 = "#323232" --# line cursor
theme.base02 = "#323232" --# statusline
theme.base03 = "#606366" --# line numbers
theme.base04 = "#a4a3a3" --# selected line number
theme.base05 = "#a9b7c6" --# foreground
theme.base06 = "#ffc66d" --# bright yellow
theme.base07 = "#ffffff"
theme.base08 = "#4eade5" --# cyan
theme.base09 = "#689757" --# blue
theme.base0A = "#bbb529" --# yellow
theme.base0B = "#6a8759" --# string green
theme.base0C = "#629755" --# comment green
theme.base0D = "#9876aa" --# purple
theme.base0E = "#cc7832" --# orange
theme.base0F = "#808080" --# gray

theme.leading_fg = theme.base0E

-- specific modifs for darcula required colors
theme.border_color_active = theme.base0E
-- }}}

return theme
