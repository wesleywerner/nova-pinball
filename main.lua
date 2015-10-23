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

local states = require ("modules.states")
local pinball = require ("nova-pinball-engine")
local targetManager = require("modules.letter-targets")
local bumperManager = require("modules.bumpers")
local sprites = { }

function loadFromFile ( )
    local binser = require("modules.binser")
    local mydata, size = love.filesystem.read("nova.pinball", nil)
    local tableDefinition = binser.deserialize(mydata)
    pinball:loadTable(tableDefinition)
end

function love.load()

    math.randomseed(os.time())
    scrWidth, scrHeight = love.window.getDimensions()

    -- Load sprites
    sprites.background = loadSprite ("images/background.png")
    sprites.ball = loadSprite ("images/ball.png")
    sprites.leftflipper = loadSprite ("images/leftflip.png")
    sprites.blackhole = loadSprite("images/black-hole.png")
    sprites.wheel = loadSprite("images/nova-wheel.png")
    sprites.wheel.angle = 0
    sprites.rays = loadSprite("images/nova-rays.png")
    sprites.rays.angle = 0

    -- Set graphics
    love.graphics.setBackgroundColor(0, 0, 0)
    local font = love.graphics.newFont (40)
    love.graphics.setFont (font)

    -- Set initial game state
    states:new (states.launch)

    -- Load the table layout into the pinball engine
    loadFromFile()

    -- The black hole position where the light rays and spiral revolve around.
    local x, y = pinball:getObjectXY("hole")
    sprites.blackhole.x = x
    sprites.blackhole.y = y

    -- Set up the bumper manager
    bumperManager:add("bumper1", "images/bumper.png")
    bumperManager:add("bumper2", "images/bumper.png")
    bumperManager:add("bumper3", "images/bumper.png")

    -- Set up the "NOVA" word target
    novaTarget = targetManager:new()
    novaTarget.onComplete = onNovaTargetComplete
    novaTarget.onSwitch = onNovaTargetSwitch
    local x, y = pinball:getObjectXY("n")
    novaTarget:add("n", x, y, "images/spot-off.png", "images/n-on.png")
    local x, y = pinball:getObjectXY("o")
    novaTarget:add("o", x, y, "images/spot-off.png", "images/o-on.png")
    local x, y = pinball:getObjectXY("v")
    novaTarget:add("v", x, y, "images/spot-off.png", "images/v-on.png")
    local x, y = pinball:getObjectXY("a")
    novaTarget:add("a", x, y, "images/spot-off.png", "images/a-on.png")

    -- Set up the dot targets
    dotTarget = targetManager:new()
    dotTarget.onComplete = onDotTargetComplete
    dotTarget.onSwitch = onDotTargetSwitch
    dotTarget:add("dot1", 85, 245, "images/dot-off.png", "images/dot-on.png")
    dotTarget:add("dot2", 85, 295, "images/dot-off.png", "images/dot-on.png")
    dotTarget:add("dot3", 85, 345, "images/dot-off.png", "images/dot-on.png")

    omegaTargets = targetManager:new()
    --omegaTargets.onComplete = onOmegaTargetsComplete
    --omegaTargets.onSwitch = onOmegaTargetsSwitch
    omegaTargets:add("dot4", 545, 315, "images/dot-off.png", "images/dot-on.png")
    omegaTargets:add("dot5", 545, 390, "images/dot-off.png", "images/dot-on.png")

end

function love.update (dt)

    states:update(dt)
    bumperManager:update(dt)

    if (states.current == states.play or states.current == states.drained) then
        pinball:update(dt)
    end

    sprites.wheel.angle = sprites.wheel.angle + 0.0004
    sprites.rays.angle = sprites.rays.angle + 0.0004

end

function love.keypressed (key, isrepeat)

    if (key == "escape") then
        love.event.quit ( )
    elseif (key == " " and states.current == states.play) then
        pinball:newBall()
    elseif (key == "p") then
        if (states.current == states.play) then
            states:new(states.paused)
        else
            states:new(states.play)
        end
    end

end

function love.draw ( )

    -- Reset drawing color
    love.graphics.setColor (255, 255, 255, 255)

    -- Fix the coordinate system so that we draw relative to the table.
    pinball:setCamera()

    -- Draw the background image. It has a 20px border we account for.
    love.graphics.setColor(255, 255, 255, 255)
    local border = 20
    love.graphics.draw(sprites.background.image,
        pinball.table.size.x1-border, pinball.table.size.y1-border)

    -- Draw the dot targets
    novaTarget:draw()
    dotTarget:draw()
    omegaTargets:draw()

    -- Draw the Nova wheel
    love.graphics.draw(sprites.wheel.image,
        sprites.blackhole.x, sprites.blackhole.y,
        sprites.wheel.angle, 1, 1, sprites.wheel.ox, sprites.wheel.oy)
    love.graphics.draw(sprites.wheel.image,
        sprites.blackhole.x, sprites.blackhole.y,
        -sprites.wheel.angle, -1, -1, sprites.wheel.ox, sprites.wheel.oy)

    -- Draw the Nova rays
    love.graphics.draw(sprites.rays.image,
        sprites.blackhole.x, sprites.blackhole.y,
        sprites.rays.angle, 1, 1, sprites.rays.ox, sprites.rays.oy)

    -- Draw the Black hole
    love.graphics.draw(sprites.blackhole.image,
        sprites.blackhole.x, sprites.blackhole.y,
        0, 1, 1, sprites.blackhole.ox, sprites.blackhole.oy)

    -- Draw the pinball components
    love.graphics.origin()  -- Reset the coordinate system
    pinball:draw()

    -- Draw the status box
    love.graphics.setColor(0, 0, 0, 200)
    love.graphics.rectangle("fill", 0, scrHeight - 60, scrWidth, scrHeight - 60)

    -- Simple text overlays
    if (states.current == states.launch) then

        local text = ""
        if (states.current.timer > 1) then
            text = "GO!"
        elseif (states.current.timer > 0.5) then
            text = "Set"
        elseif (states.current.timer > 0) then
            text = "Ready"
        end
        
        love.graphics.setColor(255, 255, 255)
        love.graphics.printf (text, 0, 200, 600, "center")
        
    elseif (states.current == states.paused) then
        love.graphics.setColor(255, 128, 128, 64)
        love.graphics.printf ("PAUSED", 0, 200, 600, "center")

    elseif (states.current == states.drained) then

        love.graphics.setColor(128, 0, 255)
        love.graphics.printf ("Drained", 0, 200, 600, "center")

    end

