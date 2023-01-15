local signal_watch = require("fishlive.signal.signal_watch")
local naughty = require("naughty")

local command = 'journalctl -n 15 --no-pager -u "systemd-*"'
local signal = "signal::terminal"
local interval = 5
local sig_terminal = {}

local function sendCmdResponse(stdout, _, _, _)
    awesome.emit_signal(signal, {
        value = stdout,
        image = ""
    })
end

local function createSignalWatch(cmd, inter)
  local t, sw_terminal = signal_watch(cmd, inter, true, true, sendCmdResponse)
  sig_terminal.t = t
  sig_terminal.sw = sw_terminal
end

createSignalWatch(command, interval)

awesome.connect_signal(signal.."::command", function(cmd)
    sig_terminal.sw.command = cmd.req
    local timeout
    if cmd.timeout then
        timeout = cmd.timeout
    else
        timeout = interval
    end
    if timeout ~= sig_terminal.sw.timeout then
      sig_terminal.t:stop()
      createSignalWatch(sig_terminal.sw.command, timeout)
    else
      sig_terminal.t:emit_signal("timeout")
    end
end)

return sig_terminal