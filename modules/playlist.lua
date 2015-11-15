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

playlist.tracks = {}

function playlist:load()
    self:refreshTracks()
end

function playlist:refreshTracks()
    playlist.tracks = {}
    local files = love.filesystem.getDirectoryItems("music")
    for i, file in pairs(files) do
        -- skip nfo files at this time
        if not string.find(file, ".nfo$") then
            self:addTrack("music", file)
        end
    end
end

-- Add a track and read an optional nfo file.
-- nfo format:
--      first line is the title
--      extra lines go into the track.nfo value
--      optional "loop=n" line is applied to track.loop
--      optional "volume=n" line is applied to track.volume
function playlist:addTrack(path, filename)
    local track = {file=path .. "/" .. filename, volume=1, nfo=filename, loop=1}
    local nfopath = path .. "/" .. filename .. ".nfo"
    local infoExists = love.filesystem.exists(nfopath)
    
    if infoExists then
        
        -- read the nfo file.
        -- first line is track title
        local hasTitle = false
        
        for line in love.filesystem.lines(nfopath) do
            
            -- check for loop setting lines
            local loopI, loopJ = string.find(line, "^loop=")
            local volumeI, volumeJ = string.find(line, "^volume=")
            
            if loopI then
                track.loop = tonumber( line:sub(loopJ+1, string.len(line)) )
            elseif volumeI then
                track.volume = tonumber( line:sub(volumeJ+1, string.len(line)) )
            else
                
                if hasTitle then
                    track.nfo = track.nfo .. line .. "\n"
                else
                    track.title = line
                    track.nfo = ""
                    hasTitle = true
                end
                
            end     -- else loopI
        end
    end
    table.insert(playlist.tracks, track)
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
