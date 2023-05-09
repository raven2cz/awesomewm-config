local broker = require("fishlive.signal.broker")
local createGadgetPie = require("fishlive.widget.dashboard.gadget.gadgetPie")
local createGadgetContainer = require("fishlive.widget.dashboard.gadget.gadgetContainer")

local ctr = {}

local function createMem(mem)
  return createGadgetPie("MEM %", mem.used, mem.used.."MB", mem.total)
end
local function createNetSent(net)
  return createGadgetPie("NET 󰜷", string.format("%1.1f", net.sent), string.format("%1.1f", net.sent), 1000)
end
local function createNetReceived(net)
  return createGadgetPie("NET 󰜮", string.format("%1.1f", net.received), string.format("%1.1f", net.received), 1000)
end

local brokerListrs = {}
brokerListrs["broker::mem"] = function(e) ctr.addToCnt(1, createMem(e.value)) end
brokerListrs["broker::net"] = function(e)
  ctr.addToCnt(2, createNetSent(e.value))
  ctr.addToCnt(3, createNetReceived(e.value))
end

local function worker(args)
  ctr = createGadgetContainer("basic")

  awesome.connect_signal("dashboard::open", function()
    for signal, func in pairs(brokerListrs) do
      broker.connect_signal(signal, func)
    end
  end)
  awesome.connect_signal("dashboard::close", function()
    for signal, func in pairs(brokerListrs) do
      broker.disconnect_signal(signal, func)
    end
  end)

  return ctr
end

return setmetatable(ctr, { __call = function(_, ...)
    return worker(...)
end })
