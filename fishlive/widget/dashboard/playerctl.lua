local wibox = require("wibox")
local gears = require("gears")
local lgi = require("lgi")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local apply_borders = require("fishlive.widget.borders")

local image = wibox.widget {
    image = beautiful.nocover_icon,
    forced_width = dpi(150),
    forced_height = dpi(150),
    widget = wibox.widget.imagebox
}

local artist = wibox.widget {
    markup = "Not playing",
    font = "Roboto Black 12",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}

local title = wibox.widget {
    font = "Roboto Regular 10",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}

local previous = wibox.widget {
    font = "FiraMono Nerd Font 18",
    markup = "玲",
    widget = wibox.widget.textbox
}

local play_pause = wibox.widget {
    font = "FiraMono Nerd Font 18",
    markup = "契",
    widget = wibox.widget.textbox
}

local next = wibox.widget {
    font = "FiraMono Nerd Font 18",
    markup = "怜",
    widget = wibox.widget.textbox
}

previous:connect_signal("button::press", function()
    awesome.emit_signal("evil::playerctl::previous")
end)

play_pause:connect_signal("button::press", function()
    awesome.emit_signal("evil::playerctl::play_pause")
end)

next:connect_signal("button::press", function()
    awesome.emit_signal("evil::playerctl::next")
end)

awesome.connect_signal("evil::playerctl", function(data)
    --container.visible = data~=false

    artist.markup = data.artist
    title.markup = data.title

    if data.artist == "" and data.title == "" then
        artist.markup = "Not playing"
    end

    if data.status:lower() == "playing" then
        play_pause.markup = ""
    else
        play_pause.markup = "契"
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
        spacing = dpi(8),
        layout = wibox.layout.fixed.vertical
    },
    top = dpi(4),
    bottom = dpi(4),
    widget = wibox.container.margin
}

return wibox.widget {
    apply_borders({
        playerctl_widget,
        bg = beautiful.bg_normal,
        widget = wibox.container.background
    }, dpi(184), dpi(270), 8),
    margins = dpi(8),
    widget = wibox.container.margin
}