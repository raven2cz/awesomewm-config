--  _ __ __ ___   _____ _ __
-- | '__/ _` \ \ / / _ \ '_  \  Antonin Fischer (raven2cz)
-- | | | (_| |\ V /  __/ | | |  https://fishlive.org/
-- |_|  \__,_| \_/ \___|_| |_|  https://github.com/raven2cz
--
-- A customized theme.lua for awesomewm-git (Master) / OneDark Eighties Theme (https://github.com/raven2cz)
------------------------
-- OneDark 80s Theme  --
------------------------

local theme_name = "one-dark-80s"
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
-- Fishlive Utilities
local fishlive = require("fishlive")
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

-- activate random seed by time
math.randomseed(os.time());
-- To guarantee unique random numbers on every platform, pop a few
for i = 1,10 do
  math.random()
end

-- {{{ Styles
-- Global font
theme.font          = "Iosevka Nerd Font 9"
theme.font_larger   = "Iosevka Nerd Font 11"
theme.font_notify   = "mononoki Nerd Font 11"

-- {{{ Colors
--base16-eighties-one-dark color palatte
theme.base00 = "#2d2d2d"
theme.base01 = "#393939"
theme.base02 = "#515151"
theme.base03 = "#747369"
theme.base04 = "#a09f93"
theme.base05 = "#d3d0c8"
theme.base06 = "#e8e6df"
theme.base07 = "#f2f0ec"
theme.base08 = "#f2777a"
theme.base09 = "#f99157"
theme.base0A = "#ffcc66"
theme.base0B = "#99cc99"
theme.base0C = "#66cccc"
theme.base0D = "#6699cc"
theme.base0E = "#cc99cc"
theme.base0F = "#d27b53"

--one-dark-extended color palette
theme.base10 = "#2C2C2C"
theme.base18 = "#b74822"
theme.base1A = "#F0DFAF"

-- random shuffle foreground colors, 8 colors
theme.baseColors = {
  theme.base08,
  theme.base09,
  theme.base0A,
  theme.base0E,
  theme.base0C,
  theme.base0D,
  theme.base0B,
  theme.base18,
  theme.base1A,
}
fishlive.util.shuffle(theme.baseColors)

theme.fg_normal  = theme.base06
theme.fg_focus   = theme.base1A
theme.fg_urgent  = theme.base0E
theme.fg_minimize = theme.base07

theme.bg_normal  = theme.base10
theme.bg_focus   = theme.base00
theme.bg_urgent  = theme.base18
theme.bg_systray = theme.base10
theme.bg_minimize = theme.base03
theme.bg_underline = theme.base0C

theme.notification_opacity = 0.84
theme.notification_bg = theme.bg_normal
theme.notification_fg = theme.fg_focus
-- }}}

-- {{{ Borders
theme.useless_gap   = dpi(5)
theme.border_width  = dpi(1)
theme.border_color_normal = theme.base10
theme.border_color_active = theme.base0A
theme.border_color_marked = theme.base0E
-- }}}

-- {{{ Titlebars
theme.titlebar_bg_focus  = theme.base02
theme.titlebar_bg_normal = theme.base02
-- }}}

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- titlebar_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- }}}

-- {{{ Widgets
-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
theme.widgetbar_fg  = theme.base05
theme.fg_widget     = theme.base05
--theme.fg_center_widget = "#88A175"
--theme.fg_end_widget    = "#FF5656"
--theme.bg_widget        = "#494B4F"
--theme.border_widget    = "#3F3F3F"
-- }}}

-- {{{ Mouse finder
theme.mouse_finder_color = theme.base0E
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
theme.xcolor0 = theme.base02
theme.groups_bg  = theme.base01
theme.xbackground = theme.base01
theme.bg_very_light = theme.base03
theme.bg_light = theme.base02
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

-- }}}
---------------------
-- Wallpaper Support
---------------------
-- {{{ Tag Wallpaper
-- CONFIGURE IT: Set according to cloud wallpaper directory
wppath = os.getenv("HOME") .."/Pictures/wallpapers/public-wallpapers/"
wppath_user = os.getenv("HOME") .."/Pictures/wallpapers/user-wallpapers/"
notifpath_user = os.getenv("HOME") .."/Pictures/wallpapers/public-wallpapers/portrait/default/"
-- Set wallpaper for each tag
local wp_selected = {
  "random",
  "00022-alone-samurai.jpg",
  "00002-GUWEIZ-samurai-girl.jpg",
  "00019-wallhaven-95j8kw.jpg",
  "00009-purple-rain-l8.jpg",
  "00015-wallhaven-zx5xwv.jpg",
  "00033-GUWEIZ-1120523.jpg",
  "00008-manga-life3.jpg",
  "00027-lovers.jpg",
}
-- Feature: place random wallpaper if the wp_selected has "random" text
local wp_random = {
  "00024-anime-street-at-night.jpg",
  "00012-wallhaven-ymz61d.jpg",
  "00016-wallhaven-r28dm7.jpg",
  "00010-girl-getting-out-of-train.jpg",
  "00013-island.jpg",
  "00014-lake-house.jpg",
  "00029-fantasy-town.jpg",
  "00025-anime-girl-looking-away.jpg",
  "00028-clock-room.jpg.jpg",
}

-- Feature: User wallpaper folder - the wallpaper can be set for active tag by keybinding
-- The directory is defined in the configuration settings in this theme file
local wp_user = {}
-- settings for currecnt user wallpaper
local wp_user_idx = 0

-- Feature: Notification icon folder - support change notification icons randomly
local notif_user = {}
-- }}}

-- {{{ Wallpaper Changer
theme.change_wallpaper_user = function(direction)
  local maxIdx = #wp_user
  wp_user_idx = wp_user_idx + direction
  if wp_user_idx < 1 then wp_user_idx = maxIdx end
  if wp_user_idx > maxIdx then wp_user_idx = 1 end

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

theme.change_wallpaper_per_tag = function()
  -- For each screen
  for scr in screen do
    -- Go over each tab
    for t = 1,#wp_selected do
      local tag = scr.tags[t]
      tag:connect_signal("property::selected", function (tag)
        -- And if selected
        if not tag.selected then return end
        -- Set the color of tag
        --theme.taglist_fg_focus = theme.baseColors[tag.index]
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
end
-- }}}

-- {{{ Wibar

local markup = lain.util.markup

-- Separators
local separators = lain.util.separators

--------------------------
-- Widgets Declarations
--------------------------
local calendar_widget = require("awesome-wm-widgets.calendar-widget.calendar")
local weather_widget = require("awesome-wm-widgets.weather-widget.weather")
local spotify_widget = require("awesome-wm-widgets.spotify-widget.spotify")
local todo_widget = require("awesome-wm-widgets.todo-widget.todo")

-- fix params for wibox boxes
local wiboxMargin = 7
local underLineSize = 1.5
local wiboxBox0 = fishlive.widget.wiboxBox0Underline
local wiboxBox1 = fishlive.widget.wiboxBoxIconUnderline
local wiboxBox2 = fishlive.widget.wiboxBox2IconUnderline

-- Keyboard map indicator and switcher
local wboxColor = theme.baseColors[1]
local keyboardText = wibox.widget.textbox();
keyboardText:set_markup(markup.fontfg(theme.font_larger, wboxColor, " "))
theme.mykeyboardlayout = awful.widget.keyboardlayout()
local keyboardWibox = wiboxBox1(keyboardText, theme.mykeyboardlayout, wboxColor, 3, 6, underLineSize, wiboxMargin)

-- FS ROOT
wboxColor = theme.baseColors[2]
local fsicon = wibox.widget.textbox();
fsicon:set_markup(markup.fontfg(theme.font_larger, wboxColor, ""))
theme.fs = lain.widget.fs({
  notification_preset = { fg = theme.fg_normal, bg = theme.bg_normal, font = theme.font_notify },
  settings = function()
    local fsp = string.format(" %3.2f %s ", fs_now["/"].free, fs_now["/"].units)
    widget:set_markup(markup.font(theme.font, fsp))
  end
})
local fsWibox = wiboxBox1(fsicon, theme.fs.widget, wboxColor, 2, 3, underLineSize, wiboxMargin)

-- MEM
wboxColor = theme.baseColors[3]
local memicon = wibox.widget.textbox();
memicon:set_markup(markup.fontfg(theme.font_larger, wboxColor, ""))
local mem = lain.widget.mem({
  settings = function()
    widget:set_markup(markup.fontfg(theme.font, theme.widgetbar_fg, " " .. mem_now.used .. " MB "))
  end
})
local memWibox = wiboxBox1(memicon, mem.widget, wboxColor, 2, 3, underLineSize, wiboxMargin)

-- CPU
wboxColor = theme.baseColors[4]
local cpuicon = wibox.widget.textbox();
cpuicon:set_markup(markup.fontfg(theme.font_larger, wboxColor, ""))
local cpu = lain.widget.cpu({
  settings = function()
    widget:set_markup(markup.fontfg(theme.font, theme.widgetbar_fg, " " .. cpu_now.usage .. " % "))
  end
})
local cpuWibox = wiboxBox1(cpuicon, cpu.widget, wboxColor, 3, 4, underLineSize, wiboxMargin)

-- CPU and GPU temps (lain, average)
wboxColor = theme.baseColors[5]
local tempicon = wibox.widget.textbox();
tempicon:set_markup(markup.fontfg(theme.font_larger, wboxColor, ""))
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
local tempWibox = wiboxBox2(tempicon, tempcpu.widget, tempgpu.widget, wboxColor, 4, 4, underLineSize, wiboxMargin)

-- Weather widget
wboxColor = theme.baseColors[6]
local tempicon = wibox.widget.textbox();
tempicon:set_markup(markup.fontfg(theme.font_larger, wboxColor, ""))
local myWeather = weather_widget({
  api_key='7df2ce22b859742524de7ab6c97a352d', --fill your API KEY
  coordinates = { 49.261749, 13.903450 }, -- fill your coords
  font_name = 'Carter One',
  show_hourly_forecast = true,
  show_daily_forecast = true,
})
local weatherWibox = wiboxBox0(myWeather, wboxColor, 3, 3, underLineSize, wiboxMargin)

-- ALSA volume
local alsaColor = theme.baseColors[7]
local volicon = wibox.widget.textbox();
theme.volume = lain.widget.alsa({
  settings = function()
    if volume_now.status == "off" then
      volicon:set_markup(markup.fontfg(theme.font_larger, alsaColor, "ﱝ"))
    elseif tonumber(volume_now.level) == 0 then
      volicon:set_markup(markup.fontfg(theme.font_larger, alsaColor, ""))
    elseif tonumber(volume_now.level) <= 25 then
      volicon:set_markup(markup.fontfg(theme.font_larger, alsaColor, ""))
    elseif tonumber(volume_now.level) <= 70 then
      volicon:set_markup(markup.fontfg(theme.font_larger, alsaColor, "墳"))
    else
      volicon:set_markup(markup.fontfg(theme.font_larger, alsaColor, ""))
    end
    widget:set_markup(markup.fontfg(theme.font, theme.widgetbar_fg, " " .. volume_now.level .. "% "))
  end
})
local alsaWibox = wiboxBox1(volicon, theme.volume.widget, alsaColor, 3, 3, underLineSize, wiboxMargin)

-- Net
wboxColor = theme.baseColors[8]
local neticon = wibox.widget.textbox();
neticon:set_markup(markup.fontfg(theme.font_larger, wboxColor, ""))
local net = lain.widget.net({
  settings = function()
    widget:set_markup(markup.fontfg(theme.font, theme.widgetbar_fg, string.format("%#7.1f", net_now.sent) .. " ﰵ " .. string.format("%#7.1f", net_now.received) .. " ﰬ "))
  end
})
local netWibox = wiboxBox1(neticon, net.widget, wboxColor, 3, 3, underLineSize, wiboxMargin)

-- Textclock widget
wboxColor = theme.baseColors[9]
local clockicon = wibox.widget.textbox();
clockicon:set_markup(markup.fontfg(theme.font_larger, wboxColor, ""))
local mytextclock = wibox.widget.textclock(markup.fontfg(theme.font, theme.widgetbar_fg, " %a %d-%m-%Y") .. markup.fontfg(theme.font_larger, theme.base0A, " %H:%M:%S "), 1)
local clockWibox = wiboxBox1(clockicon, mytextclock, wboxColor, 0, 0, underLineSize, wiboxMargin)

-- Calendar widget
local cw = calendar_widget({
  theme = 'outrun',
  placement = 'top_right'
})

-- Spotify widge
local spotifyWibox = spotify_widget({
  font = theme.font,
  max_length = 500,
  play_icon = '/usr/share/icons/Papirus-Light/24x24/categories/spotify.svg',
  pause_icon = '/usr/share/icons/Papirus-Dark/24x24/panel/spotify-indicator.svg'
})

-- Separators
local separator = wibox.widget.textbox()

-- {{{ Menu - Press Button Awesome
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

mylauncher = awful.widget.launcher({ image = theme.awesome_icon, menu = mymainmenu })

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

-------------------------------------
-- DESKTOP and PANELS CONFIGURATION
-------------------------------------
screen.connect_signal("request::desktop_decoration", function(s)
  local tags = {
    icons = {
      "", "", "", "", "懲", "摒", "", "", ""
    },
    names = { "/main", "/w3", "/apps", "/dev", "/water", "/air", "/fire", "/earth", "/love" },
    layouts = {
      awful.layout.layouts[13], --main
      awful.layout.layouts[2], --www (machi)
      awful.layout.layouts[2], --apps (machi)
      awful.layout.suit.floating, --idea
      awful.layout.layouts[11],--water (machi to empty placement)
      awful.layout.suit.magnifier, --air (machi)
      awful.layout.layouts[5], --fire (center-work)
      awful.layout.layouts[6], --earth (termfair)
      awful.layout.suit.max    --love
    }
  }

  -- Each screen has its own tag table.
  for s = 1, screen.count() do
    tags[s] = awful.tag(tags.names, s, tags.layouts)
    -- Set additional optional parameters for each tag
    --tags[s][1].column_count = 2
  end

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

  -- TAGLIST COMPONENT
  -- Taglist Callbacks
  local update_tag = function(self, c3, index, objects)
      local focused = false
      for _, x in pairs(awful.screen.focused().selected_tags) do
          if x.index == index then
              focused = true
              break
          end
      end
      local color
      if focused then
          color = theme.bg_underline
      else
          color = theme.bg_normal
      end
      local tagBox = self:get_children_by_id("overline")[1]
      local iconBox = self:get_children_by_id("icon_text_role")[1]
      iconBox:set_markup(markup.fontfg(theme.font_larger, theme.baseColors[index], tags.icons[index]))
      tagBox.bg = color
  end

  -- Create a taglist widget
  s.mytaglist = awful.widget.taglist {
    screen  = s,
    filter  = awful.widget.taglist.filter.all,
    buttons = {
      awful.button({}, 1, function(t) t:view_only() end),
      awful.button({ modkey }, 1, function(t)
        if client.focus then
          client.focus:move_to_tag(t)
        end
      end),
      awful.button({}, 3, awful.tag.viewtoggle),
      awful.button({ modkey }, 3, function(t)
        if client.focus then
          client.focus:toggle_tag(t)
        end
      end),
      awful.button({}, 4, function(t) awful.tag.viewprev(t.screen) end),
      awful.button({}, 5, function(t) awful.tag.viewnext(t.screen) end),
    },
    widget_template = {
        {
            {
               layout = wibox.layout.fixed.vertical,
               {
                    layout = wibox.layout.fixed.horizontal,
                    {
                         {
                             id = 'icon_text_role',
                             widget = wibox.widget.textbox
                         },
                         left = 7,
                         right = 0,
                         top = 0,
                         widget = wibox.container.margin
                    },
                    {
                        {
                            id = 'text_role',
                            widget = wibox.widget.textbox
                        },
                        top = 0,
                        right = 7,
                        widget = wibox.container.margin
                    }
                },
                {
                    {
                        bottom = 2,
                        widget = wibox.container.margin
                    },
                    id = 'overline',
                    bg = theme.bg_normal,
                    shape = gears.shape.rectangle,
                    widget = wibox.container.background
                }
            },
            widget = wibox.container.margin
        },
        id = 'background_role',
        widget = wibox.container.background,
        shape = gears.shape.rectangle,
        create_callback = update_tag,
        update_callback = update_tag
    },
  }

  -- TASKLIST
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

  -- MAIN PANEL CONFIGURATION
  -- Create the wibox
  if usePolybar then
    -- Polybar support
    awful.util.spawn(os.getenv("HOME") .. "/.config/polybar/launch.sh")
    s.mywibox = awful.wibar({ position = "top", height = 35, screen = s })
  else
    -- Add widgets to the wibox
    --awful.util.spawn("killall -q polybar")
    s.mywibox = awful.wibar({ position = "top", bg = theme.bg_normal, screen = s })
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
        spotifyWibox,
        separator,
        todo_widget(),
        separator,
        wibox.widget.systray(),
        separator,
        keyboardWibox,
        fsWibox,
        memWibox,
        cpuWibox,
        tempWibox,
        alsaWibox,
        netWibox,
        weatherWibox,
        clockWibox,
        s.mylayoutbox,
      },
    }
  end

  --------------------------
  -- NAUGHTY CONFIGURATION
  --------------------------
  naughty.config.defaults.ontop = true
  naughty.config.defaults.icon_size = dpi(32)
  naughty.config.defaults.timeout = 10
  naughty.config.defaults.title = 'System Notification Title'
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
    '/usr/share/icons/Papirus-Dark/',
    '/usr/share/icons/Tela',
    '/usr/share/icons/Tela-blue-dark',
    '/usr/share/icons/la-capitaine/'
  }
  naughty.config.icon_formats = { 'svg', 'png', 'jpg', 'gif' }

  rnotification.connect_signal('request::rules', function()
      -- Critical notifs
      rnotification.append_rule {
        rule       = { urgency = 'critical' },
        properties = {
          font                = theme.font_notify,
          bg                  = theme.bg_urgent,
          fg                  = theme.fg_normal,
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
      app_name = 'System Notification',
      icon = theme.awesome_icon
    }
  end
  )
  -- naughty.connect_signal("request::display", function(n)
  --     naughty.layout.box { notification = n }
  -- end
  -- )

  -- XDG icon lookup
  naughty.connect_signal('request::icon', function(n, context, hints)
    if context ~= 'app_icon' then
      -- try use random notification portrait from resources
      if #notif_user >= 1 then
        n.icon = notifpath_user .. notif_user[math.random(#notif_user)]
      end
      return
    end
    -- try use application icon

    local path = menubar.utils.lookup_icon(hints.app_icon) or
      menubar.utils.lookup_icon(hints.app_icon:lower())

    if path then
      n.icon = path
    end
  end
  )


  -----------------------------------------------
  -- WALLPAPER PER TAG and USER WALLS keybinding
  -----------------------------------------------
  -- Set actual wallpaper for first tag and screen
  local wp = wp_selected[1]
  if wp == "random" then wp = wp_random[1] end
  gears.wallpaper.maximized(wppath .. wp, s, false)

  -- Try to load user wallpapers
  wp_user = fishlive.util.scandir(wppath_user)
  -- Try to load notification icons
  notif_user = fishlive.util.scandir(notifpath_user)

  -- Change wallpaper per tag
  theme.change_wallpaper_per_tag()
  -- }}}
end)
-- }}}

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
