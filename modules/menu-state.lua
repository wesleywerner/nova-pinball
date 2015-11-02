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
local currentOptions = {}
local mainOptions = {"Play", "Settings", "About", "Leave"}
local configOptions = {}
local selectedItem = 1

function thisState:load()

    -- Set up menu states
    state = statemanager:new()
    state:add("main", 60, "about")
    state:add("config")
    state:add("about")
    state:set("main")
    currentOptions = mainOptions

end

function thisState:update (dt)
    state:update(dt)
end

function thisState:keypressed (key)
    -- Menu navigation
    if key == "up" then
        selectedItem = selectedItem - 1
        if (selectedItem < 1) then selectedItem = #currentOptions end
    elseif key == "down" then
        selectedItem = selectedItem + 1
        if (selectedItem > #currentOptions) then selectedItem = 1 end
    elseif key == "return" or key == "enter" or key == " " then
        self:menuAction()
    elseif key == "escape" then
        if state:on("main") then
            -- Selects the last menu option
            selectedItem = #currentOptions
        else
            -- Save config
            if state:on("config") then gameconfig:save() end
            -- Escape to the main menu
            state:set("main")
            currentOptions = mainOptions
            self:resetSelection()
        end
    end
end

function thisState:keyreleased(key)
    if (playstate:gameInProgress()) then
        mainOptions[1] = "Continue"
    else
        mainOptions[1] = "Play"
    end
end

function thisState:drawOptionsMenu()
   local y = 100
    local color
    for _, m in ipairs(currentOptions) do
        if (currentOptions[selectedItem] == m) then
            color = {200, 200, 255, 255}
        else
            color = {255, 255, 255, 128}
        end
        printShadowText(m, y, color)
        y = y + 100
    end
end

function thisState:draw ( )
    love.graphics.setBackgroundColor(32, 32, 64)
    if state:on("main") then
        self:drawOptionsMenu()
    elseif state:on("config") then
        self:drawOptionsMenu()
    elseif state:on("about") then
        love.graphics.setColor(128, 255, 255, 255)
        love.graphics.printf ("about", 0, 300, scrWidth, "center")
    end
end

function thisState:resize (w, h)

end

function thisState:resetSelection()
    selectedItem = 1
end

function thisState:menuAction()
    local item = currentOptions[selectedItem]

    -- Main
    if (item == "Play" or item == "Continue") then
        mainstate:set("play")
    elseif (item == "Settings") then
        state:set("config")
        self:buildConfigMenu()
        self:resetSelection()
        return
    elseif (item == "About") then
        state:set("about")
    elseif (item == "Leave") then
        love.event.quit()
    end

    -- Config
    if state:on("config") then
        if (selectedItem == 1) then
            gameconfig.values.cameraFollowsBall = not gameconfig.values.cameraFollowsBall
            self:buildConfigMenu()
        elseif (selectedItem == 2) then
            gameconfig.values.flashingTargets = not gameconfig.values.flashingTargets
            self:buildConfigMenu()
        elseif (selectedItem == 3) then
            gameconfig.values.fullscreen = not gameconfig.values.fullscreen
            self:buildConfigMenu()
        end
    end
end

function thisState:buildConfigMenu()
    local cameraValue = "Follow Ball"
    if (not gameconfig.values.cameraFollowsBall) then cameraValue = "Zoomed Out" end
    local flashValue = "On"
    if (not gameconfig.values.flashingTargets) then flashValue = "Off" end
    local fullscreenValue = "Full"
    if (not gameconfig.values.fullscreen) then fullscreenValue = "Window" end
    currentOptions = {}
    currentOptions = {
        [1]="Camera: " .. cameraValue,
        [2]="Target Lights: " .. flashValue,
        [3]="Screen: " .. fullscreenValue
        }
end

return thisState
