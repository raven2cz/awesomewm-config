local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local markup = require "lain".util.markup
local dpi = xresources.apply_dpi

local function exit_screen()
    -- Appearance
    local font = gears.string.split(beautiful.font, " ")[1] or "sans"
    local icon_font = beautiful.icon_font .. "90" or "TerminessTTF NF 90"
    local icon_normal_color = beautiful.fg_focus or "#54ff54"
    local icon_hover_color = beautiful.fg_urgent or "#18b218"

    local username = os.getenv("USER")
    -- Capitalize username
    local goodbye_widget = wibox.widget.textbox("Goodbye " .. username:sub(1, 1):upper() .. username:sub(2) .. "!")
    goodbye_widget.font = font .. " 70"

    -- Get screen geometry
    local s = awful.screen.focused()
    local geo_x = s.geometry.x
    local geo_y = s.geometry.y
    local geo_width = s.geometry.width
    local geo_height = s.geometry.height

    -- Create the widget
    local exit_screen = wibox({
        x = geo_x,
        y = geo_y,
        visible = false,
        ontop = true,
        type = "dock",
        screen = s,
        height = geo_height,
        width = geo_width
    })
    exit_screen.bg = beautiful.bg_normal .. "cc" or "#000000cc"
    exit_screen.fg = beautiful.fg_normal or "#b2b2b2"

    local exitKey = "Escape"
    local exit_screen_grabber

    local function big_button_widget(button_text_icon, button_text, action)
        local button_icon = wibox.widget.textbox()
        button_icon.font = icon_font
        button_icon.markup = "<span foreground='" .. icon_normal_color .. "'>" .. button_text_icon .. "</span>"

        local button_text = wibox.widget.textbox(button_text)
        button_text.font = font .. " 25"

        local result = wibox.widget {
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

        result:buttons(gears.table.join(awful.button({}, 1, function()
            action()
            awesome.emit_signal("exit_screen::close")
        end)
        ))

        -- Add shortcut (awesome bug doesn't work correctly)
        --if shortcut then
        --    exit_screen_grabber:add_keybinding(
        --        awful.key({ key = shortcut, modifiers = {}, on_press = action})
        --    )
        --end

        -- Add visual hover effect
        button_icon:connect_signal("mouse::enter", function()
            button_icon.markup = "<span foreground='" .. icon_hover_color .. "'>" .. button_icon.text .. "</span>"
        end)
        result:connect_signal("mouse::enter", function()
            ---@diagnostic disable-next-line: undefined-field
            local w = _G.mouse.current_wibox
            if w then
                w.cursor = "hand1"
            end
        end)
        button_icon:connect_signal("mouse::leave", function()
            button_icon.markup = "<span foreground='" .. icon_normal_color .. "'>" .. button_icon.text .. "</span>"
        end)
        result:connect_signal("mouse::leave", function()
            ---@diagnostic disable-next-line: undefined-field
            local w = _G.mouse.current_wibox
            if w then
                w.cursor = "left_ptr"
            end
        end)

        return result
    end

    local exit_actions = {
        ["poweroff"] = function() awful.spawn.with_shell("systemctl poweroff") end,
        ["reboot"] = function() awful.spawn.with_shell("systemctl reboot") end,
        ["hibernate"] = function() awful.spawn.with_shell("systemctl hibernate") end,
        ["suspend"] = function() awful.spawn.with_shell("systemctl suspend") end,
        ["refresh"] = function() awesome.restart() end,
        ["exit"] = function() awesome.quit() end,
        ["lock"] = function() awful.spawn("lock.sh") end
    }

    local function getKeygrabber()
        return awful.keygrabber {
            keypressed_callback = function(_, mod, key)
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
                elseif key == exitKey or key == 'q' or key == 'x' then
                    awesome.emit_signal("exit_screen::close")
                end
            end,
        }
    end

    local poweroff          = big_button_widget("", "[P]oweroff", exit_actions["poweroff"])
    local reboot            = big_button_widget("", "[R]eboot", exit_actions["reboot"])
    local hibernate         = big_button_widget("", "[H]ibernate", exit_actions["hibernate"])
    local suspend           = big_button_widget("", "[S]uspend", exit_actions["suspend"])
    local refresh           = big_button_widget("", "Re[f]resh", exit_actions["refresh"])
    local exit              = big_button_widget("󰗼", "[E]xit", exit_actions["exit"])
    local lock              = big_button_widget("", "[L]ock", exit_actions["lock"])

    exit_screen_grabber     = getKeygrabber()

    exit_screen.signals_on  = function()
        -- Get new screen geometry
        s = awful.screen.focused()
        geo_x = s.geometry.x
        geo_y = s.geometry.y
        geo_width = s.geometry.width
        geo_height = s.geometry.height

        -- Update the widget
        exit_screen.screen = s
        exit_screen.x = geo_x
        exit_screen.y = geo_y
        exit_screen.height = geo_height
        exit_screen.width = geo_width

        exit_screen_grabber:start()
    end

    exit_screen.signals_off = function()
        exit_screen_grabber:stop()
    end

    exit_screen.close       = function()
        exit_screen.visible = false
        exit_screen.signals_off()
    end

    exit_screen.toggle      = function()
        exit_screen.visible = not exit_screen.visible
        if exit_screen.visible then
            exit_screen_grabber = getKeygrabber()
            exit_screen.signals_on()
            awesome.emit_signal("exit_screen::open")
        else
            exit_screen.signals_off()
        end
    end

    exit_screen:buttons(gears.table.join(
    -- Middle click - Hide exit_screen
        awful.button({}, 2, function()
            awesome.emit_signal("exit_screen::close")
        end),
        -- Right click - Hide exit_screen
        awful.button({}, 3, function()
            awesome.emit_signal("exit_screen::close")
        end)
    ))

    -- listen to signal emitted by other widgets
    awesome.connect_signal("exit_screen::toggle", exit_screen.toggle)
    awesome.connect_signal("exit_screen::close", exit_screen.close)

    -- switch off signals after start, just read once only!
    exit_screen.signals_off()

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
end

return exit_screen
