local favourites = require("fishlive.widget.tasklist.favourites")

local function reverse_table(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end

return function()
    -- Get all clients
    local cls = client.get()

    -- Filter by an existing filter function and allowing only one client per class
    local result = {}
    local class_seen = {}
    for _, c in pairs(cls) do
        if c.class ~= nil and not class_seen[c.class] and not favourites[c.class:lower()] then
            class_seen[c.class] = true
            table.insert(result, c)
        end
    end

    return reverse_table(result)
end