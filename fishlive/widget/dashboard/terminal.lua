local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local fishlive = require("fishlive")
local markup = require("lain").util.markup
local config = require("config")
local dpi = require("beautiful.xresources").apply_dpi

local signal = "signal::terminal"

-- Define a function to parse terminal color codes and replace with markup tags
local function parse_colors(output)
    output = string.gsub(output, "\27%[([0-9;]+)m", '<span color="red">')
    output = string.gsub(output, "\27%[0m", '</span>')
    output = string.gsub(output, "\\([nt])", {n="\n", t="\t"})
    return output
end

return function(sig_terminal)
  local maxwidth = fishlive.helpers.screen_res_x() * 0.5
  local maxheight = (fishlive.helpers.screen_res_y() - 650) / 2

  local terminal_textbox = wibox.widget {
    bg = beautiful.bg_normal,
    align = "left",
    valign = "center",
    widget = wibox.widget.textbox
  }

  local terminal_wibox = wibox.widget {
    terminal_textbox,
    layout = require("fishlive.widget.overflow").vertical,
    scrollbar_width = 2,
    spacing = 7,
    scroll_speed = 15,
  }
  terminal_wibox.forced_height = maxheight

  awesome.connect_signal(signal, function(event)
    terminal_textbox.markup = markup.fontfg(
        beautiful.operator_font.." 10",
        beautiful.base0B,
        parse_colors(event.value)
    )
    local width = terminal_textbox:get_preferred_size()
      if width > maxwidth then
        terminal_wibox.forced_width = maxwidth
      else
        terminal_wibox.forced_width = width
    end
  end)

    local new_menu = function()
    local menu = awful.menu({
        items = (function()
          local menucmd = {}
          for i, cmd in ipairs(config.terminal_cmds) do
              menucmd[i] = { cmd.cmd, function()
                if cmd.prompt then
                  awful.prompt.run {
                    prompt       = '<b>'..cmd.prompt..' </b>',
                    bg_cursor    = '#ff0000',
                    textbox      = mouse.screen.mypromptbox.widget,
                    exe_callback = function(input)
                        if not input or #input == 0 then return end
                        cmd.req = string.gsub(cmd.cmd, "${input}", input)
                        awesome.emit_signal("signal::terminal::command", cmd)
                    end
                  }
                else
                  cmd.req = cmd.cmd
                  awesome.emit_signal("signal::terminal::command", cmd)
                end
              end}
          end
          return menucmd
        end)(),
        theme = {
            height = dpi(18),
            width  = dpi(500)
        }
    })
    fishlive.widget.click_to_hide_menu(menu, nil, true)
    return menu
  end

  terminal_wibox:connect_signal('button::press', function(_, _, _, button)
    if button == 1 then
      sig_terminal.t:emit_signal("timeout")
    elseif button == 3 then
      new_menu():toggle()
    end
  end)

  return terminal_wibox
end
