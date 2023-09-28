--  _ __ __ ___   _____ _ __
-- | '__/ _` \ \ / / _ \ '_  \  Antonin Fischer (raven2cz)
-- | | | (_| |\ V /  __/ | | |  https://tonda-fischer.online/
-- |_|  \__,_| \_/ \___|_| |_|  https://github.com/raven2cz
--
-- A customized rc.lua for awesomewm-git (master branch) (https://awesomewm.org//)

-- awesome_mode: api-level=4:screen=on
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Theme handling library
local beautiful = require("beautiful")
-- Window Enhancements
local lain = require("lain")
-- Configuration
local config = require("config")
-- Fishlive Enhancements
local fishlive = require("fishlive")
-- Notification library
local naughty = require("naughty")
-- Declarative object management
local ruled = require("ruled")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

-- special layouts import
local treetile = require("treetile")
-- local treetileBindings = require("treetile.bindings")
local machi = require("layout-machi")
-- switching windows in the actual layout
--local machina = require("machina")()
-- cycle focus clients
local cyclefocus = require("cyclefocus")

-- classes and services
local dpi = require("beautiful.xresources").apply_dpi

local io = io

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
        message = message
    }
end)
-- }}}

-- This is used later as the default terminal and editor to run.
terminal = config.user.terminal --"kitty" --"urxvt"
terminal2 = config.user.terminal2nd
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal2 .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey  = "Mod4"
altkey  = "Mod1"
ctrlkey = "Control"
-- }}}
-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it

-- {{{ Layout Definitions
-- Table of layouts to cover with awful.layout.inc, order matters.
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        treetile,
        machi.default_layout,
        awful.layout.suit.tile,
        awful.layout.suit.floating,
        lain.layout.centerwork,
        lain.layout.termfair.center,
        awful.layout.suit.spiral,
        awful.layout.suit.magnifier,
        awful.layout.suit.max,
        awful.layout.suit.max.fullscreen,
        machi.layout.create{ new_placement_cb = machi.layout.placement.empty_then_fair },
        awful.layout.suit.tile.bottom,
        fishlive.layout.mirrored_tile.left,
        -- lain.layout.cascade,
        -- lain.layout.cascade.tile,
        -- lain.layout.termfair,
        -- awful.layout.suit.tile.left,
        -- awful.layout.suit.tile.top,
        -- awful.layout.suit.fair,
        -- awful.layout.suit.fair.horizontal,
        -- awful.layout.suit.spiral.dwindle,
        -- awful.layout.suit.corner.nw,
        -- awful.layout.suit.corner.ne,
        -- awful.layout.suit.corner.sw,
        -- awful.layout.suit.corner.se,
    })
end)

lain.layout.termfair.nmaster           = 3
lain.layout.termfair.ncol              = 1
lain.layout.termfair.center.nmaster    = 3
lain.layout.termfair.center.ncol       = 1
lain.layout.cascade.tile.offset_x      = dpi(2)
lain.layout.cascade.tile.offset_y      = dpi(32)
lain.layout.cascade.tile.extra_padding = dpi(5)
lain.layout.cascade.tile.nmaster       = 5
lain.layout.cascade.tile.ncol          = 2
-- }}}

-- {{{ Theme and Colorscheme Declaration
-- Themes define colours, icons, font and wallpapers.
--beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
local themeName = "multicolor"
beautiful.init(gears.filesystem.get_configuration_dir().."themes/"..themeName.."/theme.lua")
-- }}}

-- {{{ Libraries Configuration after beautiful.init()
-- Bling (must be after beautiful.init())
bling = require("bling")
awful.layout.append_default_layout(bling.layout.mstab)

-- MainMenu
local main_menu = require("fishlive.widget.mebox.menu.main")

-- Nice titlebars
fishlive.plugins.createTitlebarsNiceLib()

-- Dashboard Component
if config.dashboard_enabled then 
    dashboard = require("fishlive.widget.dashboard")()
end

-- Notification Center
popup = require("notifs.notif-center.notif_popup")
-- }}}

