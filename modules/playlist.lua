-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- any later version.
   
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
   
-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see http://www.gnu.org/licenses/.

-----------------------------------------------------------------------

-- Written by Wesley "keyboard monkey" Werner 2015
-- https://github.com/wesleywerner/

-- This music playlist controls song looping, volume and queuing.

local playlist = {}

playlist.turnedOn = false

playlist.trackIndex = 1

playlist.source = nil

playlist.playedCount = 0

playlist.tracks = {
    {
        file="music/nexus_x.it",
        credit="Nexus, by Xaser",
        url="http://modarchive.org/index.php?request=view_by_moduleid&query=50384",
        loop=2,
        volume=0.6,
    },
    {
        file="music/nosotr_x.it",
        credit="Nosotros, by Xaser",
        url="http://modarchive.org/index.php?request=view_by_moduleid&query=51677",
        loop=2,
        volume=0.6,
    },
    {
        file="music/tarvoi_x.it",
        credit="Void of Space, by Xaser",
        url="http://modarchive.org/index.php?request=view_by_moduleid&query=160395",
        loop=4,
        volume=0.6,
    },
    {
        file="music/voxel_x.it",
        credit="voxelbuffer, by Xaser",
        url="http://modarchive.org/index.php?request=view_by_moduleid&query=162116",
        loop=2,
        volume=0.6,
    },
    {
        file="music/zeroph_x.it",
        credit="Zerophine, by Xaser",
        url="http://modarchive.org/index.php?request=view_by_moduleid&query=160368",
        loop=2,
        volume=0.6,
    },
}

function playlist:load()

end

function playlist:play()
    playlist.turnedOn = true
end

function playlist:pauseUnpause()
    if (playlist.turnedOn and playlist.source) then
        if (playlist.source:isPaused()) then
            playlist.source:resume()
        else
            playlist.source:pause()
        end
    end
end

function playlist:stop()
    playlist.turnedOn = false
    if (playlist.source) then
        love.audio.stop(playlist.source)
        playlist.source = nil
    end
end

function playlist:update(dt)
    if (playlist.turnedOn) then
        -- next track
        if (not playlist.source) then
            local track = playlist.tracks[playlist.trackIndex]
            -- Loop the same track or skip to the next track
            playlist.playedCount = playlist.playedCount + 1
            if (playlist.playedCount > track.loop) then
                playlist.playedCount = 1
                playlist.trackIndex = playlist.trackIndex + 1
                if (playlist.trackIndex > #playlist.tracks) then playlist.trackIndex = 1 end
            end
            local track = playlist.tracks[playlist.trackIndex]
            playlist.source = love.audio.newSource(track.file, "stream")
            playlist.source:setVolume(track.volume)
            love.audio.play(playlist.source)
        else
        -- Track is finished playing
            if (playlist.source:isStopped()) then
                playlist.source = nil
            end
        end
    end
end

return playlist
