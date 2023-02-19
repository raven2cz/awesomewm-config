local wibox = require("wibox")

local function createGadgetContainer(args)
    local content = wibox.layout.fixed.horizontal()
    content.spacing = 36

    local container = wibox.widget {
      content,
      spacing = 24,
      layout = wibox.layout.fixed.horizontal
    }

    container.addToCnt = function(idx, widget)
      content:remove(idx)
      content:insert(idx, widget)
    end

    return container, content
end

return createGadgetContainer