-- {{{ Mouse bindings
awful.mouse.append_global_mousebindings({
    awful.button({}, 3, function() main_menu:toggle(nil, { source = "mouse" }) end),
    awful.button({}, 4, awful.tag.viewprev),
    awful.button({}, 5, awful.tag.viewnext),
    awful.button({ modkey, altkey }, 4, function ()
        os.execute(string.format("amixer -q set %s 5%%+", beautiful.volume.channel))
        beautiful.volume.update()
    end),
    awful.button({ modkey, altkey }, 5, function ()
        os.execute(string.format("amixer -q set %s 5%%-", beautiful.volume.channel))
        beautiful.volume.update()
    end),
})
-- }}}

-- {{{ Key bindings

--awful.keyboard.append_global_keybindings(machina.bindings)

-- Personal Awesome keys
awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, "z", function() awesome.emit_signal("dashboard::toggle") end,
       {description = "dashboard toggle", group = "awesome"}),

    -- user directory wallpapers change by keybindings - NEXT/PREVIOUS WALLPAPER
    awful.key({ modkey, altkey }, "w", function() beautiful.change_wallpaper_user(1) end,
        {description = "set next user wallpaper", group = "awesome"}),
    awful.key({ modkey, ctrlkey }, "w", function() beautiful.change_wallpaper_user(-1) end,
        {description = "set previous user wallpaper", group = "awesome"}),

    -- colorscheme directory wallpapers change by keybindings - NEXT/PREVIOUS WALLPAPER
    awful.key({ modkey, altkey }, "c", function() beautiful.change_wallpaper_colorscheme(1) end,
        {description = "set next colorscheme wallpaper", group = "awesome"}),
    awful.key({ modkey, ctrlkey }, "c", function() beautiful.change_wallpaper_colorscheme(-1) end,
        {description = "set previous colorscheme wallpaper", group = "awesome"}),

    -- personal widget notification center
    awful.key({ modkey }, "d", function() popup.visible=not popup.visible end,
        {description = "show notification center", group = "awesome"}),

    -- machi layout special keybindings
    awful.key({ modkey }, ".", function () machi.default_editor.start_interactive() end,
        {description = "machi: edit the current machi layout", group = "layout"}),
    awful.key({ modkey }, "/", function () machi.switcher.start(client.focus) end,
        {description = "machi: switch between windows", group = "layout"}),

    -- treetile layout special keybindings
    awful.key({ modkey }, "x", treetile.vertical,
        {description = "treetile.vertical split", group = "layout"}),
    awful.key({ modkey }, "z", treetile.horizontal,
        {description = "treetile.horizontal split", group = "layout"}),

    -- resize clients with arrows
    awful.key({ modkey, altkey }, "Right", function ()
        local c = client.focus
        if awful.layout.get(c.screen).name ~= "treetile" then
            awful.tag.incmwfact(0.05)
        else
            treetile.resize_horizontal(0.1)
            -- increase or decrease by percentage of current width or height,
            -- the value can be from 0.01 to 0.99, negative or postive
        end
        end,
        {description = "layout.extends right", group = "layout"}),
        awful.key({ modkey, altkey   }, "Left", function ()
        local c = client.focus
        if awful.layout.get(c.screen).name ~= "treetile" then
            awful.tag.incmwfact(-0.05)
        else
            treetile.resize_horizontal(-0.1)
            -- increase or decrease by percentage of current width or height,
            -- the value can be from 0.01 to 0.99, negative or postive
        end
        end,
        {description = "layout.extends left", group = "layout"}),
    awful.key({ modkey, altkey }, "Up", function ()
        local c = client.focus
        if awful.layout.get(c.screen).name ~= "treetile" then
            awful.tag.incmwfact(0.05)
        else
            treetile.resize_vertical(-0.1)
        end
        end,
        {description = "layout.extends up", group = "layout"}),
    awful.key({ modkey, altkey }, "Down", function ()
        local c = client.focus
        if awful.layout.get(c.screen).name ~= "treetile" then
            awful.tag.incmwfact(-0.05)
        else
            treetile.resize_vertical(0.1)
        end
        end,
        {description = "layout.extends down", group = "layout"}),

    -- swap client with arrows
    awful.key({ modkey, "Shift" }, "Right", function ()
          awful.client.swap.byidx(1)
        end,
        {description = "layout.client.swap right", group = "layout"}),
        awful.key({ modkey, "Shift" }, "Left", function ()
          awful.client.swap.byidx(-1)
        end,
        {description = "layout.client.swap left", group = "layout"}),
    awful.key({ modkey, "Shift" }, "Up", function ()
          awful.client.swap.byidx(1)
        end,
        {description = "layout.client.swap up", group = "layout"}),
    awful.key({ modkey, "Shift" }, "Down", function ()
          awful.client.swap.byidx(-1)
        end,
        {description = "layout.client.swap down", group = "layout"}),

    -- focus client with arrows
    awful.key({ modkey, ctrlkey }, "Right", function ()
          awful.client.focus.bydirection("right")
        end,
        {description = "layout.client.focus right", group = "layout"}),
    awful.key({ modkey, ctrlkey }, "Left", function ()
          awful.client.focus.bydirection("left")
        end,
        {description = "layout.client.focus left", group = "layout"}),
    awful.key({ modkey, ctrlkey }, "Up", function ()
          awful.client.focus.bydirection("up")
        end,
        {description = "layout.client.focus up", group = "layout"}),
    awful.key({ modkey, ctrlkey }, "Down", function ()
          awful.client.focus.bydirection("down")
        end,
        {description = "layout.client.focus down", group = "layout"}),

    awful.key({ "Shift" }, "Alt_L", function () beautiful.mykeyboardlayout.next_layout(); end),

    -- Print Screen
    awful.key({}, "Print", function ()
          awful.util.spawn("scrot -e 'mv $f ~/Pictures/screenshots/ 2>/dev/null'", false)
          awful.util.spawn("notify-send \"SCROT\" \"Screenshot created!\"", false)
        end,
        {description="Make screenshot to ~/Pictures/screenshots/", group="awesome"}),

    -- Language Translation Support
    awful.key({ modkey, ctrlkey }, "t", function ()
          awful.util.spawn("notify-trans cs", false)
        end,
        {description="translate to Czech", group="awesome"}),

    -- Language Translation Support
    awful.key({ modkey, ctrlkey, "Shift" }, "t", function ()
          awful.util.spawn("notify-trans en tts", false)
        end,
        {description="translate to English TTS", group="awesome"}),

    -- Language Translation Support
    awful.key({ modkey, altkey }, "t", function ()
          awful.util.spawn("notify-trans cs tts", false)
        end,
        {description="translate to Czech TTS", group="awesome"}),

    -- Lock Support
    awful.key({ modkey }, "Home", function () awful.spawn("lock.sh") end,
              {description="Lock Screen", group="awesome"}),
    awful.key({ modkey }, "F12", function () awful.spawn("poweroff") end,
              {description="Suspend Computer", group="awesome"}),

    -- Rofi Support
    awful.key({ modkey }, "s", function () awful.spawn("rofi -show-icons -modi windowcd,window,drun -show drun") end,
              {description="show rofi drun", group="launcher"}),
    awful.key({modkey, altkey},"p",function() awful.spawn.with_shell("rofi-pass -t") end,
              {description="types password from pass",group="launcher"}),
    awful.key({modkey, ctrlkey},"p", function() awful.spawn.with_shell("rofi-pass") end,
              {description="copy password from pass",group="launcher"}),

    -- Layout and Gaps Support
    awful.key({ modkey, ctrlkey }, "=", function () lain.util.useless_gaps_resize(1) end,
              {description="increase gaps between windows", group="awesome"}),

    awful.key({ modkey, ctrlkey }, "-", function () lain.util.useless_gaps_resize(-1) end,
              {description="decrease gaps between windows", group="awesome"}),

    -- Widgets popups
    awful.key({ modkey }, "h", function () if beautiful.fs then beautiful.fs.show(7) end end,
              {description = "show filesystem", group = "widgets"}),
    -- ALSA volume control
    awful.key({ modkey, altkey }, "k", function ()
            os.execute(string.format("amixer -q set %s 5%%+", beautiful.volume.channel))
            beautiful.volume.update()
        end,
        {description="sounds volume up", group="awesome"}),
    awful.key({ modkey, altkey }, "j", function ()
            os.execute(string.format("amixer -q set %s 5%%-", beautiful.volume.channel))
            beautiful.volume.update()
        end,
        {description="sounds volume down", group="awesome"}),
    awful.key({ modkey, altkey }, "m",
        function ()
            os.execute(string.format("amixer -q set %s toggle", beautiful.volume.channel))
            beautiful.volume.update()
        end,
        {description="sounds volume toggle mute", group="awesome"}),
    awful.key({ modkey, altkey }, "0",
        function ()
            os.execute(string.format("amixer -q set %s 0%%", beautiful.volume.channel))
            beautiful.volume.update()
        end,
        {description="sounds volume 0%", group="awesome"}),
})

