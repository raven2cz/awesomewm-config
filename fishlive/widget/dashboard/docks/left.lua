local wibox = require("wibox")

return wibox.widget {
    nil,
    require("fishlive.widget.tasklist.tasklist"),
    nil,
    expand = "none",
    layout = wibox.layout.align.vertical
}