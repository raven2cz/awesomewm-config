local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

--- Creates a music info box with album art, artist, and title.
-- @param data Table containing 'image' (path to album art), 'artist', and 'title'.
-- If 'data' is nil or missing elements, defaults are used.
-- @return The music info box ('wibox') object.
local function createMusicBox(data)
  -- Default data if none provided
  if data == nil then
    data = {
      image = beautiful.nocover_icon, -- Default album cover image
      artist = "NOT PRESENT",
      title = "NOT PRESENT",
      album = "NOT PRESENT",
    }
  end

  local img_source = data.image or beautiful.nocover_icon
  local artist = data.artist
  local title = data.title
  local album = data.album

  -- Space for the bar containing the close button
  local bar_space_height = 80

  -- Default position
  local x = 1024
  local y = 768

  -- Background color of the music box
  local bg_color = "#000000d0"

  -- Load the image to get its dimensions
  local img = gears.surface(img_source)
  local img_width, img_height = img:get_width(), img:get_height()

  -- Create the music box wibox
  local musicbox = wibox({
    width = img_width,
    height = img_height + bar_space_height, -- Height includes space for artist/title text
    ontop = true,
    visible = true,
    bg = bg_color,
  })

  musicbox.x = x
  musicbox.y = y

  -- Add mouse button functionality for moving and resizing
  musicbox:connect_signal("button::press", function(c, _, _, button, _, geo)
    if button == 1 then -- Left click to move
      awful.mouse.client.move(c)
    end
    if button == 3 then -- Right click to resize
      awful.mouse.client.resize(c, geo)
    end
  end)

  -- Set up the layout of the music box
  musicbox:setup {
    layout = wibox.layout.fixed.vertical,
    {
      -- Top bar for the close button
      layout = wibox.layout.align.horizontal,
      nil,
      nil,
      {
        widget = wibox.widget.textbox,
        text = " X ", -- Close button
        align = "center",
        valign = "center",
        buttons = gears.table.join(
          awful.button({}, 1, function()
            musicbox.visible = false -- Hide the music box
            musicbox = nil           -- Allow garbage collection
          end)
        ),
      },
    },
    {
      -- Album art
      widget = wibox.widget.imagebox,
      image = img_source,
      resize = true,
    },
    {
      -- Artist, title and album information
      layout = wibox.layout.fixed.vertical,
      {
        widget = wibox.widget.textbox,
        text = "Artist: " .. artist,
        align = "left",
      },
      {
        widget = wibox.widget.textbox,
        text = "Title: " .. title,
        align = "left",
      },
      {
        widget = wibox.widget.textbox,
        text = "Album: " .. album,
        align = "left",
      },
    },
  }

  return musicbox
end

return createMusicBox