-- General Awesome keys
awful.keyboard.append_global_keybindings({
    awful.key({ modkey, ctrlkey }, "s", hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey }, "w", function () main_menu:toggle(nil, { source = "mouse" }) end,
              {description = "show main menu", group = "awesome"}),
    awful.key({ modkey }, "q", function () fishlive.widget.exit_screen() end,
              {description = "exit screen", group = "awesome"}),
    awful.key({ modkey }, "c", function () beautiful.menu_colorschemes_create():toggle() end,
              {description = "show colorschemes menu", group = "awesome"}),
    awful.key({ modkey }, "x", function () beautiful.menu_portrait_create():toggle() end,
              {description = "show portrait menu for love tag", group = "awesome"}),
    awful.key({ modkey }, "a", function () awful.spawn("clipmenu") end,
              {description = "clipboard history by rofi/clipmenud", group = "awesome"}),
    awful.key({ modkey }, "l", function() awful.menu.client_list { theme = { width = 250 } } end,
              {description="show client list", group="awesome"}),
    awful.key({ modkey, ctrlkey }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift" }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),
    awful.key({ modkey, ctrlkey }, "x", function ()
        awful.prompt.run {
            prompt       = "Run Lua code: ",
            textbox      = awful.screen.focused().mypromptbox.widget,
            exe_callback = awful.util.eval,
            history_path = awful.util.get_cache_dir() .. "/history_eval"
        }
        end,
        {description = "lua execute prompt", group = "awesome"}),
    awful.key({ modkey }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal (alacritty)", group = "launcher"}),
    awful.key({ modkey, altkey }, "Return", function () awful.spawn(terminal2) end,
              {description = "open a terminal2 (wezterm)", group = "launcher"}),
    awful.key({ modkey }, "r", function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the d-menu", group = "launcher"}),
})

-- Tags related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, "Left", awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey }, "Right",awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
})

