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

-- Manages bumpers.
-- Tracks bumper states when hit to draw at varying scales.
-- Add bumpers with :add(tag)
-- Update their status with :update(dt)
-- Call :hit(tag) when hit.

local manager = { }
manager.bumpers = { }

local function loadSprite (path)
    -- Store sprites as
    --      sprite.image    
    --      sprite.size     (width, height)
    --      sprite.ox       draw offset x
    --      sprite.oy       draw offset y
    local sprite = { }
    sprite.image = love.graphics.newImage (path)
    sprite.size = { sprite.image:getDimensions () }
    sprite.ox = sprite.size[1] / 2
    sprite.oy = sprite.size[2] / 2
    sprite.hitCooldown = 0
    return sprite
end

function manager:add(tag, image)
    self.bumpers[tag] = loadSprite(image)
end

function manager:draw(tag, x, y)
    local bumper = self.bumpers[tag]
    if (bumper) then
        local scale = 1
        if (bumper.hitCooldown > 0) then scale = 1.1 end     -- draw larger after a hit
        love.graphics.draw(bumper.image, x, y, 0, scale, scale, bumper.ox, bumper.oy)
    end
end

function manager:hit(tag)
    local bumper = self.bumpers[tag]
    if (bumper) then
        bumper.hitCooldown = 0.1
    end
end

function manager:update(dt)
    for _, v in pairs(self.bumpers) do
        if (v.hitCooldown > 0) then
            v.hitCooldown = v.hitCooldown - dt
        end
    end
end
        
return manager
