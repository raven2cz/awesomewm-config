local collage = require("fishlive.collage")
local fhelpers = require("fishlive.helpers")

local standard_collage = {}
local collage_configs

function standard_collage.init_environment(dsconfig)
    local theme = dsconfig.theme
    -- Collage Configuration Standard Layouts
    collage_configs = {
        -- TAG 4
        {
            wppath = theme.wppath_sel_portrait,
            wps = theme.portraits,
            tagids = { 4 },
            collage_template = dsconfig.isFullhd and {
                { max_height = 450, posx = 10, posy = 40 },
                { max_height = 450, posx = 10, posy = 500 },
            } or {
                { max_height = 600, posx = 100, posy = 100 },
                { max_height = 600, posx = 100, posy = 800 },
                {
                    max_width = 600,
                    posx = 100,
                    posy = 100,
                    align = "bottom-right",
                },
            },
        },
        -- TAG 9
        {
            wppath = theme.wppath_sel_portrait,
            wps = theme.portraits,
            tagids = { 9 },
            collage_template = {
                { max_height = 800, posx = 100,  posy = 100 },
                { max_height = 400, posx = 100,  posy = 930 },
                { max_height = 400, posx = 450,  posy = 930 },
                { max_height = 400, posx = 870,  posy = 100 },
                { max_height = 400, posx = 1220, posy = 100 },
                { max_height = 800, posx = 870,  posy = 530 },
                { max_height = 760, posx = 100,  posy = 1370 },
                { max_height = 400, posx = 870,  posy = 1370 },
                { max_height = 400, posx = 1220, posy = 1370 },
            },
        },
    }
end

local function collageTag(cmpcfg)
    local imgsources = {}
    for i = 1, #cmpcfg.wps do
        imgsources[i] = cmpcfg.wppath .. cmpcfg.wps[i]
    end
    fhelpers.shuffle(imgsources)

    local collage_template = {}
    for _, item in ipairs(cmpcfg.collage_template) do
        local new_item = {}
        for k, v in pairs(item) do
            new_item[k] = v
        end
        table.insert(collage_template, new_item)
    end

    collage.registerTagCollage({
        collage_template = collage_template,
        imgsources = imgsources,
        tagids = cmpcfg.tagids,
    })
end

---------------------
-- COLLAGE PER TAG
---------------------
function standard_collage.create()
    for _, config in ipairs(collage_configs) do
        collageTag(config)
    end
end

return standard_collage
