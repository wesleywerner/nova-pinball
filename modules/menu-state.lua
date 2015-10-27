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
local menuOptions = {"Play", "About", "Leave"}
local selectedItem = 1

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
    if state:on("main") then
        if key == "up" then
            selectedItem = selectedItem - 1
            if (selectedItem < 1) then selectedItem = #menuOptions end
        elseif key == "down" then
            selectedItem = selectedItem + 1
            if (selectedItem > #menuOptions) then selectedItem = 1 end
        elseif key == "return" or key == "enter" or key == " " then
            self:menuAction()
        end
    elseif state:on("about") then
        state:set("main")
    end
end

function thisState:keyreleased(key)
    if (playstate:gameInProgress()) then
        menuOptions[1] = "Continue"
    else
        menuOptions[1] = "Play"
    end
end

function thisState:draw ( )
    love.graphics.setBackgroundColor(32, 32, 64)
    if state:on("main") then
        local y = 100
        local color
        for _, m in ipairs(menuOptions) do
            if (menuOptions[selectedItem] == m) then
                color = {200, 200, 255, 255}
            else
                color = {255, 255, 255, 128}
            end
            printShadowText(m, y, color)
            y = y + 100
        end
    elseif state:on("about") then
        love.graphics.setColor(128, 255, 255, 255)
        love.graphics.printf ("about", 0, 300, scrWidth, "center")
    end
end

function thisState:resize (w, h)

end

function thisState:menuAction()
    local item = menuOptions[selectedItem]
    if (item == "Play" or item == "Continue") then
        mainstate:set("play")
    elseif (item == "About") then
        state:set("about")
    elseif (item == "Leave") then
        love.event.quit()
    end
end

return thisState
