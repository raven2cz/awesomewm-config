-- base16-nord
-- color palatte definition
local theme = {}

-- {{{ Colors
theme.scheme = "Nord"
theme.scheme_id = "nord"
theme.scheme_author = "arcticicestudio"
theme.scheme_type = "dark"
theme.base00 = "#2E3440"
theme.base01 = "#3B4252"
theme.base02 = "#434C5E"
theme.base03 = "#4C566A"
theme.base04 = "#D8DEE9"
theme.base05 = "#E5E9F0"
theme.base06 = "#ECEFF4"
theme.base07 = "#8FBCBB"
theme.base08 = "#88C0D0"
theme.base09 = "#81A1C1"
theme.base0A = "#5E81AC"
theme.base0B = "#BF616A"
theme.base0C = "#D08770"
theme.base0D = "#EBCB8B"
theme.base0E = "#A3BE8C"
theme.base0F = "#B48EAD"

theme.leading_fg = theme.base0A

-- specific modifs for nord required colors
theme.base10 = theme.base02
theme.base1A = theme.base08
theme.awesome_icon_bg = theme.base09
theme.clock_fg = theme.base07
theme.border_color_active = theme.base08
theme.bg_underline = theme.base0A
-- }}}

return theme
