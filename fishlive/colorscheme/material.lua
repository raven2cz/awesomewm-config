-- base16-material
-- color palatte definition
local theme = {}

-- {{{ Colors
theme.scheme = "Material"
theme.scheme_id = "material"
theme.scheme_author = "Nate Peterson"
theme.scheme_type = "dark"
theme.base00 = "#263238"
theme.base01 = "#2E3C43"
theme.base02 = "#314549"
theme.base03 = "#546E7A"
theme.base04 = "#B2CCD6"
theme.base05 = "#EEFFFF"
theme.base06 = "#EEFFFF"
theme.base07 = "#FFFFFF"
theme.base08 = "#F07178"
theme.base09 = "#F78C6C"
theme.base0A = "#FFCB6B"
theme.base0B = "#C3E88D"
theme.base0C = "#89DDFF"
theme.base0D = "#82AAFF"
theme.base0E = "#C792EA"
theme.base0F = "#FF5370"

theme.leading_fg = theme.base0C

-- specific modifs for nord required colors
theme.fg_focus = theme.base0C
theme.clock_fg = theme.base0C
theme.border_color_active = theme.base0C
-- }}}

return theme