-- Focus related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ modkey }, "j", function () awful.client.focus.byidx(1) end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey }, "k", function () awful.client.focus.byidx(-1) end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey }, "Tab", function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),
    awful.key({ modkey, ctrlkey }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, ctrlkey }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey, ctrlkey }, "n", function ()
              local c = awful.client.restore()
              -- Focus restored client
              if c then
                c:activate { raise = true, context = "key.unminimize" }
              end
          end,
          {description = "restore minimized", group = "client"}),
})

-- Tabbed related keybindings
awful.keyboard.append_global_keybindings({
    awful.key {
        modifiers   = { modkey, ctrlkey },
        keygroup    = "numpad",
        description = "tabbed features",
        group       = "client",
        on_press    = function(index)
            if index == 1 then bling.module.tabbed.pick_with_dmenu()
            elseif index == 2 then bling.module.tabbed.pick_by_direction("down")
            elseif index == 4 then bling.module.tabbed.pick_by_direction("left")
            elseif index == 5 then bling.module.tabbed.iter()
            elseif index == 6 then bling.module.tabbed.pick_by_direction("right")
            elseif index == 7 then bling.module.tabbed.pick()
            elseif index == 8 then bling.module.tabbed.pick_by_direction("up")
            elseif index == 9 then bling.module.tabbed.pop()
            end
        end
    },
})

