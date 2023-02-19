local wibox = require("wibox")
local createGadgetPie = require("fishlive.widget.dashboard.gadget.gadgetPie")
local createGadgetContainer = require("fishlive.widget.dashboard.gadget.gadgetContainer")

local signal = "signal::storage"
local content = {}
local container = {}

local function createDiskRow(disk)
    local _, short_mount = string.match(disk.mount, "(.-)([^\\/]-%.?([^%.\\/]*))$")
    if short_mount == "" then short_mount = disk.mount end
    local detailText = math.floor((disk.size - disk.used)/1024/1024) .. " GB free"

    return createGadgetPie(short_mount, disk.perc, detailText)
end

local function worker(args)
    local mounts = args

  container, content = createGadgetContainer("basic")

  awesome.connect_signal(signal, function(event)
          content:reset(content)
          for _,v in ipairs(mounts) do
      local disk = event.value[v]
      if disk then
        content:add(createDiskRow(event.value[v]))
          end
    end
  end)

    return container
end

return setmetatable(container, { __call = function(_, ...)
    return worker(...)
end })
