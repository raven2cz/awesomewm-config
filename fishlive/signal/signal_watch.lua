---------------------------------------------------------------------------
--- Simplification of Timer for integration with signals.
--  Awesome component Watch missing some important features which are
--  necessary for signals.
--
-- @usage
-- return signal_watch(command, interval, autostart, call_now, function(stdout, stderr, exitreason, exitcode)
--     local value = tonumber(string.match(string.match(stdout, "%d+%%"), "%d+"))

--     awesome.emit_signal(signal, {
--         value = value,
--         image = iconImage
--     })
-- end)
--
-- @author Antonin Fischer (raven2cz)
-- @copyright 2023 MIT License
---------------------------------------------------------------------------

local setmetatable = setmetatable
local timer = require("gears.timer")
local spawn = require("awful.spawn")

local signal_watch = {
    mt = {}
}

--- Create signal watcher that send callback result to signal listeners
-- and updates it at a given time interval (timeout).
--
-- @tparam string|table command The shell command.
-- @tparam[opt=5] integer timeout The time interval at which the textbox
-- will be updated.
-- @tparam boolean args.autostart Automatically start the timer.
-- @tparam boolean args.call_now Call the callback at timer creation.
-- @tparam[opt] function callback The function that will be called after
-- the command output will be received. You can send it by signal processing.
-- Example:
--     awesome.emit_signal(signal, {
--        value = value,
--        icon = icon
--     })
-- @tparam string callback.stdout Output on stdout.
-- @tparam string callback.stderr Output on stderr.
-- @tparam string callback.exitreason Exit Reason.
-- The reason can be "exit" or "signal".
-- @tparam integer callback.exitcode Exit code.
-- For "exit" reason it's the exit code.
-- For "signal" reason — the signal causing process termination.
--
-- @return Its gears.timer.
-- @return sw SignalWatch data table
-- @constructorfct fishlive.signal.signal_watch
function signal_watch.new(command, timeout, autostart, call_now, callback)
    timeout = timeout or 5
    local sw = {}
    sw.command = command
    sw.timeout = timeout
    local t = timer {
        timeout = sw.timeout,
        autostart = autostart,
        call_now = call_now,
        callback = function()
            spawn.easy_async(sw.command, function(stdout, stderr, exitreason, exitcode)
                callback(stdout, stderr, exitreason, exitcode)
            end)
        end
    }
    return t, sw
end

function signal_watch.mt.__call(_, ...)
    return signal_watch.new(...)
end

return setmetatable(signal_watch, signal_watch.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
