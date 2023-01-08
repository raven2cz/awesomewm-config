--[[

Copyright (c) 2020 mut-ex <https://github.com/mut-ex>

The following code is a derivative work of the code from the awesome-wm-nice project
(https://github.com/mut-ex/awesome-wm-nice/), which is licensed MIT. This code therefore
is also licensed under the terms of the MIT License

]]--

local gears = require("gears")
local cairo = require("lgi").cairo

-- Flips the given surface around the specified axis
local function flip(surface, axis)
    local width = surface:get_width()
    local height = surface:get_height()
    local flipped = cairo.ImageSurface.create("ARGB32", width, height)
    local cr = cairo.Context.create(flipped)
    local source_pattern = cairo.Pattern.create_for_surface(surface)
    if axis == "horizontal" then
        source_pattern.matrix = cairo.Matrix {xx = -1, yy = 1, x0 = width}
    elseif axis == "vertical" then
        source_pattern.matrix = cairo.Matrix {xx = 1, yy = -1, y0 = height}
    elseif axis == "both" then
        source_pattern.matrix = cairo.Matrix {
            xx = -1,
            yy = -1,
            x0 = width,
            y0 = height,
        }
    end
    cr.source = source_pattern
    cr:rectangle(0, 0, width, height)
    cr:paint()

    return flipped
end

local function create_corner_top_left(args)
    local radius = args.radius
    local height = args.height
    local surface = cairo.ImageSurface.create("ARGB32", radius, height)
    local cr = cairo.Context.create(surface)
    -- Create the corner shape and fill it with a gradient
    local radius_offset = 1 -- To soften the corner
    cr:move_to(0, height)
    cr:line_to(0, radius - radius_offset)
    cr:arc(
        radius + radius_offset, radius + radius_offset, radius, math.rad(180),
        math.rad(270))
    cr:line_to(radius, height)
    cr:close_path()
    cr.source = args.background_source
    cr.antialias = cairo.Antialias.BEST
    cr:fill()
    -- Next add the subtle 3D look
    local function add_stroke(nargs)
        local arc_radius = nargs.radius
        local offset_x = nargs.offset_x
        local offset_y = nargs.offset_y
        cr:new_sub_path()
        cr:move_to(offset_x, height)
        cr:line_to(offset_x, arc_radius + offset_y)
        cr:arc(
            arc_radius + offset_x, arc_radius + offset_y, arc_radius, math.rad(180),
            math.rad(270))
        cr.source = nargs.source
        cr.line_width = nargs.width
        cr.antialias = cairo.Antialias.BEST
        cr:stroke()
    end
    -- Outer dark stroke
    add_stroke {
        offset_x = args.stroke_offset_outer,
        offset_y = args.stroke_offset_outer,
        radius = radius + 0.5,
        source = args.stroke_source_outer,
        width = args.stroke_width_outer,
    }
    -- Inner light stroke
    add_stroke {
        offset_x = args.stroke_offset_inner,
        offset_y = args.stroke_offset_inner,
        radius = radius,
        width = args.stroke_width_inner,
        source = args.stroke_source_inner,
    }

    return surface
end

local function create_edge_top_middle(args)
    local client_color = args.color
    local height = args.height
    local width = args.width
    local surface = cairo.ImageSurface.create("ARGB32", width, height)
    local cr = cairo.Context.create(surface)
    -- Create the background shape and fill it with a gradient
    cr:rectangle(0, 0, width, height)
    cr.source = args.background_source
    cr:fill()
    -- Then add the light and dark strokes for that 3D look
    local function add_stroke(stroke_width, stroke_offset, stroke_color)
        cr:new_sub_path()
        cr:move_to(0, stroke_offset)
        cr:line_to(width, stroke_offset)
        cr.line_width = stroke_width
        cr:set_source_rgb(gears.color.parse_color(stroke_color))
        cr:stroke()
    end
    -- Inner light stroke
    add_stroke(
        args.stroke_width_inner, args.stroke_offset_inner,
        args.stroke_color_inner)
    -- Outer dark stroke
    add_stroke(
        args.stroke_width_outer, args.stroke_offset_outer,
        args.stroke_color_outer)

    return surface
end

local function create_edge_left(args)
    local height = args.height
    local width = 2
    -- height = height or 1080
    local surface = cairo.ImageSurface.create("ARGB32", width, height)
    local cr = cairo.Context.create(surface)
    cr:rectangle(0, 0, 2, args.height)
    cr:set_source_rgb(gears.color.parse_color(args.client_color))
    cr:fill()
    -- Inner light stroke
    cr:new_sub_path()
    cr:move_to(args.stroke_offset_inner, 0) -- 1/5
    cr:line_to(args.stroke_offset_inner, height)
    cr.line_width = args.stroke_width_inner -- 1.5
    cr:set_source_rgb(gears.color.parse_color(args.inner_stroke_color))
    cr:stroke()
    -- Outer dark stroke
    cr:new_sub_path()
    cr:move_to(args.stroke_offset_outer, 0)
    cr:line_to(args.stroke_offset_outer, height)
    cr.line_width = args.stroke_width_outer -- 1
    cr:set_source_rgb(gears.color.parse_color(args.stroke_color_outer))
    cr:stroke()

    return surface
end

local gradient = function(color_1, color_2, height, offset_1, offset_2)
    local fill_pattern = cairo.Pattern.create_linear(0, 0, 0, height)
    local r, g, b, a
    r, g, b, a = gears.color.parse_color(color_1)
    fill_pattern:add_color_stop_rgba(offset_1 or 0, r, g, b, a)
    r, g, b, a = gears.color.parse_color(color_2)
    fill_pattern:add_color_stop_rgba(offset_2 or 1, r, g, b, a)
    return fill_pattern
end

return {
    create_corner_top_left = create_corner_top_left,
    create_edge_left = create_edge_left,
    create_edge_top_middle = create_edge_top_middle,
    flip = flip,
    gradient = gradient
}