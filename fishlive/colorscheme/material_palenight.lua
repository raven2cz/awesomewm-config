-- base16-material-palenight
-- color palatte definition
local theme = {}

-- {{{ Colors
theme.scheme = "Material, palenight"
theme.scheme_id = "material_palenight"
theme.scheme_author = "Nate Peterson"
theme.scheme_type = "dark"
theme.base00 = "#292D3E"
theme.base01 = "#444267"
theme.base02 = "#32374D"
theme.base03 = "#676E95"
theme.base04 = "#8796B0"
theme.base05 = "#959DCB"
theme.base06 = "#959DCB"
theme.base07 = "#FFFFFF"
theme.base08 = "#F07178"
theme.base09 = "#F78C6C"
theme.base0A = "#FFCB6B"
theme.base0B = "#C3E88D"
theme.base0C = "#89DDFF"
theme.base0D = "#82AAFF"
theme.base0E = "#C792EA"
theme.base0F = "#FF5370"

theme.leading_fg = theme.base0E

-- specific modifs for nord required colors
theme.fg_focus = theme.base0E
theme.clock_fg = theme.base0E
theme.border_color_active = theme.base0E
theme.bg_underline = theme.base06
-- }}}

return theme
