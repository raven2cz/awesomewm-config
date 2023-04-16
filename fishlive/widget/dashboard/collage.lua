local fishlive = require("fishlive")
local collage = require("fishlive.collage")
local fhelpers = require("fishlive.helpers")

local imgbox = nil

return {
    show = function()
        if imgbox == nil then
            local notifpath = os.getenv("HOME").."/Pictures/wallpapers/public-wallpapers/portrait/"
            local sel_portrait = fhelpers.first_line(os.getenv("HOME")..'/.portrait') or 'joy'
            local _, imgsources = fishlive.helpers.getImgsFromDir(notifpath, sel_portrait)
            local xres = fishlive.helpers.screen_res_x()

            imgbox = collage.placeCollageImage(xres/5.48, xres/5.48,
              xres-(3840/xres)^2 * 20, xres/3840 * 60, "top-right", imgsources, 1, true)
        else
            imgbox.shadow.visible = true
            imgbox.image.visible = true
            imgbox.shadow:get_children_by_id("shadow")[1].visible = true
            imgbox.image:get_children_by_id("img")[1].visible = true
        end
    end,

    hide = function ()
        if imgbox then
            imgbox.image.visible = false
            imgbox.shadow.visible = false
            imgbox.image:get_children_by_id("img")[1].visible = false
            imgbox.shadow:get_children_by_id("shadow")[1].visible = false
        end
    end
}
