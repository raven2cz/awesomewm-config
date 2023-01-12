local signal_watch = require("fishlive.signal.signal_watch")

local command = 'brightnessctl info'
local signal = "signal::brightness"
local interval = 1

return signal_watch(command, interval, true, true, function(stdout, _, _, _)
    local value = tonumber(string.match(string.match(stdout, "%d+%%"), "%d+"))

    awesome.emit_signal(signal, {
        value = value,
        image = ""
    })
end)