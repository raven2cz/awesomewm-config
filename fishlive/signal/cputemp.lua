local devil = "devil::cputemp"
local signal = "signal::cputemp"
local d = {}
local event
local send = false

awesome.connect_signal(devil, function(e)
    event = e
    if send then
        awesome.emit_signal(signal, event)
    end
end)

function d:start()
    send = true
    if event then
        awesome.emit_signal(signal, event)
    end
end

function d:stop()
    send = false
end

return d
