local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local markup = require "lain".util.markup
local dpi = xresources.apply_dpi

-- Appearance
local font = gears.string.split(beautiful.font, " ")[1] or "sans"
local icon_font = beautiful.icon_font .. "90" or "TerminessTTF NF 90"
local icon_normal_color = beautiful.fg_focus or "#54ff54"
local icon_hover_color = beautiful.fg_urgent or "#18b218"

local username = os.getenv("USER")
-- Capitalize username
local goodbye_widget = wibox.widget.textbox("Goodbye " .. username:sub(1,1):upper()..username:sub(2) .. "!")
goodbye_widget.font = font .. " 70"

-- Get screen geometry
local screen_width = awful.screen.focused().geometry.width
local screen_height = awful.screen.focused().geometry.height

-- Create the widget
local exit_screen = wibox({x = 0, y = 0, visible = false, ontop = true, type = "dock", height = screen_height, width = screen_width})
exit_screen.bg = beautiful.bg_normal .. "cc" or "#000000cc"
exit_screen.fg = beautiful.fg_normal or "#b2b2b2"

local exit_screen_grabber

local function exit_screen_hide()
    exit_screen_grabber:stop()
    exit_screen.visible = false
end
local function exit_screen_show()
    exit_screen.visible = true
    exit_screen_grabber:start()
end

exit_screen:buttons(gears.table.join(
    -- Middle click - Hide exit_screen
    awful.button({}, 2, function ()
          exit_screen_hide()
    end),
    -- Right click - Hide exit_screen
    awful.button({}, 3, function ()
          exit_screen_hide()
    end)
))

local function big_button_widget(button_text_icon, button_text, action)
    local button_icon = wibox.widget.textbox()
    button_icon.font = icon_font
    button_icon.markup = "<span foreground='" .. icon_normal_color .."'>" .. button_text_icon .. "</span>"

    local button_text = wibox.widget.textbox(button_text)
    button_text.font = font .. " 25"

    local result = wibox.widget{
        {
            nil,
            button_icon,
            forced_height = dpi(170),
            expand = "none",
            layout = wibox.layout.align.horizontal
        },
        {
            nil,
            button_text,
            expand = "none",
            layout = wibox.layout.align.horizontal
        },
        -- forced_width = 100,
        layout = wibox.layout.fixed.vertical
    }

    result:buttons(gears.table.join(awful.button({}, 1, function ()
          action()
          exit_screen_hide()
      end)
    ))

    -- Add shortcut (awesome bug doesn't work correctly)
    --if shortcut then
    --    exit_screen_grabber:add_keybinding(
    --        awful.key({ key = shortcut, modifiers = {}, on_press = action})
    --    )
    --end

    -- Add visual hover effect
    button_icon:connect_signal("mouse::enter", function ()
        button_icon.markup = "<span foreground='" .. icon_hover_color .."'>" .. button_icon.text .. "</span>"
    end)
    result:connect_signal("mouse::enter", function ()
        ---@diagnostic disable-next-line: undefined-field
        local w = _G.mouse.current_wibox
        if w then
            w.cursor = "hand1"
        end
    end)
    button_icon:connect_signal("mouse::leave", function ()
        button_icon.markup = "<span foreground='" .. icon_normal_color .."'>" .. button_icon.text .. "</span>"
    end)
    result:connect_signal("mouse::leave", function ()
        ---@diagnostic disable-next-line: undefined-field
        local w = _G.mouse.current_wibox
        if w then
            w.cursor = "left_ptr"
        end
    end)

    return result
end

local exit_actions = {
    ["poweroff"] = function () awful.spawn.with_shell("systemctl poweroff") end,
    ["reboot"] = function () awful.spawn.with_shell("systemctl reboot") end,
    ["hibernate"] = function () awful.spawn.with_shell("systemctl hibernate") end,
    ["suspend"] = function () awful.spawn.with_shell("systemctl suspend") end,
    ["refresh"] = function () awesome.restart() end,
    ["exit"] = function () awesome.quit() end,
    ["lock"] = function () awful.spawn("lock.sh") end
}

exit_screen_grabber = awful.keygrabber {
    auto_start = true,
	stop_event = 'release',
	keypressed_callback = function(self, mod, key, command)
                if key == 'p' then
			exit_actions["poweroff"]()

		elseif key == 'r' then
			exit_actions["reboot"]()

		elseif key == 'h' then
			exit_actions["hibernate"]()

		elseif key == 's' then
			exit_actions["suspend"]()

		elseif key == 'f' then
			exit_actions["refresh"]()

                elseif key == 'e' then
			exit_actions["exit"]()

                elseif key == 'l' then
			exit_actions["lock"]()

		elseif key == 'Escape' or key == 'q' or key == 'x' then
			exit_screen_hide()
		end
    end
}

local poweroff  = big_button_widget("", "[P]oweroff", exit_actions["poweroff"])
local reboot    = big_button_widget("", "[R]eboot", exit_actions["reboot"])
local hibernate = big_button_widget("", "[H]ibernate", exit_actions["hibernate"])
local suspend   = big_button_widget("", "[S]uspend", exit_actions["suspend"])
local refresh   = big_button_widget("", "Re[f]resh", exit_actions["refresh"])
local exit      = big_button_widget("󰗼", "[E]xit",exit_actions["exit"])
local lock      = big_button_widget("", "[L]ock", exit_actions["lock"])

-- Item placement
exit_screen:setup {
    nil,
    {
        {
            nil,
            goodbye_widget,
            nil,
            expand = "none",
            layout = wibox.layout.align.horizontal
        },
        {
            nil,
            {
                poweroff,
                reboot,
                -- hibernate,
                suspend,
                refresh,
                exit,
                lock,
                spacing = dpi(70),
                layout = wibox.layout.fixed.horizontal
            },
            nil,
            expand = "none",
            layout = wibox.layout.align.horizontal
            -- layout = wibox.layout.fixed.horizontal
        },
        spacing = dpi(42),
        layout = wibox.layout.fixed.vertical
    },
    nil,
    expand = "none",
    layout = wibox.layout.align.vertical
}

return exit_screen_show
