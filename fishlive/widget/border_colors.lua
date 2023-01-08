--[[

Copyright (c) 2020 mut-ex <https://github.com/mut-ex>

The following code is a derivative work of the code from the awesome-wm-nice project
(https://github.com/mut-ex/awesome-wm-nice/), which is licensed MIT. This code therefore
is also licensed under the terms of the MIT License

]]--

local gears = require("gears")
local cairo = require("lgi").cairo

local stroke_inner_bottom_lighten_mul = 0.4
local stroke_inner_sides_lighten_mul = 0.4
local stroke_outer_top_darken_mul = 0.7

local gradient = function(color_1, color_2, height, offset_1, offset_2)
    local fill_pattern = cairo.Pattern.create_linear(0, 0, 0, height)
    local r, g, b, a
    r, g, b, a = gears.color.parse_color(color_1)
    fill_pattern:add_color_stop_rgba(offset_1 or 0, r, g, b, a)
    r, g, b, a = gears.color.parse_color(color_2)
    fill_pattern:add_color_stop_rgba(offset_2 or 1, r, g, b, a)
    return fill_pattern
end

-- Calculates the relative luminance of the given color
local function relative_luminance(color)
    local r, g, b = gears.color.parse_color(color)
    local function from_sRGB(u)
        return u <= 0.0031308 and 25 * u / 323 or
                   math.pow(((200 * u + 11) / 211), 12 / 5)
    end
    return 0.2126 * from_sRGB(r) + 0.7152 * from_sRGB(g) + 0.0722 * from_sRGB(b)
end

local function rel_lighten(lum) return lum * 90 + 10 end
local function rel_darken(lum) return -(lum * 70) + 100 end

-- Lightens a given hex color by the specified amount
local function color_lighten(color, amount)
    local r, g, b
    r, g, b = gears.color.parse_color(color)
    r = 255 * r
    g = 255 * g
    b = 255 * b
    r = r + math.floor(2.55 * amount)
    g = g + math.floor(2.55 * amount)
    b = b + math.floor(2.55 * amount)
    r = r > 255 and 255 or r
    g = g > 255 and 255 or g
    b = b > 255 and 255 or b
    return ("#%02x%02x%02x"):format(r, g, b)
end

-- Darkens a given hex color by the specified amount
local function color_darken(color, amount)
    local r, g, b
    r, g, b = gears.color.parse_color(color)
    r = 255 * r
    g = 255 * g
    b = 255 * b
    r = math.max(0, r - math.floor(r * (amount / 100)))
    g = math.max(0, g - math.floor(g * (amount / 100)))
    b = math.max(0, b - math.floor(b * (amount / 100)))
    return ("#%02x%02x%02x"):format(r, g, b)
end

local get_colors = function(client_color)
    -- Closures to avoid repitition
    local lighten = function(amount)
        return color_lighten(client_color, amount)
    end

    local darken = function(amount)
        return color_darken(client_color, amount)
    end

    local luminance = relative_luminance(client_color)
    local lighten_amount = rel_lighten(luminance)
    local darken_amount = rel_darken(luminance)

    return {
        client_color = client_color,
        -- Inner strokes
        stroke_color_inner_top = lighten(lighten_amount),
        stroke_color_inner_sides = lighten(lighten_amount * stroke_inner_sides_lighten_mul),
        stroke_color_inner_bottom = lighten(lighten_amount * stroke_inner_bottom_lighten_mul),
        -- Outer strokes
        stroke_color_outer_top = darken(darken_amount * stroke_outer_top_darken_mul),
        stroke_color_outer_sides = darken(darken_amount),
        stroke_color_outer_bottom = darken(darken_amount),

        background_fill_top = gradient(client_color, client_color, titlebar_height, 0, 0.5)
    }
end

return get_colors