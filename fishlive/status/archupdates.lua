local awful = require("awful")
local status = {}

local command = "aurupdates.sh"
local signal = "status::archupdates"
local interval = 1800 -- per 30 mins

awful.widget.watch(command, interval, function(_, stdout)
    awesome.emit_signal(signal, stdout)
end)

function status.emit_signal()
    awful.spawn.easy_async_with_shell(command, function(stdout)
        awesome.emit_signal(signal, stdout)
    end)
end

return status
