--[[

     Fishlive Lua Library
     Layouts, widgets and utilities for Awesome WM

     Display Session section

     Licensed under GNU General Public License v2
      * (c) 2024, A.Fischer
--]]

local json = require("json")
local naughty = require("naughty")
local wrequire = require("fishlive.helpers").wrequire
local setmetatable = setmetatable

-- fishlive display_session submodule
local dsession = { _NAME = "fishlive.display_session" }

--- Parses the display session name to extract configuration details.
-- This function takes a session name string which can include several components
-- separated by underscores. It analyzes the session name to determine the type
-- of device (DESKTOP or LAPTOP), whether the internal display is used,
-- and the orientation of any connected displays.
-- It automatically removes the 'NOINTERNAL' token if present and adjusts
-- the configuration accordingly.
-- @param session_name The session configuration string, e.g., "LAPTOP_NOINTERNAL_LANDSCAPE_PORTRAIT".
-- @return A table containing the parsed configuration:
--         - device_type: Indicates the type of device ("DESKTOP" or "LAPTOP").
--         - internal_display: Boolean indicating whether the internal display is active (false by default).
--         - orientations: A table of strings indicating the orientation for each display.
function dsession.parse_display_session(session_name)
  local config = {
      is_multiple_monitors = false,
      device_type = nil,
      internal_display = false,
      orientations = {}
  }

  if string.find(session_name, "NOINTERNAL") then
      config.internal_display = false
      session_name = string.gsub(session_name, "_NOINTERNAL", "")
  end

  local tokens = {}
  for token in string.gmatch(session_name, "[^_]+") do
      table.insert(tokens, token)
  end

  -- device type (DESKTOP nebo LAPTOP)
  config.device_type = tokens[1]

  -- monitor orientation (includes INTERNAL)
  for i = 2, #tokens do
      table.insert(config.orientations, tokens[i])
  end

  -- set multiple monitors prop
  config.is_multiple_monitors = #config.orientations > 1

  return config
end

--- Reads display session configuration from a file.
-- This function reads the session configuration from a file, decodes the JSON,
-- and uses the configuration to set up the system.
function dsession.load_display_session()
  local file_path = os.getenv("HOME") .. "/.dsession"
  local file = io.open(file_path, "r")
  if file then
      local data = file:read("*all")
      file:close()

      local config = json.decode(data)
      if config and config.session_type then
          naughty.notify{
            title = 'Display Session Info',
            text = "Loaded display session type: " .. config.session_type}
          return dsession.parse_display_session(config.session_type)
      else
          naughty.notify{
            preset = naughty.config.presets.critical,
            title = 'Display Session Error',
            text = "No display session type found or JSON parsing error."}
      end
  else
      naughty.notify{
          preset = naughty.config.presets.critical,
          title = 'Display Session Error',
          text = "Failed to open display session configuration file."}
  end
end

-- initialize util

function dsession.initialize(args)
end

return setmetatable(dsession, { __index = wrequire, __call = function(_, ...) return dsession.initialize(...) end })
