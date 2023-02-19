local devil = "devil::cpu"
local signal = "signal::cpu"
local d = {}

local function sig(event)
    awesome.emit_signal(signal, event)
end

function d:start()
    awesome.connect_signal(devil, sig)
end

function d:stop()
    awesome.disconnect_signal(devil, sig)
end

return d
