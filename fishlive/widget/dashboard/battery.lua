local beautiful = require("beautiful")
local drawIconProgress = require("fishlive.widget.dashboard.drawIconProgress")

return function()
    return drawIconProgress("signal::battery", beautiful.base08, beautiful.base01)
end