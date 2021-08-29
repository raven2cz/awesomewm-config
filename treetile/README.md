Treetile
========

*Codes work with git version of awesome and sould work with stable version too (e.g. 3.5.9 currently).  Let me know if they fail.* 

Treetile is binary tree-based, dynamical tiling layout for Awesome 3.5 and
latter.  Similarly to tmux or i3wm, if a new client/window is created, 
the screen area occupied by the previous focused client (progenitor) will be
split vertically or horizontally and shared equally by the new and the previous
focused client (descendants).  Each time the spilt can either be specified or depends on
which side (width or height) of the screen area of the previous focused client (progenitor)
is longer. If you want, you can also manually resize these two descendants with
respect to each other by the keyboad or mouse, but only in the frame of screen area occupied by the
progenitor (which can be improved in the future).  

This project is forked from (https://github.com/RobSis/treesome) and still under the development.
Comments and feedbacks are welcome.


Installation
---

1. Clone repository to your awesome directory

    ```
    git clone http://github.com/guotsuan/treetile.git ~/.config/awesome/treetile
    ```

2. Add this line to your rc.lua below other require calls.

    ```lua
    local treetile = require("treetile")`
    ```

3. And finally add the layout `treetile` to your layout table.
    ```lua
    local layouts = {
        ...
        treetile
    }
    ```
4. ##### Important Option:
    if you set the in your `rc.lua` to let the new created client gain the focus, 
    for example: 
    ```lua
    ...
        { rule = { },
          properties = { focus = awful.client.focus.filter, 
             -- or focus = true,

    ...
    ```

    then you should set the following option to make sure treetile works correctly 
    ```lua
    treetile.focusnew = true  
    ```
    If no extra settings about focus are added in your rc.lua, please set 
    ```lua
    treetile.focusnew = false
    ```
5. Restart and you're done. 


Configuration
----

1. The following option controls the new client apprear on the left or the right side
    of current client: 
    ```lua
    treetile.direction = "right" -- or "left"
    ```

2. By default, direction of split is decided based on the dimensions of the last focused
   client. If you want you to force the direction of the split, bind keys to
   `treetile.vertical` and `treetile.horizontal` functions. For example:
    ```lua
    awful.key({ modkey }, "v", treetile.vertical),
    awful.key({ modkey }, "h", treetile.horizontal)
    ```

3. Set the keyboad shortcut for resizing the descendant clients
   ` treetile.resize_client(inc) `. The value of inc can be from 0.01 to 0.99,
   negative or postive, for example:
    ```lua
    ...
    awful.key({ modkey, "Shift"   }, "h", function ()
            local c = client.focus
            if awful.layout.get(c.screen).name ~= "treetile" then
                awful.client.moveresize(-20,0,0,0) 
            else
                treetile.resize_client(-0.1) 
                -- increase or decrease by percentage of current width or height, 
                -- the value can be from 0.01 to 0.99, negative or postive
            end 
            end),   
    awful.key({ modkey, "Shift"   }, "l", function () 
            local c = client.focus
            if awful.layout.get(c.screen).name ~= "treetile" then
                awful.client.moveresize(20,0,0,0) 
            else
                treetile.resize_client(0.1)
            end 
            end),
    ...
    ```

Screenshots
-----------

![screenshot](./screenshot.png)

TODO
----------
1. The resizing of clients can be improved


Licence
-------

[GPL 2.0](http://www.gnu.org/licenses/gpl-2.0.html)
