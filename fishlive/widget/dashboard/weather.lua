local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local json = require("json")
local config = require("config")

local OPEN_WEATHER_URL = ("https://api.openweathermap.org/data/2.5/weather?lat="..config.weather_coordinates[1]..
           "&lon="..config.weather_coordinates[2].."&units=metric&appid="..os.getenv("WEATHER_API_KEY"))

local interval = 3600
local function fetchWeather()
    return "curl -X GET '"..OPEN_WEATHER_URL.."'"
end

local function get_icon(condition)
    local icon

    if (condition == "Thunderstorm") then
        icon = ""
    elseif (condition == "Drizzle") then
        icon = "󰖗"
    elseif (condition == "Rain") then
        icon = ""
    elseif (condition == "Snow") then
        icon = "󰖘"
    elseif (condition == "Clear") then
        local time = os.date("*t")
        if time.hour > 6 and time.hour < 18 then
            icon = "󰖙"
        else
            icon = "󰖔"
        end
    elseif (condition == "Clouds") then
        icon = ""
    else
        icon = "󰖑"
    end

    return icon
end

local temperature = wibox.widget {
    font = beautiful.font_board_monob.."14",
    widget = wibox.widget.textbox
}

local description = wibox.widget {
    font = beautiful.font_board_mono.."10",
    widget = wibox.widget.textbox
}

local icon_widget = wibox.widget {
    font = beautiful.icon_font.."48",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}

local weather_widget = wibox.widget {
    icon_widget,
    {
        nil,
        {
            temperature,
            description,
            layout = wibox.layout.fixed.vertical
        },
        expand = "none",
        layout = wibox.layout.align.vertical
    },
    spacing = dpi(16),
    layout = wibox.layout.fixed.horizontal
}


local function update_widget(widget, stdout, stderr)
    local result = json.decode(stdout)

    temperature.markup = "<span foreground='"..beautiful.fg_normal.."'>"..tostring(result.main.temp).." °C</span>"
    description.markup = "<span foreground='"..beautiful.fg_normal.."'>"..result.weather[1].description.."</span>"

    local condition = result.weather[1].main
    local icon = get_icon(condition)

    icon_widget.markup = "<span foreground='"..beautiful.fg_normal.."'>"..icon.."</span>"
end

local timer
 _, timer = awful.widget.watch(fetchWeather(), interval, update_widget, weather_widget)

return weather_widget, timer
