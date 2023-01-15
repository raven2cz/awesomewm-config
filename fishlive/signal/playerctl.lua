-- Playerctl for Spotify Client only
-- If there are active more clients, the spotify is selected.
local awful = require("awful")
local signal_watch = require("fishlive.signal.signal_watch")

local Playerctl = require("lgi").Playerctl
local player = nil

local command = "playerctl -p spotify status"
local signal = "signal::playerctl"
local interval = 3

local art_script = [[
sh -c '
    tmp_dir="$XDG_CACHE_HOME/awesome/"

    if [ -z ${XDG_CACHE_HOME} ]; then
        tmp_dir="$HOME/.cache/awesome/"
    fi

    tmp_cover_path=${tmp_dir}"cover.png"

    if [ ! -d $tmp_dir  ]; then
        mkdir -p $tmp_dir
    fi

    link="$(playerctl -p spotify metadata mpris:artUrl)"
    link=${link/open.spotify.com/i.scdn.co}

    curl -s "$link" --output $tmp_cover_path && echo "$tmp_cover_path"
']]

-- https://open.spotify.com/image/
-- https://i.scdn.co/image/
local function update_metadata()
    local artist = ""
    local title = ""
    local status = ""

    if player:get_title() then
	    artist = player:get_artist()
        title = player:get_title()
        status = player.playback_status

        awful.spawn.easy_async_with_shell(art_script, function(out)
            -- Get album path
            local album_path = out:gsub('%\n', '')

            awesome.emit_signal(signal, {
                artist = artist,
                title = title,
                status = status,
                image = album_path
            })
        end)
    end
end

local function exit()
    awesome.emit_signal(signal, {
        artist = "",
        title = "",
        status = "STOPPED",
        image = ""
    })

    player = nil
end

awesome.connect_signal(signal.."::previous", function()
    player:previous()
end)

awesome.connect_signal(signal.."::next", function()
    player:next()
end)

awesome.connect_signal(signal.."::play_pause", function()
    player:play_pause()
    -- revert logic because the change is too fast!
    local status
    if player.playback_status:lower() == "playing" then
        status = "paused" else status = "playing" end
    awesome.emit_signal(signal.."::play_pause_result", status)
end)

return signal_watch(command, interval, true, true, function(stdout, _, _, _)
    local out = stdout:gsub('%\n', '')
    if out ~= "" and player == nil then
        local manager = Playerctl.PlayerManager()
        for _, id in ipairs(manager.player_names) do
            player = Playerctl.Player.new_from_name(id)
            if player.player_name == 'spotify' then
                manager:manage_player(player)
                break
            end
        end
        player.on_metadata = update_metadata
        player.on_exit = exit
        update_metadata()
    end
    awesome.emit_signal(signal.."::play_pause_result", out)
end)