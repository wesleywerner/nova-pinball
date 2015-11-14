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

local pausedScreen = {}

function pausedScreen:update(dt)
    
end

function pausedScreen:draw()
    -- Full screen overlay
    love.graphics.setColor(0, 0, 0, 200)
    love.graphics.rectangle("fill", 0 , 0, 
        pausedScreen.screenWidth, pausedScreen.screenHeight)
    -- Box Fill
    love.graphics.setColor(0, 0, 0, 200)
    love.graphics.rectangle("fill",
        pausedScreen.x, pausedScreen.y, 
        pausedScreen.width, pausedScreen.height)
    -- Box Outline
    love.graphics.setColor(200, 255, 200, 200)
    love.graphics.rectangle("line",
        pausedScreen.x, pausedScreen.y, 
        pausedScreen.width, pausedScreen.height)
    -- Box Title
    --love.graphics.setColor(200, 255, 200, 255)
    printShadowText("PAUSED", 
        pausedScreen.center, 
        {200, 255, 200, 255})
end

function pausedScreen.reposition()
   local width, height = love.graphics.getDimensions()
   pausedScreen.screenWidth = width
   pausedScreen.screenHeight = height
   pausedScreen.width = width * 0.8
   pausedScreen.height = height * 0.5
   pausedScreen.x = (width - pausedScreen.width) / 2
   pausedScreen.y = (height - pausedScreen.height) / 2
   pausedScreen.center = pausedScreen.y + (pausedScreen.height / 2)
end

return pausedScreen