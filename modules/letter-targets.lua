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

-- Manages stationary targets.
-- Call switchOn(letter) to toggle a letter.
-- Hook into the onSwitch(letter) callback to get notifications.
-- Hook into onComplete() to get notified when the entire word is on.
-- The letters reset when the word completes.

local targets = { }
targets.letters = nil

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
    return sprite
end

function targets:new()
    local function deepcopy(orig)
        local orig_type = type(orig)
        local copy
        if orig_type == 'table' then
            copy = {}
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key)] = deepcopy(orig_value)
            end
            setmetatable(copy, deepcopy(getmetatable(orig)))
        else -- number, string, boolean, etc
            copy = orig
        end
        return copy
    end
    
    local t = deepcopy(self)
    t.letters = {}
    return t
end

function targets:add(letter, x, y, offImage, onImage)
    if (not self.letters) then
        print("cannot add letters to the module. use :new() and use the returned object instead.")
        return
    end
    t = { }
    t.x, t.y = x, y
    t.offImage = loadSprite(offImage)
    t.onImage = loadSprite(onImage)
    self.letters[letter] = t
end

function targets:draw()
    for _, v in pairs(self.letters) do
        local i = v.on and v.onImage or v.offImage
        love.graphics.draw(i.image, v.x, v.y, 0, 1, 1, i.ox, i.oy)
    end
end

function targets:switchOn(letter)
    if (self.letters[letter]) then
        if (not self.letters[letter].on) then
            self.letters[letter].on = true
            self.onSwitch(letter)
            self:testStatus()
        end
    end
end

function targets:testStatus()
    for _, v in pairs(self.letters) do
        if (not v.on) then return false end
    end
    self.onComplete()
    self:reset()
end

function targets.onSwitch(letter)

end

function targets.onComplete()

end

function targets:reset()
    for _, v in pairs(self.letters) do
        v.on = false
    end
end
        
return targets
