local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local apply_borders = require("fishlive.widget.borders")

return function(width, height)
    local image = wibox.widget {
        image = beautiful.nocover_icon,
        forced_width = dpi(150),
        forced_height = dpi(150),
        widget = wibox.widget.imagebox
    }

    local artist = wibox.widget {
        markup = "Not playing",
        font = beautiful.font_board_bold.."12",
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox
    }

    local title = wibox.widget {
        font = beautiful.font_board_reg.."10",
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox
    }

    local previous = wibox.widget {
        font = beautiful.icon_font.."20",
        markup = "󰒮",
        widget = wibox.widget.textbox
    }

    local play_pause = wibox.widget {
        font = beautiful.icon_font.."20",
        markup = "",
        widget = wibox.widget.textbox
    }

    local next = wibox.widget {
        font = beautiful.icon_font.."20",
        markup = "󰒭",
        widget = wibox.widget.textbox
    }

    previous:connect_signal("button::press", function()
        awesome.emit_signal("signal::playerctl::previous")
    end)

    play_pause:connect_signal("button::press", function()
        awesome.emit_signal("signal::playerctl::play_pause")
    end)

    next:connect_signal("button::press", function()
        awesome.emit_signal("signal::playerctl::next")
    end)

    awesome.connect_signal("signal::playerctl::play_pause_result", function(status)
        if status:lower() == "playing" then
            play_pause.markup = "󰏤"
        else
            play_pause.markup = "󰐊"
        end
    end)

    awesome.connect_signal("signal::playerctl", function(data)
        artist.markup = string.sub(data.artist, 0, 28)
        title.markup = string.sub(data.title, 0, 28)

        if data.artist == "" and data.title == "" then
            artist.markup = "Not playing"
        end

        if data.image ~= "" then
            image:set_image(gears.surface.load_uncached(data.image))
        else
            image:set_image(beautiful.nocover_icon)
        end
    end)

    local playerctl_widget = wibox.widget {
        {
            {
                nil,
                image,
                nil,
                expand = "none",
                layout = wibox.layout.align.horizontal
            },
            {
                nil,
                {
                    artist,
                    title,
                    layout = wibox.layout.fixed.vertical
                },
                nil,
                expand = "none",
                forced_width = dpi(168),
                forced_height = dpi(60),
                layout = wibox.layout.align.vertical
            },
            {
                nil,
                {
                    previous,
                    play_pause,
                    next,
                    spacing = dpi(20),
                    layout = wibox.layout.fixed.horizontal
                },
                nil,
                expand = "none",
                forced_height = dpi(18),
                layout = wibox.layout.align.horizontal
            },
            spacing = dpi(2),
            layout = wibox.layout.fixed.vertical
        },
        top = dpi(16),
        bottom = dpi(4),
        widget = wibox.container.margin
    }

    return wibox.widget {
        apply_borders({
            playerctl_widget,
            bg = beautiful.bg_normal,
            widget = wibox.container.background
        }, width, height, 8),
        margins = dpi(8),
        widget = wibox.container.margin
    }
end
