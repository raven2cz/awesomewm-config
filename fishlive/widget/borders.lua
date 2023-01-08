--[[

Copyright (c) 2020 mut-ex <https://github.com/mut-ex>

The following code is a derivative work of the code from the awesome-wm-nice project
(https://github.com/mut-ex/awesome-wm-nice/), which is licensed MIT. This code therefore
is also licensed under the terms of the MIT License

]]--

local wibox = require("wibox")
local beautiful = require("beautiful")

local shapes = require("fishlive.widget.shapes")
local get_border_colors = require("fishlive.widget.border_colors")

local apply_borders = function(widget, width, height, radius)
    local args = get_border_colors(beautiful.bg_normal)

    local top_edge = shapes.create_edge_top_middle {
        color = args.client_color,
        height = radius,
        background_source = args.background_fill_top,
        stroke_color_inner = args.stroke_color_inner_top,
        stroke_color_outer = args.stroke_color_outer_top,
        stroke_offset_inner = 1.25,
        stroke_offset_outer = 0.5,
        stroke_width_inner = 1,
        stroke_width_outer = 1,
        width = width,
    }

    local corner_top_left_img = shapes.create_corner_top_left {
        background_source = args.background_fill_top,
        color = args.client_color,
        height = radius,
        radius = radius,
        stroke_offset_inner = 1.5,
        stroke_width_inner = 1,
        stroke_offset_outer = 0.5,
        stroke_width_outer = 1,
        stroke_source_inner = shapes.gradient(
            args.stroke_color_inner_top, args.stroke_color_inner_sides, radius),
        stroke_source_outer = shapes.gradient(
            args.stroke_color_outer_top, args.stroke_color_outer_sides, radius),
    }
    -- The top right corner of the titlebar
    local corner_top_right_img = shapes.flip(corner_top_left_img, "horizontal")

    local corner_bottom_left_img = shapes.flip(
        shapes.create_corner_top_left {
            color = args.client_color,
            radius = radius,
            height = radius,
            background_source = args.background_fill_top,
            stroke_offset_inner = 1.5,
            stroke_offset_outer = 0.5,
            stroke_source_outer = shapes.gradient(
                args.stroke_color_outer_bottom, args.stroke_color_outer_sides,
                radius, 0, 0.25),
            stroke_source_inner = shapes.gradient(
                args.stroke_color_inner_bottom, args.stroke_color_inner_sides,
                radius),
            stroke_width_inner = 1,
            stroke_width_outer = 1,
        }, "vertical")

    local corner_bottom_right_img = shapes.flip(corner_bottom_left_img, "horizontal")

    local bottom_edge = shapes.flip(shapes.create_edge_top_middle {
            color = args.client_color,
            height = radius,
            background_source = args.background_fill_top,
            stroke_color_inner = args.stroke_color_inner_bottom,
            stroke_color_outer = args.stroke_color_outer_bottom,
            stroke_offset_inner = 1.25,
            stroke_offset_outer = 0.5,
            stroke_width_inner = 1,
            stroke_width_outer = 1,
            width = width,
        }, "vertical")

    local left_border_img = shapes.create_edge_left {
        client_color = args.client_color,
        width = width,
        height = height,
        stroke_offset_outer = 0.5,
        stroke_width_outer = 1,
        stroke_color_outer = args.stroke_color_outer_sides,
        stroke_offset_inner = 1.5,
        stroke_width_inner = 1.5,
        inner_stroke_color = args.stroke_color_inner_sides,
    }

    local right_border_img = shapes.flip(left_border_img, "horizontal")

    collectgarbage("collect")

    return wibox.widget {
        {
            wibox.widget.imagebox(corner_top_left_img, false),
            wibox.widget.imagebox(top_edge, false),
            wibox.widget.imagebox(corner_top_right_img, false),
            layout = wibox.layout.align.horizontal,
        },
        {
            wibox.widget.imagebox(left_border_img, false),
            widget,
            wibox.widget.imagebox(right_border_img, false),
            layout = wibox.layout.align.horizontal
        },
        {
            wibox.widget.imagebox(corner_bottom_left_img, false),
            wibox.widget.imagebox(bottom_edge, false),
            wibox.widget.imagebox(corner_bottom_right_img, false),
            layout = wibox.layout.align.horizontal,
        },
        layout = wibox.layout.align.vertical
    }
end

return apply_borders