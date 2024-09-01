local naughty = require("naughty")
local gears = require("gears")
local dpi = require("beautiful.xresources").apply_dpi
local rnotification = require("ruled.notification")
local menubar = require('menubar')

local standard_naughty = {}

--------------------------
-- NAUGHTY CONFIGURATION
--------------------------
function standard_naughty.init_environment(dsconfig)
    local theme = dsconfig.theme
    local notif_user = theme.notif_user
    local notifpath_user = theme.notifpath_user

    naughty.config.defaults.ontop = true
    naughty.config.defaults.icon_size = dpi(360)
    naughty.config.defaults.timeout = 10
    naughty.config.defaults.hover_timeout = 300
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
                font             = theme.font_notify,
                bg               = theme.bg_urgent,
                fg               = theme.fg_normal,
                margin           = dpi(16),
                icon_size        = dpi(360),
                position         = 'top_middle',
                implicit_timeout = 0
            }
        }

        -- Normal notifs
        rnotification.append_rule {
            rule       = { urgency = 'normal' },
            properties = {
                font             = theme.font_notify,
                bg               = theme.notification_bg,
                fg               = theme.notification_fg,
                margin           = dpi(16),
                position         = 'top_middle',
                implicit_timeout = 10,
                icon_size        = dpi(360),
                opacity          = 0.87
            }
        }

        -- Low notifs
        rnotification.append_rule {
            rule       = { urgency = 'low' },
            properties = {
                font             = theme.font_notify,
                bg               = theme.notification_bg,
                fg               = theme.notification_fg,
                margin           = dpi(16),
                position         = 'top_middle',
                implicit_timeout = 10,
                icon_size        = dpi(360),
                opacity          = 0.87
            }
        }
    end
    )

    -- Error handling
    naughty.connect_signal('request::display_error', function(message, startup)
        naughty.notification {
            urgency  = 'critical',
            title    = 'Oops, an error happened' .. (startup and ' during startup!' or '!'),
            message  = message,
            app_name = 'System Notification',
            icon     = theme.awesome_icon
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

    naughty.connect_signal("request::action_icon", function(a, _, hints)
        a.icon = menubar.utils.lookup_icon(hints.id)
    end)
end

return standard_naughty