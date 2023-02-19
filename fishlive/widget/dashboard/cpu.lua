local broker = require("fishlive.signal.broker")
local createGadgetPie = require("fishlive.widget.dashboard.gadget.gadgetPie")
local createGadgetContainer = require("fishlive.widget.dashboard.gadget.gadgetContainer")

local ctr = {}

local function createCpu(cpu)
  return createGadgetPie("CPU %", cpu.usage, "cpu "..cpu.usage.."%")
end
local function createCpuTemp(cputemp)
  return createGadgetPie("CPU ", cputemp, "cpu "..cputemp.."˚C")
end
local function createGpuTemp(gputemp)
  return createGadgetPie("GPU ", gputemp, "gpu "..gputemp.."˚C")
end

local brokerListrs = {}
brokerListrs["broker::cpu"] = function(e) ctr.addToCnt(1, createCpu(e.value)) end
brokerListrs["broker::cputemp"] = function(e) ctr.addToCnt(2, createCpuTemp(e.value)) end
brokerListrs["broker::gputemp"] = function(e) ctr.addToCnt(3, createGpuTemp(e.value)) end

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
