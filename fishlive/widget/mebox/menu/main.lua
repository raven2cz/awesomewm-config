local capi = {
    awesome = awesome,
}
local table = table
local awful = require("awful")
local beautiful = require("beautiful")
local config = require("config")
local mebox = require("fishlive.widget.mebox.mebox")
local menu_templates = require("fishlive.widget.mebox.menu.templates")
local dpi = require("beautiful.xresources").apply_dpi


local main_menu

local menu_items = {}

table.insert(menu_items, mebox.header("Scripts"))
table.insert(menu_items, {
    text = "Dashboard",
    icon = beautiful.dir .. "/icons/dashboard.svg",
    icon_color = beautiful.base08,
    callback = function() awesome.emit_signal("dashboard::toggle") end,
})
table.insert(menu_items, {
    text = "Update Notes",
    icon = beautiful.dir .. "/icons/file-document-edit.svg",
    icon_color = beautiful.base07,
    callback = function() awful.spawn("notes_sync_notif") end,
})
table.insert(menu_items, mebox.separator)
table.insert(menu_items, mebox.header("Favorites"))
table.insert(menu_items, {
    text = "terminal",
    icon = beautiful.dir .. "/icons/console-line.svg",
    icon_color = beautiful.base08,
    callback = function() awful.spawn(config.user.terminal) end,
})
table.insert(menu_items, {
    text = "web browser",
    icon = beautiful.dir .. "/icons/firefox.svg",
    icon_color = beautiful.base0B,
    callback = function() awful.spawn(config.apps.browser) end,
})
table.insert(menu_items, {
    text = "file manager",
    icon = beautiful.dir .. "/icons/folder.svg",
    icon_color = beautiful.base09,
    callback = function() awful.spawn(config.apps.fileexplorer) end,
})
table.insert(menu_items, {
    text = "editor",
    icon = beautiful.dir .. "/icons/visual-studio-code.svg",
    icon_color = beautiful.base07,
    callback = function() awful.spawn(config.apps.editor) end,
})
table.insert(menu_items, {
    text = "ide",
    icon = beautiful.dir .. "/icons/intellij.svg",
    icon_color = beautiful.base0D,
    callback = function() awful.spawn(config.apps.ide) end,
})
table.insert(menu_items, mebox.separator)
table.insert(menu_items, {
    text = "applications",
    icon = beautiful.dir .. "/icons/apps.svg",
    icon_color = beautiful.base0C,
    cache_submenu = false,
    submenu = menu_templates.applications.shared,
})
table.insert(menu_items, {
    text = "config",
    icon = beautiful.dir .. "/icons/apps.svg",
    icon_color = beautiful.base0D,
    submenu = menu_templates.config.shared,
})
table.insert(menu_items, mebox.separator)
table.insert(menu_items, mebox.header("Power/Session"))
table.insert(menu_items, {
    text = "Shutdown",
    icon = beautiful.dir .. "/icons/power.svg",
    icon_color = beautiful.base09,
    callback = function() awful.spawn("poweroff") end,
})
table.insert(menu_items, {
    text = "Reboot",
    icon = beautiful.dir .. "/icons/restart.svg",
    icon_color = beautiful.base0A,
    callback = function() awful.spawn("reboot") end,
})
table.insert(menu_items, {
    text = "Lock",
    icon = beautiful.dir .. "/icons/lock.svg",
    icon_color = beautiful.base0B,
    callback = function() awful.spawn("lock.sh") end,
})


main_menu = mebox {
    click_to_hide = true,
    item_width = dpi(192),
    items_source = menu_items,
}

return main_menu
