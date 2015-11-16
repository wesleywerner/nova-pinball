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

local screen = {}

function screen:load()
   local cutter = require("modules.cutter") 
   screen.pauseBox = cutter.cut(0.9, 0.5)
   screen.titleBox = cutter.cut(1, 0.1, "top", screen.pauseBox)
   screen.trackBox = cutter.cut(0.9, 0.5, "center", screen.pauseBox)
   local W, H = love.graphics.getDimensions()
   screen.width = W
   screen.height = H
end

function screen:update(dt)
    
end

function screen:draw()
    
    -- Full screen overlay
    love.graphics.setColor(0, 0, 0, 200)
    love.graphics.rectangle(
        "fill", 0 , 0, 
        screen.width, 
        screen.height)
    
    -- Box Fill
    love.graphics.setColor(0, 0, 0, 200)
    love.graphics.rectangle(
        "fill",
        screen.pauseBox.x, 
        screen.pauseBox.y, 
        screen.pauseBox.width, 
        screen.pauseBox.height)
    
    -- Box Outline
    love.graphics.setColor(200, 255, 200, 200)
    love.graphics.rectangle(
        "line",
        screen.pauseBox.x, 
        screen.pauseBox.y, 
        screen.pauseBox.width, 
        screen.pauseBox.height)
    
    -- Box Title
    printShadowText("PAUSED", 
        screen.titleBox.center.y,
        {200, 255, 200, 255})
    
    -- Now Playing
    local track = playlist:nowplaying()
    if track then
        local title = string.format("Now Playing:\n\n#%s. %q by %s\n\n%s", 
                        playlist.trackIndex, track.title, track.artist, track.nfo)
        love.graphics.setFont(smallFont)
        love.graphics.setColor(255, 255, 200, 255)
        love.graphics.printf (title, 
            screen.trackBox.x, 
            screen.trackBox.y, 
            screen.trackBox.width, 
            "left")

        love.graphics.setColor(255, 255, 255, 100)
        love.graphics.print("Arrows - Skip + Volume",
            screen.trackBox.x,
            screen.trackBox.y + screen.trackBox.height)

    end
    
end

function screen:keypressed(key)
    if key == "left" then
        playlist:prevTrack()
    elseif key == "right" then
        playlist:nextTrack()
    end
end

screen:load()

return screen