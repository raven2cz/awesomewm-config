awesome-sharedtags
==================

A simple implementation for creating tags shared on multiple screens for
[awesome window manager](http://awesome.naquadah.org/).

This branch of the library is intended to work with *awesome* version 4 (for
all minor versions), but there are other branches with support for other
versions.

Features
--------

* Define a list of tags to be usable on all screens.
* Move tags with all clients between screens.
* Everything else should be just as usual.

Installation
------------

1. Clone or download a zip of the repository, and put the `sharedtags`
   directory somewhere where you can easily include it, for example in the same
   directory as your `rc.lua` file, generally located in `~/.config/awesome/`.
2. Modify your `rc.lua` file. A [patch](rc.lua.patch) against the default
   configuration is included in the repository for easy comparison, but keep
   reading for a textual description.
   1. Require the `sharedtags` library somewhere at the top of the file.
      ```lua
      local sharedtags = require("sharedtags")
      ```
   2. Create the tags using the `sharedtags()` method, instead of the original
      ones created with `awful.tag()`. They should be created at the file level,
      i.e. outside of any function.
      ```lua
      local tags = sharedtags({
          { name = "main", layout = awful.layout.layouts[2] },
          { name = "www", layout = awful.layout.layouts[10] },
          { name = "game", layout = awful.layout.layouts[1] },
          { name = "misc", layout = awful.layout.layouts[2] },
          { name = "chat", screen = 2, layout = awful.layout.layouts[2] },
          { layout = awful.layout.layouts[2] },
          { screen = 2, layout = awful.layout.layouts[2] }
      })
      ```
   3. Remove or uncomment the code which creates the tags when a screen is
      connected, in the `connect_for_each_screen` callback.
      ```lua
      awful.screen.connect_for_each_screen(function(s)
          -- Each screen has its own tag table.
          --awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

          -- Here is a good place to add tags to a newly connected screen, if desired:
          --sharedtags.viewonly(tags[4], s)
      end)
      ```
   4. The code for handling tags and clients needs to be changed to use the
      library and pick the correct tag.
      ```lua
      for i = 1, 9 do
          globalkeys = gears.table.join(globalkeys,
              -- View tag only.
              awful.key({ modkey }, "#" .. i + 9,
                        function ()
                              local screen = awful.screen.focused()
                              local tag = tags[i]
                              if tag then
                                 sharedtags.viewonly(tag, screen)
                              end
                        end,
                        {description = "view tag #"..i, group = "tag"}),
              -- Toggle tag display.
              awful.key({ modkey, "Control" }, "#" .. i + 9,
                        function ()
                            local screen = awful.screen.focused()
                            local tag = tags[i]
                            if tag then
                               sharedtags.viewtoggle(tag, screen)
                            end
                        end,
                        {description = "toggle tag #" .. i, group = "tag"}),
              -- Move client to tag.
              awful.key({ modkey, "Shift" }, "#" .. i + 9,
                        function ()
                            if client.focus then
                                local tag = tags[i]
                                if tag then
                                    client.focus:move_to_tag(tag)
                                end
                           end
                        end,
                        {description = "move focused client to tag #"..i, group = "tag"}),
              -- Toggle tag on focused client.
              awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                        function ()
                            if client.focus then
                                local tag = tags[i]
                                if tag then
                                    client.focus:toggle_tag(tag)
                                end
                            end
                        end,
                        {description = "toggle focused client on tag #" .. i, group = "tag"})
          )
      end
      ```
   5. Lastly, any rules referencing the screen and tag should use the newly
      created `tags` array instead.
      ```lua
      awful.rules.rules = {
          -- Set Firefox to always map on tag number 2.
          { rule = { class = "Firefox" },
            properties = { tag = tags[2] } }, -- or tags["www"] to map it to the name instead
      }
      ```
3. Restart or reload *awesome*.

Notes
-----

1. There is a bug in [awesome v4.0](https://github.com/awesomeWM/awesome/pull/1600)
   which can cause all tags to be deselected when moving a tag to another
   screen. The following patch can be used to fix the problem.
   ```diff
   diff --git a/lib/awful/tag.lua b/lib/awful/tag.lua
   index 66bd0c1..b481f42 100644
   --- a/lib/awful/tag.lua
   +++ b/lib/awful/tag.lua
   @@ -475,7 +475,7 @@ end
    function tag.object.set_screen(t, s)
    
        s = get_screen(s or ascreen.focused())
   -    local sel = tag.selected
   +    local sel = t.selected
        local old_screen = get_screen(tag.getproperty(t, "screen"))
    
        if s == old_screen then return end
   ```
   The file is located under `/usr/share/awesome/lib/awful/tag.lua` on my
   system.
2. Because of constraints in the X server, *awesome* does not allow
   toggling clients on tags allocated to other screens. Having a client on
   multiple tags and moving one of the tags will cause the client to move as well.
3. When selecting a tag on a different screen with `sharedtags.viewonly`, the tag is pulled to the current screen. To instead move focus to the other screen and view the tag there, use `sharedtags.jumpto(tag)`. This can be used with a seperate bind that calls `sharedtags.movetag(tag, screen)` to directly move a tag to another screen.

API
---

See [`doc/index.html`](doc/index.html) for API documentation.

Credits
-------

Idea originally from https://github.com/lammermann/awesome-configs, but I could
not get that implementation to work.