-- Layout related keybindings
awful.keyboard.append_global_keybindings({
    awful.key({ modkey, "Shift" }, "j", function () awful.client.swap.byidx(1) end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift" }, "k", function () awful.client.swap.byidx(-1) end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey }, "l", function () awful.tag.incmwfact( 0.05) end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey }, "h", function () awful.tag.incmwfact(-0.05) end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift" }, "h", function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift" }, "l", function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, ctrlkey }, "h", function () awful.tag.incncol( 1, nil, true) end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, ctrlkey }, "l", function () awful.tag.incncol(-1, nil, true) end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey }, "space", function () awful.layout.inc( 1) end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift" }, "space", function () awful.layout.inc(-1) end,
              {description = "select previous", group = "layout"}),
})


awful.keyboard.append_global_keybindings({
    awful.key({ modkey, ctrlkey, "Shift" }, "Right", function()
      local screen = awful.screen.focused()
      local t = screen.selected_tag
      if t then
          local idx = t.index + 1
          if idx > #screen.tags then idx = 1 end
          if client.focus then
            client.focus:move_to_tag(screen.tags[idx])
            screen.tags[idx]:view_only()
          end
      end
    end,
    {description = "move focused client to next tag and view tag", group = "tag"}),

    awful.key({ modkey, ctrlkey, "Shift" }, "Left", function()
      local screen = awful.screen.focused()
      local t = screen.selected_tag
      if t then
          local idx = t.index - 1
          if idx == 0 then idx = #screen.tags end
          if client.focus then
            client.focus:move_to_tag(screen.tags[idx])
            screen.tags[idx]:view_only()
          end
      end
    end,
    {description = "move focused client to previous tag and view tag", group = "tag"}),

    awful.key {
        modifiers   = { modkey },
        keygroup    = "numrow",
        description = "only view tag",
        group       = "tag",
        on_press    = function (index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                tag:view_only()
            end
        end,
    },
    awful.key {
        modifiers   = { modkey, ctrlkey },
        keygroup    = "numrow",
        description = "toggle tag",
        group       = "tag",
        on_press    = function (index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end,
    },
    awful.key {
        modifiers = { modkey, "Shift" },
        keygroup    = "numrow",
        description = "move focused client to tag",
        group       = "tag",
        on_press    = function (index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end,
    },
    awful.key {
        modifiers   = { modkey, ctrlkey, "Shift" },
        keygroup    = "numrow",
        description = "toggle focused client on tag",
        group       = "tag",
        on_press    = function (index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end,
    },
    awful.key {
        modifiers   = { modkey },
        keygroup    = "numpad",
        description = "select layout directly",
        group       = "layout",
        on_press    = function (index)
            local t = awful.screen.focused().selected_tag
            if t then
                t.layout = t.layouts[index] or t.layout
            end
        end,
    }
})

client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings({
        awful.button({}, 1, function (c)
            c:activate { context = "mouse_click" }
        end),
        awful.button({ modkey }, 1, function (c)
            c:activate { context = "mouse_click", action = "mouse_move"  }
        end),
        awful.button({ modkey }, 3, function (c)
            c:activate { context = "mouse_click", action = "mouse_resize"}
        end),
    })
end)

-- {{ Personal keybindings
client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
        -- swap and rotate clients in treetile layout
        awful.key({ modkey, "Shift" }, "r", function (c) treetile.rotate(c) end,
            {description = "treetile.container.rotate", group = "layout"}),
        awful.key({ modkey, "Shift" }, "s", function (c) treetile.swap(c) end,
            {description = "treetile.container.swap", group = "layout"}),

        -- transparency for focused client
        awful.key({ modkey }, "Next", function (c) awful.util.spawn("transset-df -a --inc 0.20 --max 0.99") end,
            {description="Client Transparency Up", group="client"}),
        awful.key({ modkey }, "Prior", function (c) awful.util.spawn("transset-df -a --min 0.1 --dec 0.1") end,
            {description="Client Transparency Down", group="client"}),

        -- show/hide titlebar
        awful.key({ modkey }, "t", awful.titlebar.toggle,
            {description = "Show/Hide Titlebars", group="client"}),

        -- altkey+Tab: cycle through all clients.
        awful.key({ altkey }, "Tab", function(c)
                cyclefocus.cycle({modifier="Alt_L"})
            end,
            {description = "Cycle through all clients", group="client"}
        ),
        -- altkey+Shift+Tab: backwards
        awful.key({ altkey, "Shift" }, "Tab", function(c)
                cyclefocus.cycle({modifier="Alt_L"})
            end,
            {description = "cycle through all clients backwards", group="client"}
        ),
    })
end)
--}}