end

function love.resize (w, h)
    pinball:resize (w, h)
end

function pinball.drawWall (points)
    --love.graphics.setLineWidth (6)
    --love.graphics.setColor(92, 201, 201, 255)
    --love.graphics.line(points)
end

function pinball.drawBumper (tag, x, y, r)
    --love.graphics.setLineWidth (2)
    --love.graphics.setColor(42, 161, 152)
    --love.graphics.circle("fill", x, y, r * 0.8)
    --love.graphics.setColor(108, 113, 196)
    --love.graphics.circle("line", x, y, r)

    ---- draw bumper image
    --love.graphics.setColor(255, 255, 255, 255)
    --love.graphics.draw(sprites.bumper.image, x, y, 0, 1, 1, sprites.bumper.ox, sprites.bumper.oy)

    bumperManager:draw(tag, x, y)
end

function pinball.drawKicker (tag, points)
    love.graphics.setLineWidth (1)
    love.graphics.setColor(108, 196, 113)
    love.graphics.polygon("fill", points)
end

function pinball.drawTrigger (tag, points)
    --love.graphics.setLineWidth (1)
    --love.graphics.setColor(255, 255, 255, 32)
    --love.graphics.polygon("fill", points)
end

function pinball.drawFlipper (orientation, position, angle, origin, points)
    -- orientation is "left" or "right"
    -- position {x,y}
    -- angle is in radians
    -- origin {x,y} is offset from the physics body center
    -- points {} are polygon vertices

    love.graphics.setColor(108, 113, 196)
    love.graphics.polygon("fill", points)
    love.graphics.setLineWidth (4)
    love.graphics.setColor(68, 73, 156)
    love.graphics.polygon("line", points)

    ---- The flipper body is positioned relative to it's center, given
    ---- as the origin parameter. When we draw the image we offset by the
    ---- origin to line the top-left corner of our image with the body.
    --love.graphics.setColor(255, 255, 255, 255)
    --local scaleX = (orientation == "left") and 1 or -1  -- a negative scale flips the image horizontally
    --love.graphics.draw(sprites.leftflipper.image, position.x, position.y, angle, scaleX, 1, origin.x, origin.y)
end

function pinball.drawBall (x, y, radius)
    --love.graphics.setLineWidth (4)
    --love.graphics.setColor(238, 232, 213, alpha)
    --love.graphics.circle("fill", x, y, radius)
    --love.graphics.setColor(147, 161, 161, alpha)
    --love.graphics.circle("line", x, y, radius)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(sprites.ball.image, x, y, 0, 1, 1, sprites.ball.ox, sprites.ball.oy)
end

-- Called when a ball has drained out of play.
-- The number of balls still in play are passed.
function pinball.ballDrained (ballsInPlay)
    if (ballsInPlay == 0) then
        states:new (states.drained)
    end
end

function pinball.tagContact (tag, id)

    --print("tag hit", tag, id)

    if (tag == "renew") then
        pinball:newBall()
    elseif (tag == "hole") then
        local sign1 = math.random(-1, 1) < 0 and -1 or 1
        local sign2 = math.random(-10, 1) < 0 and -1 or 1   -- More chance to shoot up
        local v1 = (300 + math.random() * 600) * sign1
        local v2 = (300 + math.random() * 600) * sign2
        pinball:lockBall (id, sprites.blackhole.x, sprites.blackhole.y, 1, v1, v2)
    end

    novaTarget:switchOn(tag)
    dotTarget:switchOn(tag)
    omegaTargets:switchOn(tag)

    bumperManager:hit(tag)
    
end

-- Load a sprite and calculate the center point.
function loadSprite (path)
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

function onNovaTargetSwitch(letter)
    print("switched " .. letter)
end

function onNovaTargetComplete()
    print("NOVA word completed")
end

function onDotTargetSwitch(letter)
    print("switched " .. letter)
end

function onDotTargetComplete()
    print("DOT target completed")
end

-- When a ball is locked with pinball:lockBall()
function pinball.ballLocked(id)
end

-- When a locked ball delay expired and is released into play
function pinball.ballUnlocked(id)
end
