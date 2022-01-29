-- base16-solarized_dark
-- color palatte definition
local theme = {}

-- {{{ Colors
theme.scheme = "Solarized Dark"
theme.scheme_id = "solarized_dark"
theme.scheme_author = "Ethan Schoonover (modified by aramisgithub)"
theme.scheme_type = "dark"
theme.base00 = "#002b36"
theme.base01 = "#073642"
theme.base02 = "#586e75"
theme.base03 = "#657b83"
theme.base04 = "#839496"
theme.base05 = "#93a1a1"
theme.base06 = "#eee8d5"
theme.base07 = "#fdf6e3"
theme.base08 = "#dc322f"
theme.base09 = "#cb4b16"
theme.base0A = "#b58900"
theme.base0B = "#859900"
theme.base0C = "#2aa198"
theme.base0D = "#268bd2"
theme.base0E = "#6c71c4"
theme.base0F = "#d33682"

theme.leading_fg = theme.base0C

-- specific modifs for nord required colors
--theme.base10 = theme.base02
theme.base1A = theme.base0C
theme.awesome_icon_bg = theme.base09
theme.clock_fg = theme.base0C
theme.border_color_active = theme.base08
theme.bg_underline = theme.base0F
-- }}}

return theme
