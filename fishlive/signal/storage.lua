local signal_watch = require("fishlive.signal.signal_watch")

local command = [[bash -c "df | tail -n +2"]]
local signal = "signal::storage"
local interval = 60
local disks = {}

return signal_watch(command, interval, true, true, function(stdout, _, _, _)
    for line in stdout:gmatch("[^\r\n$]+") do
        local filesystem, size, used, avail, perc, mount =
          line:match('([%p%w]+)%s+([%d%w]+)%s+([%d%w]+)%s+([%d%w]+)%s+([%d]+)%%%s+([%p%w]+)')

        disks[mount]            = {}
        disks[mount].filesystem = filesystem
        disks[mount].size       = size
        disks[mount].used       = used
        disks[mount].avail      = avail
        disks[mount].perc       = perc
        disks[mount].mount      = mount
    end

    awesome.emit_signal(signal, {
        value = disks
    })
end)
