local fishlive = require("fishlive")

local standard_wallpapers = {}
local theme
local wp_user_params
local wp_colorscheme_params

function standard_wallpapers.init_environment(dsconfig, cmpcfg)
    theme = dsconfig.theme
    -- User Wallpaper Changer
    wp_user_params = {
        wppath_user = cmpcfg.wppath_user
    }
    theme.change_wallpaper_user = fishlive.wallpaper.createUserWallpaper(wp_user_params)

    -- Colorscheme Wallpaper Changer
    wp_colorscheme_params = {
        wppath_user = cmpcfg.wppath_colorscheme
    }
    theme.change_wallpaper_colorscheme = fishlive.wallpaper.createUserWallpaper(wp_colorscheme_params)
end

-----------------------------------------------
-- WALLPAPER PER TAG and SCREEN
-----------------------------------------------
function standard_wallpapers.create(s, dsconfig, cmpcfg)
    -- Register Tag Wallpaper Changer
    fishlive.wallpaper.registerTagWallpaper({
        screen = s,
        wp_selected = cmpcfg.wp_selected,
        wp_portrait = cmpcfg.wp_portrait,
        wp_random = cmpcfg. wp_random,
        wppath = cmpcfg.wppath,
        wp_user_params = wp_user_params,
        wp_colorscheme_params = wp_colorscheme_params,
        change_wallpaper_colorscheme = theme.change_wallpaper_colorscheme
    })
end

return standard_wallpapers
