local signal_watch = require("fishlive.signal.signal_watch")

local command = "fortune"
local signal = "signal::news"
local interval = 60

return signal_watch(command, interval, true, true, function(stdout, _, _, _)
    awesome.emit_signal(signal, {
        value = stdout,
        image = ""
    })
end)