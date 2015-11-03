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
-- The index of the new score (if any)
scores.newScoreIndex = nil

function scores:load()
    -- TODO load scores from file
    self.scores = {
        {score=3000, initials="AAA", date="01/02/11"},
        {score=2999, initials="", date="03/11/15"},
        {score=2000, initials="BBB", date="01/03/11"},
        {score=1000, initials="CCC", date="06/04/11"},
        }
    scores.newScoreIndex = 2
end

function scores:register(score)
    self.newScoreIndex = nil
    -- Find the position of this score
    for i, entry in ipairs(self.scores) do
        if (score > entry.score) then
            local newEntry = {score=score, initials="", date="FOO"}
            table.insert(self.scores, i, newEntry)
            self.newScoreIndex = i
            break
        end
    end
    -- Or add to the end
    if (not self.newScoreIndex) then
        table.insert(self.scores, {score=score, initials="", date="FOO"})
        self.newScoreIndex = #self.scores
    end
    -- Cull the list
    while (#self.scores > 4) do
        table.remove(self.scores)
    end
    -- We did not make it after all :(
    if (self.newScoreIndex > #self.scores) then
        self.newScoreIndex = nil
    end
    
    self.initials = ""
    -- TODO check if the new score made it on the list
    if (self.newScoreIndex) then self.isTyping = true end
end

function scores:update(dt)

end

function scores:keypressed(key)
    -- Entering Initials
    if (self.isTyping) then
        if (key == "return" or key == "enter") then
            self.isTyping = false
            -- TODO save new score file
        else
            if (self.initials:len() < 3 and string.find("0123456789abcdefghijklmnopqrstuvwxyz", key)) then
                self.initials = self.initials .. string.upper(key)
            elseif (key == "backspace") then
                self.initials = self.initials:sub(1, self.initials:len() - 1)
            end
            self.scores[scores.newScoreIndex].initials = self.initials
        end
        return true
    end
    
    if (key == "escape" or key == " ") then
        return false
    end

    return true
end

function scores:draw()
    local y = 100
    for i, entry in ipairs(self.scores) do
        if (i == scores.newScoreIndex and self.isTyping) then
            love.graphics.setColor (0, 255, 255, 255)
        else
            love.graphics.setColor (255, 255, 255, 255)
        end
        love.graphics.print(entry.initials, 80, y)
        love.graphics.print(scores.formatNumber(entry.score), 200, y)
        love.graphics.print(entry.date, 500, y)
        y = y + 60
    end
end

function scores.formatNumber(number)
    local formatted = number
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k==0) then break end
    end
    return formatted
end

return scores
