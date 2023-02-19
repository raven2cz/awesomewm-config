local broker = {}

if _DEVIL_VALS == nil then
    _DEVIL_VALS = {}
end
if _DEVIL_SIGNALS == nil then
    _DEVIL_SIGNALS = {}
end

--- Find a given signal
-- @tparam table obj The object to search in
-- @tparam string name The signal to find
-- @treturn table The signal table
local function find_signal(name)
    if not _DEVIL_SIGNALS[name] then
        assert(type(name) == "string", "name must be a string, got: " .. type(name))
        _DEVIL_SIGNALS[name] = {
            strong = {}
        }
    end
    return _DEVIL_SIGNALS[name]
end

--- Connect to a signal.
--
-- @tparam string name The name of the signal.
-- @tparam function func The callback to call when the signal is emitted.
-- @method connect_signal
-- @noreturn
function broker.connect_signal(name, func)
    assert(type(func) == "function", "callback must be a function, got: " .. type(func))
    local sig = find_signal(name)
    sig.strong[func] = true
    -- return historical last value
    local val = broker.get_value(name)
    if val then
        func(val)
    end
end

--- Disonnect from a signal.
-- @tparam string name The name of the signal.
-- @tparam function func The callback that should be disconnected.
-- @method disconnect_signal
-- @noreturn
function broker.disconnect_signal(name, func)
    local sig = find_signal(name)
    sig.strong[func] = nil
end

--- Emit a signal.
--
-- @tparam string name The name of the signal
-- @param val value argument for the callback functions. Each connected
--   function receives the object as first argument is given to emit_signal()
-- @method emit_signal
-- @noreturn
function broker.emit_signal(name, val)
    _DEVIL_VALS[name] = val
    local sig = find_signal(name)
    for func in pairs(sig.strong) do
        func(val)
    end
end

--- Provides historical last value for a signal.
-- @treturn object The signal value
function broker.get_value(name)
    return _DEVIL_VALS[name]
end

return broker
