-- base16-doom-one
-- color palatte definition
local theme = {}

-- {{{ Colors
theme.scheme = "Doom One"
theme.scheme_id = "doom_one"
theme.scheme_author = "Henrik Lissner (https://github.com/hlissner)"
theme.scheme_type = "dark"
theme.base00 = "#282c34" --# ----
theme.base01 = "#1c1f24" --# ---
theme.base02 = "#23272e" --# --
theme.base03 = "#3f444a" --# -
theme.base04 = "#73797e" --# +
theme.base05 = "#9ca0a4" --# ++
theme.base06 = "#bbc2cf" --# +++
theme.base07 = "#E6E6E6" --# ++++
theme.base08 = "#ff6c6b" --# red
theme.base09 = "#da8548" --# orange
theme.base0A = "#ECBE7B" --# yellow
theme.base0B = "#98be65" --# green
theme.base0C = "#46D9FF" --# cyan
theme.base0D = "#51afef" --# blue
theme.base0E = "#c678dd" --# purple
theme.base0F = "#5699AF" --# brown

theme.leading_fg = theme.base0B

theme.border_color_active = theme.base0B
theme.widgetbar_fg = theme.base06
theme.bg_focus = theme.base03
theme.bg_minimize = theme.base04
-- }}}

return theme
