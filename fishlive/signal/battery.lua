local signal_watch = require("fishlive.signal.signal_watch")
local naughty = require("naughty")

local command = "acpi -i"
local signal = "signal::battery"
local interval = 3


local last_battery_check = os.time()
return signal_watch(command, interval, true, true, function(stdout, _, _, _)
    local battery_info = {}
    local capacities = {}
    local charging = false

    for s in stdout:gmatch("[^\r\n]+") do
        local status, charge_str,_ = string.match(s, '.+: (%a+), (%d?%d?%d)%%,?(.*)')

        if status == "Charging" then charging = true end

        if status ~= nil then
            table.insert(battery_info, { status = status, charge = tonumber(charge_str) })
        else
            local cap_str = string.match(s, '.+:.+last full capacity (%d+)')
            table.insert(capacities, tonumber(cap_str))
        end
    end

    local capacity = 0
    for _, cap in ipairs(capacities) do
        capacity = capacity + cap
    end

    local charge = 0
    local count = 0
    for _, batt in ipairs(battery_info) do
        if batt.charge == 0 then
            -- Skip this battery
            goto continue
        end
        charge = charge + batt.charge
        count = count + 1
        :: continue ::
    end

    charge = math.floor(charge / count)

    local icon
    if charging then
        icon = ""
    elseif (charge >= 0 and charge < 10) then
        icon = ""
        -- if 5 minutes have elapsed since the last warning
        if os.difftime(os.time(), last_battery_check) > 300 and charge < 3 and charge > 0 then
            last_battery_check = os.time()
            naughty.notify{ text = "Battery Warning! Status is "..charge.."%" }
        end
    elseif (charge < 20) then
        icon = ""
    elseif charge < 30 then
        icon = ""
    elseif charge < 40 then
        icon = ""
    elseif charge < 50 then
        icon = ""
    elseif charge < 60 then
        icon = ""
    elseif charge < 70 then
        icon = ""
    elseif charge < 80 then
        icon = ""
    elseif charge < 90 then
        icon = ""
    elseif charge < 100 then
        icon = ""
    else
        icon = ""
    end

    awesome.emit_signal(signal, {
        value = charge,
        image = icon
    })
end)
