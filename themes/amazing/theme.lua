--  _ __ __ ___   _____ _ __
-- | '__/ _` \ \ / / _ \ '_  \  Antonin Fischer (raven2cz)
-- | | | (_| |\ V /  __/ | | |  https://tonda-fischer.online/
-- |_|  \__,_| \_/ \___|_| |_|  https://github.com/raven2cz
--
-- A customized theme.lua for awesomewm-git (Master) / amazing theme (https://awesomewm.org//)
----------------------------
-- Amazing Awesome Theme! --
----------------------------

local theme_name = "amazing"
local awful = require("awful")
local gfs = require("gears.filesystem")
local gears = require("gears")
local themes_path = gfs.get_themes_dir()
local rnotification = require("ruled.notification")
local dpi = require("beautiful.xresources").apply_dpi
-- Widget and layout library
local wibox = require("wibox")
-- Window Enhancements
local lain = require("lain")
-- Notification library
local naughty = require("naughty")
local menubar = require('menubar')
local xdg_menu = require("archmenu")

-- Use Polybar instead of classic Awesome Bar
local usePolybar = false
-- {{{ Main
local theme = {}
theme.dir = os.getenv("HOME") .. "/.config/awesome/themes/" .. theme_name
-- }}}

-- {{{ Styles
-- Global font
theme.font          = "Iosevka Nerd Font 9"
theme.font_larger   = "Iosevka Nerd Font 11"
theme.font_notify   = "mononoki Nerd Font 11"

-- {{{ Colors
theme.fg_normal  = "#fcfae8"
theme.fg_focus   = "#F0DFAF"
theme.fg_urgent  = "#CC9393"
theme.fg_minimize = "#ffffff"

theme.bg_normal  = "#3F3F3F"
theme.bg_focus   = "#1E2320"
theme.bg_urgent  = "#b74822"
theme.bg_systray = "#000000"
theme.bg_minimize = "#6d6d6d"

theme.notification_opacity = 0.84
theme.notification_bg = "#3F3F3F"
theme.notification_fg = "#F0DFAF"
-- }}}

-- {{{ Borders
theme.useless_gap   = dpi(5)
theme.border_width  = dpi(1)
theme.border_color_normal = "#000000"
theme.border_color_active = "#e7af61"--#535d6c"
theme.border_color_marked = "#CC9393"
-- }}}

-- {{{ Titlebars
theme.titlebar_bg_focus  = "#3F3F3F"
theme.titlebar_bg_normal = "#3F3F3F"
-- }}}

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- titlebar_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- Example:
--theme.taglist_bg_focus = "#CC9393"
-- }}}

-- {{{ Widgets
-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
theme.widgetbar_fg  = "#cacaca"
theme.fg_widget        = "#cacaca"
--theme.fg_center_widget = "#88A175"
--theme.fg_end_widget    = "#FF5656"
--theme.bg_widget        = "#494B4F"
--theme.border_widget    = "#3F3F3F"

theme.arrow1_bg = "#4d614d" --"#4f4743" --"#4d614d"
theme.arrow2_bg = "#273450"
-- }}}

-- {{{ Mouse finder
theme.mouse_finder_color = "#CC9393"
-- mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}}

-- {{{ Menu
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_height = dpi(15)
theme.menu_width  = dpi(100)
-- }}}

-- {{{ Notification Center
theme.clear_icon = theme.dir .. "/icons/clear.png"
theme.clear_grey_icon = theme.dir .. "/icons/clear_grey.png"
theme.notification_icon = theme.dir .. "/icons/notification.png"
theme.delete_icon = theme.dir .. "/icons/delete.png"
theme.delete_grey_icon = theme.dir .. "/icons/delete_grey.png"
theme.xcolor0 = "#4b5262"
theme.groups_bg  = "#3F3F3F"
theme.xbackground = "#3F3F3F"
theme.bg_normal = theme.xbackground
theme.bg_very_light = "#6d6d6d"
theme.bg_light = "#494B4F"
theme.border_radius = dpi(0)
theme.wibar_height = dpi(27)
-- }}}

-- {{{ Icons
-- {{{ Taglist
theme.taglist_squares_sel   = theme.dir .. "/taglist/squarefz.png"
theme.taglist_squares_unsel = theme.dir .. "/taglist/squarez.png"
--theme.taglist_squares_resize = "false"
-- }}}

-- {{{ Misc
theme.awesome_icon           = theme.dir .. "/awesome-icon.png"
theme.menu_submenu_icon      = themes_path .. "default/submenu.png"
-- }}}

-- {{{ Layout
theme.layout_tile        = theme.dir .. "/layouts/tile.png"
theme.layout_tileleft    = theme.dir .. "/layouts/tileleft.png"
theme.layout_tilebottom  = theme.dir .. "/layouts/tilebottom.png"
theme.layout_tiletop     = theme.dir .. "/layouts/tiletop.png"
theme.layout_fairv       = theme.dir .. "/layouts/fairv.png"
theme.layout_fairh       = theme.dir .. "/layouts/fairh.png"
theme.layout_spiral      = theme.dir .. "/layouts/spiral.png"
theme.layout_dwindle     = theme.dir .. "/layouts/dwindle.png"
theme.layout_max         = theme.dir .. "/layouts/max.png"
theme.layout_fullscreen  = theme.dir .. "/layouts/fullscreen.png"
theme.layout_magnifier   = theme.dir .. "/layouts/magnifier.png"
theme.layout_floating    = theme.dir .. "/layouts/floating.png"
theme.layout_cornernw    = theme.dir .. "/layouts/cornernw.png"
theme.layout_cornerne    = theme.dir .. "/layouts/cornerne.png"
theme.layout_cornersw    = theme.dir .. "/layouts/cornersw.png"
theme.layout_cornerse    = theme.dir .. "/layouts/cornerse.png"
theme.layout_cascade     = theme.dir .. "/layouts/cascade.png"
theme.layout_cascadetile = theme.dir .. "/layouts/cascadetile.png"
theme.layout_centerfair  = theme.dir .. "/layouts/centerfair.png"
theme.layout_centerwork  = theme.dir .. "/layouts/centerwork.png"
theme.layout_centerworkh = theme.dir .. "/layouts/centerworkh.png"
theme.layout_termfair    = theme.dir .. "/layouts/termfair.png"
theme.layout_treetile    = theme.dir .. "/layouts/treetile.png"
theme.layout_machi       = theme.dir .. "/layouts/machi.png"
-- }}}

-- {{{ Titlebar
theme.titlebar_close_button_focus  = theme.dir .. "/titlebar/close_focus.png"
theme.titlebar_close_button_normal = theme.dir .. "/titlebar/close_normal.png"

theme.titlebar_minimize_button_normal = theme.dir .. "/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus  = theme.dir .. "/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_focus_active  = theme.dir .. "/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = theme.dir .. "/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive  = theme.dir .. "/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = theme.dir .. "/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active  = theme.dir .. "/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = theme.dir .. "/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive  = theme.dir .. "/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = theme.dir .. "/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active  = theme.dir .. "/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active = theme.dir .. "/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive  = theme.dir .. "/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = theme.dir .. "/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active  = theme.dir .. "/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = theme.dir .. "/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = theme.dir .. "/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = theme.dir .. "/titlebar/maximized_normal_inactive.png"

-- Volume
theme.widget_vol      = theme.dir .. "/icons/vol.png"
theme.widget_vol_low  = theme.dir .. "/icons/vol_low.png"
theme.widget_vol_no   = theme.dir .. "/icons/vol_no.png"
theme.widget_vol_mute = theme.dir .. "/icons/vol_mute.png"

-- Iconcs
theme.widget_mem = theme.dir .. "/icons/mem.png"
theme.widget_cpu = theme.dir .. "/icons/cpu.png"
theme.widget_temp = theme.dir .. "/icons/temp.png"
theme.widget_net = theme.dir .. "/icons/net.png"
theme.widget_hdd = theme.dir .. "/icons/hdd.png"
theme.widget_keyboard = theme.dir .. "/icons/hdd.png"
-- }}}

-- Wallpaper
-- {{{ Tag Wallpaper
-- CONFIGURE IT: Set according to wallpaper directory
wppath = os.getenv("HOME") .."/OneCloud/linux/pictures/manga-wallpapers/"
wppath_user = os.getenv("HOME") .."/OneCloud/linux/pictures/wallpapers-user/"
-- Set wallpaper for each tag
local wp_selected = {
    "random",
    "lone-samurai-wallpaper.jpg",
    "wallhaven-xlmlmo.jpg",
    "wallhaven-95j8kw.jpg",
    "purple-rain.jpg",
    "wallhaven-zx5xwv.jpg",
    "wallhaven-oxlpj9.png",
    "wallhaven-g8y59e.jpg",
    "wallhaven-lqekzp.jpg",
}
-- Feature: place random wallpaper if the wp_selected has "random" text
local wp_random = {
    "anime-streets-wallpaper.jpg",
    "dragon-fire-girl.jpg",
    "wallhaven-q67my5.jpg",
    "wallhaven-r7j781.jpg",
    "6330.jpg",
    "alone-sad-girl.jpg",
    "24525.jpg",
    "41107.jpg",
    "127009.jpg",
    "127022.jpg",
    "127656.jpg",
    "381246.jpg",
    "gamer-girl.jpg",
}

-- Feature: User wallpaper folder - the wallpaper can be set for active tag by keybinding
-- The directory is defined in the configuration settings in this theme file
local wp_user = {}
-- settings for currecnt user wallpaper
local wp_user_idx = 1

-- default wallpaper
theme.wallpaper = theme.dir.."/zenburn-background.png"

-- }}}

-- {{{ Wallpaper Changer
local function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a "'..directory..'"')
    for filename in pfile:lines() do
        i = i + 1
        if i > 2 then t[i-2] = filename end
    end
    pfile:close()
    return t
end

theme.change_wallpaper_user = function(direction)
    local maxIdx = #wp_user
    wp_user_idx = wp_user_idx + direction
    if wp_user_idx < 1 then wp_user_idx = 1 end
    if wp_user_idx > maxIdx then wp_user_idx = maxIdx end

    local wp = wp_user[wp_user_idx]

    for s in screen do
      for i = 1,#s.tags do
        local tag = s.tags[i]
        if tag.selected then
            theme.wallpaper_user = wppath_user .. wp
            theme.wallpaper_user_tag = tag
            gears.wallpaper.maximized(theme.wallpaper_user, s, false)
        end
      end
    end
end
-- }}}

-- {{{ Wibar

local markup = lain.util.markup

-- Separators
local separators = lain.util.separators
local arrow = separators.arrow_left

-- Widgets params
local calendar_widget = require("awesome-wm-widgets.calendar-widget.calendar")
local weather_widget = require("awesome-wm-widgets.weather-widget.weather")
local spotify_widget = require("awesome-wm-widgets.spotify-widget.spotify")
local todo_widget = require("awesome-wm-widgets.todo-widget.todo")

-- Keyboard map indicator and switcher
local keyboardText = wibox.widget.textbox();
keyboardText:set_markup(markup.fontfg(theme.font_larger, theme.fg_minimize, " "))
theme.mykeyboardlayout = awful.widget.keyboardlayout()

-- FS ROOT
local fsicon = wibox.widget.imagebox(theme.widget_hdd)
theme.fs = lain.widget.fs({
    notification_preset = { fg = theme.fg_normal, bg = theme.bg_normal, font = theme.font_notify },
    settings = function()
        local fsp = string.format(" %3.2f %s ", fs_now["/"].free, fs_now["/"].units)
        widget:set_markup(markup.font(theme.font, fsp))
    end
})

-- MEM
local memicon = wibox.widget.imagebox(theme.widget_mem)
local mem = lain.widget.mem({
    settings = function()
        widget:set_markup(markup.fontfg(theme.font, theme.widgetbar_fg, " " .. mem_now.used .. " MB "))
    end
})

-- CPU
local cpuicon = wibox.widget.imagebox(theme.widget_cpu)
local cpu = lain.widget.cpu({
    settings = function()
        widget:set_markup(markup.fontfg(theme.font, theme.widgetbar_fg, " " .. cpu_now.usage .. " % "))
    end
})

-- CPU and GPU temps (lain, average)
local tempicon = wibox.widget.imagebox(theme.widget_temp)
local tempcpu = lain.widget.temp_ryzen({
    settings = function()
        widget:set_markup(markup.fontfg(theme.font, theme.widgetbar_fg, " cpu " .. coretemp_now .. "°C "))
    end
})
local tempgpu = lain.widget.temp_gpu({
    settings = function()
        widget:set_markup(markup.fontfg(theme.font, theme.widgetbar_fg, " gpu " .. coretemp_now .. "°C "))
    end
})

-- ALSA volume
local volicon = wibox.widget.imagebox(theme.widget_vol)
theme.volume = lain.widget.alsa({
    settings = function()
        if volume_now.status == "off" then
            volicon:set_image(theme.widget_vol_mute)
        elseif tonumber(volume_now.level) == 0 then
            volicon:set_image(theme.widget_vol_no)
        elseif tonumber(volume_now.level) <= 50 then
            volicon:set_image(theme.widget_vol_low)
        else
            volicon:set_image(theme.widget_vol)
        end

        widget:set_markup(markup.fontfg(theme.font, theme.widgetbar_fg, " " .. volume_now.level .. "% "))
    end
})
-- Net
local neticon = wibox.widget.imagebox(theme.widget_net)
local net = lain.widget.net({
    settings = function()
        widget:set_markup(markup.fontfg(theme.font, theme.widgetbar_fg, " " .. string.format("%5.1f", net_now.received) .. " ↓↑ " .. string.format("%5.1f", net_now.sent) .. " "))
    end
})

-- Weather widget
local myWeather = weather_widget({
    api_key='7df2ce22b859742524de7ab6c97a352d',
    coordinates = {49.261749, 13.903450},
    font_name = 'Carter One',
    show_hourly_forecast = true,
    show_daily_forecast = true,
})

-- Textclock widget
--local mytextclock = wibox.widget.textclock(" %a %d-%m-%Y %H:%M:%S ", 1)
local mytextclock = wibox.widget.textclock(markup.fontfg(theme.font, theme.widgetbar_fg, "%a %d-%m-%Y") .. markup.fontfg(theme.font_larger, theme.fg_focus, " %H:%M:%S "), 1)

-- Calendar widget
local cw = calendar_widget({
    theme = 'outrun',
    placement = 'top_right'
})

-- Separators
local separator = wibox.widget.textbox()

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, theme.awesome_icon },
                                    { "Applications", xdgmenu },
                                    { "open terminal", terminal }
                                  }
                        })
theme.mymainmenu = mymainmenu

mylauncher = awful.widget.launcher({ image = theme.awesome_icon,
                                     menu = mymainmenu })

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- Set Wallpapers
--[[
screen.connect_signal("request::wallpaper", function(s)
    -- Wallpaper
    local wallpaper = theme.wppath .. wp_selected[3]
    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == "function" then
        wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)
end)
--]]

-- Defaults
naughty.config.defaults.ontop = true
naughty.config.defaults.icon_size = dpi(32)
naughty.config.defaults.timeout = 10
naughty.config.defaults.title = 'System Notification'
naughty.config.defaults.margin = dpi(16)
naughty.config.defaults.border_width = 0
naughty.config.defaults.position = 'top_middle'
naughty.config.defaults.shape = function(cr, w, h)
    gears.shape.rounded_rect(cr, w, h, dpi(6))
end

-- Apply theme variables
naughty.config.padding = dpi(8)
naughty.config.spacing = dpi(8)
naughty.config.icon_dirs = {
    '/usr/share/icons/Tela',
    '/usr/share/icons/Tela-blue-dark',
    '/usr/share/icons/Papirus-Dark/',
    '/usr/share/icons/la-capitaine/'
}
naughty.config.icon_formats = { 'svg', 'png', 'jpg', 'gif' }


rnotification.connect_signal('request::rules', function()

        -- Critical notifs
        rnotification.append_rule {
            rule       = { urgency = 'critical' },
            properties = {
                font                = theme.font_notify,
                bg                  = '#ff0000',
                fg                  = '#ffffff',
                margin              = dpi(16),
                position            = 'top_middle',
                implicit_timeout    = 0
            }
        }

        -- Normal notifs
        rnotification.append_rule {
            rule       = { urgency = 'normal' },
            properties = {
                font                = theme.font_notify,
                bg                  = theme.notification_bg,
                fg                  = theme.notification_fg,
                margin              = dpi(16),
                position            = 'top_middle',
                implicit_timeout    = 10,
                icon_size           = dpi(260),
                opacity             = 0.87
            }
        }

        -- Low notifs
        rnotification.append_rule {
            rule       = { urgency = 'low' },
            properties = {
                font                = theme.font_notify,
                bg                  = theme.notification_bg,
                fg                  = theme.notification_fg,
                margin              = dpi(16),
                position            = 'top_middle',
                implicit_timeout    = 10,
                icon_size           = dpi(260),
                opacity             = 0.87
            }
        }
    end
)


-- Error handling
naughty.connect_signal('request::display_error', function(message, startup)
        naughty.notification {
            urgency = 'critical',
            title   = 'Oops, an error happened'..(startup and ' during startup!' or '!'),
            message = message,
            app_name = 'System Notification Error',
            icon = theme.awesome_icon
        }
    end
)

-- XDG icon lookup
naughty.connect_signal('request::icon', function(n, context, hints)
        if context ~= 'app_icon' then return end

        local path = menubar.utils.lookup_icon(hints.app_icon) or
        menubar.utils.lookup_icon(hints.app_icon:lower())

        if path then
            n.icon = path
        end
    end
)

-- naughty.connect_signal("request::display", function(n)
--     naughty.layout.box { notification = n }
-- end)


screen.connect_signal("request::desktop_decoration", function(s)
    -- Each screen has its own tag table.
    --awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
    names = { "/main", "/w3", "/apps", "/dev", "懲/water", "摒/air", "/fire", "/earth", "/love" }
    l = awful.layout.suit  -- Just to save some typing: use an alias.
    layouts = {
      awful.layout.layouts[1], --main
      awful.layout.layouts[2], --www (machi)
      awful.layout.layouts[2], --apps (machi)
      l.floating,              --idea
      awful.layout.layouts[11],--water (machi to empty placement)
      l.magnifier,             --air (machi)
      awful.layout.layouts[5], --fire (center-work)
      awful.layout.layouts[6], --earth (termfair)
      l.max                    --love
    }
    awful.tag(names, s, layouts)

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox {
        screen  = s,
        buttons = {
            awful.button({ }, 1, function () awful.layout.inc( 1) end),
            awful.button({ }, 3, function () awful.layout.inc(-1) end),
            awful.button({ }, 4, function () awful.layout.inc(-1) end),
            awful.button({ }, 5, function () awful.layout.inc( 1) end),
        }
    }

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = {
            awful.button({ }, 1, function(t) t:view_only() end),
            awful.button({ modkey }, 1, function(t)
                                            if client.focus then
                                                client.focus:move_to_tag(t)
                                            end
                                        end),
            awful.button({ }, 3, awful.tag.viewtoggle),
            awful.button({ modkey }, 3, function(t)
                                            if client.focus then
                                                client.focus:toggle_tag(t)
                                            end
                                        end),
            awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
            awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end),
        }
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = {
            awful.button({ }, 1, function (c)
                c:activate { context = "tasklist", action = "toggle_minimization" }
            end),
            awful.button({ }, 3, function() awful.menu.client_list { theme = { width = 250 } } end),
            awful.button({ }, 4, function() awful.client.focus.byidx(-1) end),
            awful.button({ }, 5, function() awful.client.focus.byidx( 1) end),
        }
    }

    -- bind calendar with clock widget
    mytextclock:connect_signal("button::press",
        function(_, _, _, button)
            if button == 1 then cw.toggle() end
        end
    )
    -- separator type
    separator:set_text("   ")

    -- Create the wibox
    if usePolybar then
       awful.util.spawn(os.getenv("HOME") .. "/.config/polybar/launch.sh")
       s.mywibox = awful.wibar({ position = "top", height = 35, screen = s })
    else
      -- Add widgets to the wibox
      --awful.util.spawn("killall -q polybar")
      s.mywibox = awful.wibar({ position = "top", screen = s })
      s.mywibox.widget = {
          layout = wibox.layout.align.horizontal,
          { -- Left widgets
              layout = wibox.layout.fixed.horizontal,
              mylauncher,
              separator,
              s.mytaglist,
              separator,
              s.mypromptbox,
          },
          s.mytasklist, -- Middle widget
          { -- Right widgets
              layout = wibox.layout.fixed.horizontal,
              separator,
              spotify_widget({
                  font = 'Iosevka Nerd Font 9',
                  max_length = 50,
                  play_icon = '/usr/share/icons/Papirus-Light/24x24/categories/spotify.svg',
                  pause_icon = '/usr/share/icons/Papirus-Dark/24x24/panel/spotify-indicator.svg'
              }),
              separator,
              todo_widget(),
              separator,
              wibox.widget.systray(),
              separator,
              arrow("alpha", theme.arrow2_bg),
              wibox.container.background(wibox.container.margin(wibox.widget { keyboardText, theme.mykeyboardlayout, layout = wibox.layout.align.horizontal }, 3, 6), theme.arrow2_bg),
              arrow(theme.arrow2_bg, theme.arrow1_bg),
              wibox.container.background(wibox.container.margin(wibox.widget { fsicon, theme.fs.widget, layout = wibox.layout.align.horizontal }, 2, 3), theme.arrow1_bg),
              arrow(theme.arrow1_bg, theme.arrow2_bg),
              wibox.container.background(wibox.container.margin(wibox.widget { memicon, mem.widget, layout = wibox.layout.align.horizontal }, 2, 3), theme.arrow2_bg),
              arrow(theme.arrow2_bg, theme.arrow1_bg),
              wibox.container.background(wibox.container.margin(wibox.widget { cpuicon, cpu.widget, layout = wibox.layout.align.horizontal }, 3, 4), theme.arrow1_bg),
              arrow(theme.arrow1_bg, theme.arrow2_bg),
              wibox.container.background(wibox.container.margin(wibox.widget { tempicon, tempcpu.widget, tempgpu.widget, layout = wibox.layout.align.horizontal }, 4, 4), theme.arrow2_bg),
              arrow(theme.arrow2_bg, theme.arrow1_bg),
              wibox.container.background(wibox.container.margin(myWeather, 3, 3), theme.arrow1_bg),
              arrow(theme.arrow1_bg, theme.arrow2_bg),
              wibox.container.background(wibox.container.margin(wibox.widget { volicon, theme.volume.widget, layout = wibox.layout.align.horizontal }, 3, 3), theme.arrow2_bg),
              arrow(theme.arrow2_bg, theme.arrow1_bg),
              wibox.container.background(wibox.container.margin(wibox.widget { nil, neticon, net.widget, layout = wibox.layout.align.horizontal }, 3, 3), theme.arrow1_bg),
              arrow(theme.arrow1_bg, theme.arrow2_bg),
              wibox.container.background(wibox.container.margin(mytextclock, 4, 8), theme.arrow2_bg),
              arrow(theme.arrow2_bg, "alpha"),
              --separator,
              s.mylayoutbox,
          },
      }
    end

    -- Wallpaper Settings for each Tag
    -- Set wallpaper on first tab (else it would be empty at start up)
        -- activate random seed by time
    math.randomseed(os.time());
    -- To guarantee unique random numbers on every platform, pop a few
    for i = 1,10 do
        math.random()
    end

    -- Set actual wallpeper for first tag and screen
    local wp = wp_selected[1]
    if wp == "random" then wp = wp_random[1] end
    gears.wallpaper.maximized(wppath .. wp, s, false)

    -- Try to load user wallpapers
    wp_user = scandir(wppath_user)

    -- For each screen
    for scr in screen do
      -- Go over each tab
      for t = 1,#wp_selected do
        local tag = scr.tags[t]
        tag:connect_signal("property::selected", function (tag)
          -- And if selected
          if not tag.selected then return end
          -- Set random wallpaper
          if theme.wallpaper_user_tag == tag then
              wp = theme.wallpaper_user
          elseif wp_selected[t] == "random" then
              local position = math.random(1, #wp_random)
              wp = wppath .. wp_random[position]
          else
              wp = wppath .. wp_selected[t]
          end
          --gears.wallpaper.fit(wppath .. wp_selected[t], s)
          gears.wallpaper.maximized(wp, s, false)
        end)
      end
    end
    -- }}}
end)
-- }}}

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
