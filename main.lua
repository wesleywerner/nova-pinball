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

statemanager = require ("modules.states")
playstate = require("modules.play-state")
menustate = require("modules.menu-state")

function love.load()

    math.randomseed(os.time())
    scrWidth, scrHeight = love.window.getDimensions()

    -- Set graphics
    love.graphics.setBackgroundColor(0, 0, 0)
    local font = love.graphics.newFont ("fonts/advanced_led_board-7.ttf", 37)
    love.graphics.setFont (font)

    -- Set up main states
    mainstate = statemanager:new()
    mainstate:add("splash", 2, "menu")
    mainstate:add("menu")
    mainstate:add("play")
    mainstate:set("menu")

    menustate:load()
    playstate:load()

end

function love.update (dt)
    mainstate:update(dt)
    if (mainstate:on("play")) then
        playstate:update(dt)
    elseif (mainstate:on("menu")) then
        menustate:update(dt)
    end
end

function love.keypressed (key, isrepeat)
    if (mainstate:on("play")) then
        playstate:keypressed(key)
    elseif (mainstate:on("menu")) then
        menustate:keypressed(key)
    end
end

function love.keyreleased(key)
    if (mainstate:on("play")) then
        playstate:keyreleased(key)
    elseif (mainstate:on("menu")) then
        menustate:keyreleased(key)
    end
end

function love.draw ( )
    if (mainstate:on("play")) then
        playstate:draw()
    elseif (mainstate:on("menu")) then
        menustate:draw()
    end
end

function love.resize (w, h)
    scrWidth, scrHeight = w, h
    playstate:resize(w, h)
end

-- A global function to draw better readable words
function printShadowText(text, y, color)
    -- Shadow
    love.graphics.setColor(0, 0, 0, 200)
    love.graphics.printf (text, 2, y+2, scrWidth, "center")
    -- Text
    love.graphics.setColor(unpack(color))
    love.graphics.printf (text, 0, y, scrWidth, "center")
end
