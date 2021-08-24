
--+ allows automatically focusing back to the previous client
--> on window close (unmanage) or minimize.

local awful = require("awful")
local get_client_info = require("machina.methods").get_client_info

-------------------------------------------------------------------> methods ;

function backham(c)
    local s = awful.screen.focused()
    local back_to = awful.client.focus.history.get(s, 0)
    local active_region = get_client_info(c).active_region

    if not (active_region and client.floating) and back_to then
        client.focus = back_to
        back_to:raise()
    end
end

--------------------------------------------------------------------> signal ;

client.connect_signal("property::minimized", backham)
--+ attach to minimized state

client.connect_signal("unmanage", backham)
--+ attach to closed state