client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
       -- Store debug information
        awful.key({ modkey, "Shift" }, "d", function (c)
                --naughty.notify {
                --    text = fishlive.helpers.screen_res_y()
                --}
                local val = awesome.systray()
                local file = io.open(os.getenv("HOME") .. "/.config/awesome/debug.txt", "a")
                file:write("systray.tostring=" .. val .. "\n")
                file:close()
            end,
            {description = "store debug information to awesome/debug.txt", group = "client"}),
        awful.key({ modkey }, "f", function (c)
                c.fullscreen = not c.fullscreen
                c:raise()
            end,
            {description = "toggle fullscreen", group = "client"}),
        awful.key({ modkey, "Shift" }, "c", function (c) c:kill() end,
                {description = "close", group = "client"}),
        awful.key({ modkey, ctrlkey }, "space", awful.client.floating.toggle,
                {description = "toggle floating", group = "client"}),
        awful.key({ modkey, ctrlkey }, "Return", function (c) c:swap(awful.client.getmaster()) end,
                {description = "move to master", group = "client"}),
        awful.key({ modkey }, "o", function (c) c:move_to_screen() end,
                {description = "move to screen", group = "client"}),
        awful.key({ modkey }, "t", function (c) c.ontop = not c.ontop end,
                {description = "toggle keep on top", group = "client"}),
        awful.key({ modkey }, "n", function (c)
                -- The client currently has the input focus, so it cannot be
                -- minimized, since minimized clients can't have the focus.
                c.minimized = true
            end ,
            {description = "minimize", group = "client"}),
        awful.key({ modkey }, "m", function (c)
                c.maximized = not c.maximized
                c:raise()
            end ,
            {description = "(un)maximize", group = "client"}),
        awful.key({ modkey, ctrlkey }, "m", function (c)
                c.maximized_vertical = not c.maximized_vertical
                c:raise()
            end ,
            {description = "(un)maximize vertically", group = "client"}),
        awful.key({ modkey, "Shift"   }, "m", function (c)
                c.maximized_horizontal = not c.maximized_horizontal
                c:raise()
            end ,
            {description = "(un)maximize horizontally", group = "client"}),
    })
end)

-- Steam bug with window outside of the screen
client.connect_signal("property::position", function(c)
     if c.class == 'Steam' then
         local g = c.screen.geometry
         if c.y + c.height > g.height then
             c.y = g.height - c.height
             naughty.notify{
                 text = "restricted window: " .. c.name,
             }
         end
         if c.x + c.width > g.width then
             c.x = g.width - c.width
         end
     end
 end)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients.
