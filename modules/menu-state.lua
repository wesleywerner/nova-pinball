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

local thisState = {}
local state = nil

function thisState:load()

    -- Set up menu states
    state = statemanager:new()
    state:add("main", 60, "about")
    state:add("about")
    state:set("main")

end

function thisState:update (dt)
    state:update(dt)
end

function thisState:keypressed (key)
print("on menu state", state.current)
    if state:on("main") then
        if key == " " then
            print("playing!")
            mainstate:set("play")
        elseif key == "escape" then
            love.event.quit()
        end
    elseif state:on("about") then

    end
end

function thisState:keyreleased(key)

end

function thisState:draw ( )
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.printf ("main menu", 0, 100, scrWidth, "center")
    love.graphics.setColor(255, 255, 255, 128)
    love.graphics.printf ("press space", 0, 200, scrWidth, "center")
end

function thisState:resize (w, h)

end

return thisState
