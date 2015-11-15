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
   screen.box = cutter.cut(0.8, 0.5)
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
        screen.box.x, 
        screen.box.y, 
        screen.box.width, 
        screen.box.height)
    
    -- Box Outline
    love.graphics.setColor(200, 255, 200, 200)
    love.graphics.rectangle(
        "line",
        screen.box.x, 
        screen.box.y, 
        screen.box.width, 
        screen.box.height)
    
    -- Box Title
    printShadowText("PAUSED", 
        screen.box.center.y, 
        {200, 255, 200, 255})
end

screen:load()

return screen