ruled.client.connect_signal("request::rules", function()
    -- All clients will match this rule.
    ruled.client.append_rule {
        id         = "floating",
        rule_any = {
            name = { "Ulauncher - Application Launcher" },
        },
        properties = {
            focus     = awful.client.focus.filter,
            raise     = true,
            screen    = awful.screen.preferred,
            border_width = 0,
        }
    }

    ruled.client.append_rule {
        id         = "global",
        rule       = { },
        properties = {
            focus     = awful.client.focus.filter,
            raise     = true,
            screen    = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen
        }
    }

    -- Floating clients.
    ruled.client.append_rule {
        id       = "floating",
        rule_any = {
            instance = { "copyq", "pinentry" },
            class    = {
                "Arandr", "Blueman-manager", "Gpick", "Kruler", "Sxiv",
                "Tor Browser", "Wpa_gui", "veromix", "xtightvncviewer",
                "Pamac-manager",
                "Polkit-gnome-authentication-agent-1",
                "Polkit-kde-authentication-agent-1",
                "Gcr-prompter",
            },
            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name    = {
                "Event Tester",  -- xev.
                "Remmina Remote Desktop Client",
                "win0",
            },
            role    = {
                "AlarmWindow",    -- Thunderbird's calendar.
                "ConfigManager",  -- Thunderbird's about:config.
                "pop-up",         -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = { floating = true },
        callback = function (c)
            awful.placement.centered(c, nil)
        end
    }

    -- Add titlebars to normal clients and dialogs
    ruled.client.append_rule {
        id         = "dialogs",
        rule_any   = { type = { "dialog" } },
        except_any = {
          -- place here exceptions for special dialogs windows
        },
        properties = { floating = true },
        callback = function (c)
            awful.placement.centered(c, nil)
        end
    }

    -- FullHD Resolution for Specific Apps
    ruled.client.append_rule {
        id         = "dialogs",
        rule_any   = {
            instance = { "remmina",}
        },
        except_any = {
            name = {
                "Remmina Remote Desktop Client"
            }
        },
        properties = { floating = true },
        callback = function (c)
            c.width = 1980
            c.height = 1080
            awful.placement.centered(c, nil)
        end
    }

    -- All Dialogs are floating and center
    ruled.client.append_rule {
        id         = "titlebars",
        rule_any   = { type = { "normal", "dialog" } },
        properties = { titlebars_enabled = true      }
    }

    -- Set Blender to always map on the tag 4 in screen 1.
    ruled.client.append_rule {
        rule_any    = {
            name = {"Blender"}
        },
        properties = {
            tag = screen[1].tags[4],
        },
    }
end)

-- }}}

-- {{{ Manage new client

client.connect_signal("manage", function(c)
    -- Similar behaviour as other window managers DWM, XMonad.
    -- Master-Slave layout new client goes to the slave, master is kept
    -- If you need new slave as master press: ctrl + super + return
    if not awesome.startup then c:to_secondary_section() end
end)

-- }}}

-- {{{ Titlebars
-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    --buttons for the titlebar
    -- local buttons = {
    --     awful.button({ }, 1, function()
    --         c:activate { context = "titlebar", action = "mouse_move"  }
    --     end),
    --     awful.button({ }, 3, function()
    --         c:activate { context = "titlebar", action = "mouse_resize"}
    --     end),
    -- }

    -- awful.titlebar(c).widget = {
    --     { -- Left
    --         awful.titlebar.widget.iconwidget(c),
    --         buttons = buttons,
    --         layout  = wibox.layout.fixed.horizontal
    --     },
    --     { -- Middle
    --         { -- Title
    --             align  = "center",
    --             widget = awful.titlebar.widget.titlewidget(c)
    --         },
    --         buttons = buttons,
    --         layout  = wibox.layout.flex.horizontal
    --     },
    --     { -- Right
    --         awful.titlebar.widget.floatingbutton (c),
    --         awful.titlebar.widget.maximizedbutton(c),
    --         awful.titlebar.widget.stickybutton   (c),
    --         awful.titlebar.widget.ontopbutton    (c),
    --         awful.titlebar.widget.closebutton    (c),
    --         layout = wibox.layout.fixed.horizontal()
    --     },
    --     layout = wibox.layout.align.horizontal
    -- }
    awful.titlebar.hide(c)
end)
-- }}}

-- {{{ Notifications

ruled.notification.connect_signal('request::rules', function()
    -- All notifications will match this rule.
    ruled.notification.append_rule {
        rule       = { },
        properties = {
            screen = awful.screen.preferred,
            --implicit_timeout = 5,
        }
    }
end)

-- Store notifications to the file
naughty.connect_signal("added", function(n)
    -- local file = io.open(os.getenv("HOME") .. "/.config/awesome/naughty_history", "a")
    -- file:write(n.title .. ": " .. n.id .. " " .. n.message .. "\n")
    -- file:close()
end)

-- }}}

--{{{ Focusing

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:activate { context = "mouse_enter", raise = false }
end)

--}}}

--{{{ Application Starts
awful.spawn.with_shell("~/.config/awesome/autorun.sh")
--}}}
