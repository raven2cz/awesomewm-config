local signal_watch = require("fishlive.signal.signal_watch")

local command = "amixer -D pulse sget Master"
local signal = "signal::volume"
local interval = 1

return signal_watch(command, interval, true, true, function(stdout, _, _, _)
    local mute = string.match(stdout, "%[(o%D%D?)%]")
    local volume = string.match(stdout, "(%d?%d?%d)%%")
    volume = tonumber(string.format("% 3d", volume))

    local icon = ""

    if mute == 'off' then
        icon = ""
    elseif volume > 50 then
        icon = ""
    elseif volume > 5 then 
        icon = ""
    else
        icon = ""
    end

    awesome.emit_signal(signal, {
        value = volume,
        image = icon
    })
end)