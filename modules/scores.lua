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

-- A score tracking and display module

local scores = {}
-- The top scores
scores.high = {}
-- The newest earned score
scores.newScore = 0
-- The entered initials
scores.initials = ""
-- If the player is entering initials
scores.isTyping = false
-- The new score made it onto the list
scores.newScoreGood = false

function scores:load()
    -- TODO load scores from file
    self.scores = {
        {score=3000, initials="AAA", date="01/02/11"},
        {score=2000, initials="BBB", date="01/03/11"},
        {score=1000, initials="CCC", date="06/04/11"},
        }
end

function scores:register(score)
    self.latest = score
    self.initials = ""
    -- TODO check if the new score made it on the list
    self.newScoreGood = true
    self.isTyping = true
end

function scores:update(dt)

end

function scores:keypressed(key)
    -- Entering Initials
    if (self.isTyping) then
        if (key == "return" or key == "enter") then
            --addScore (nameInput)
            self.isTyping = false
        else
            if (self.initials:len() < 3 and string.find("0123456789abcdefghijklmnopqrstuvwxyz", key)) then
                self.initials = self.initials .. string.upper(key)
            elseif (key == "backspace") then
                self.initials = self.initials:sub(1, self.initials:len() - 1)
            end
        end
        return true
    end
    
    if (key == "escape") then
        return false
    end

    return true
end

function scores:draw()
    if (self.isTyping) then
        love.graphics.setColor (0, 255, 255, 255)
    else
        love.graphics.setColor (255, 255, 255, 255)
    end
    love.graphics.print("INITIALS: " .. self.initials, 100, 100)
end

return scores
