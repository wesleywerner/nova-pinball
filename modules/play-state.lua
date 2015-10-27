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
local states = nil
local pinball = require ("nova-pinball-engine")
local targetManager = require("modules.letter-targets")
local bumperManager = require("modules.bumpers")
local mission = require("modules.mission")
local spriteStates = require("modules.sprite-state-manager")
local led = require("modules.led-display")
local sprites = { }
local previewPosition = 0

-- A lookup of mission targets and their human readable texts
local missionDescriptions = {
    ["nova word"]="Complete the NOVA word bonus",
    }

-- A set of encouraging words while the mission state is waiting
local waitingWords = {
    "Keep it up!",
    "Looking good!",
    "Don't drop that ball!",
    "Hope you're enjoying Nova Pinball!",
    "You are in the Zone!"
    }

-- Tracks when to display the current mission goal on the LED display
local missionStatusUpdateTime = 0

function loadFromFile ( )
    local binser = require("modules.binser")
    local mydata, size = love.filesystem.read("nova.pinball", nil)
    local tableDefinition = binser.deserialize(mydata)
    pinball:loadTable(tableDefinition)
end

function thisState:load()

    -- Set up play states
    states = statemanager:new()
    states:add("preview")
    states:add("play")
    states:add("paused")

    -- Load sprites
    sprites.background = loadSprite ("images/background.png")
    sprites.ball = loadSprite ("images/ball.png")
    sprites.leftflipper = loadSprite ("images/leftflip.png")
    sprites.blackhole = loadSprite("images/black-hole.png")
    sprites.wheel1 = loadSprite("images/nova-wheel.png")
    sprites.wheel2 = loadSprite("images/nova-wheel.png")
    sprites.rays = loadSprite("images/nova-rays.png")
    sprites.redStar = loadSprite("images/red-star.png")
    sprites.wormholeRays = loadSprite("images/wormhole-rays.png")
    sprites.wormhole = loadSprite("images/wormhole-background.png")
    sprites.wormholeClouds = loadSprite("images/wormhole-clouds.png")
    sprites.starFlare = loadSprite("images/star-flare.png")

    -- Set graphics
    love.graphics.setBackgroundColor(0, 0, 0)

    -- Set initial game state
    pinball:newBall()
    states:set("preview")

    -- Load the table layout into the pinball engine
    loadFromFile()

    -- Position the background image
    local border = 20
    sprites.background.x = pinball.table.size.x1-border
    sprites.background.y = pinball.table.size.y1-border
    sprites.background.ox = 0   -- Position relative to top-left corner
    sprites.background.oy = 0   -- and not the center of the image

    -- Center all these sprites around the black hole's position
    local x, y = pinball:getObjectXY("black hole")
    sprites.blackhole.x = x
    sprites.blackhole.y = y
    sprites.wormholeRays.x = x
    sprites.wormholeRays.y = y
    sprites.wormhole.x = x
    sprites.wormhole.y = y
    sprites.wormholeClouds.x = x
    sprites.wormholeClouds.y = y
    sprites.rays.x = x
    sprites.rays.y = y
    sprites.starFlare.x = x
    sprites.starFlare.y = y
    sprites.redStar.x = x
    sprites.redStar.y = y
    sprites.wheel1.x = x
    sprites.wheel1.y = y
    sprites.wheel2.x = x
    sprites.wheel2.y = y
    sprites.wheel2.scale = -1

    -- Set up the sprite state manager
    spriteStates:add("wheel 1", sprites.wheel1):setRotation(0.0004):setScale(0)
    spriteStates:add("wheel 2", sprites.wheel2):setRotation(0.0006):setScale(0)
    spriteStates:add("rays", sprites.rays):setRotation(-0.002):setScale(0)
    spriteStates:add("red star", sprites.redStar):setScale(0)
    spriteStates:add("star flare", sprites.starFlare):setRotation(-0.0003):setScale(0)
    spriteStates:add("worm hole rays", sprites.wormholeRays):setRotation(0.01):setScale(0)
    spriteStates:add("worm hole", sprites.wormhole):setRotation(0.01):setScale(0)
    spriteStates:add("worm hole clouds", sprites.wormholeClouds):setRotation(0.02):setScale(0):setBlendmode("additive")
    spriteStates:add("black hole", sprites.blackhole):setScale(0)

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

    -- Set up the left targets
    leftTargets = targetManager:new()
    leftTargets.onComplete = onLeftTargetsComplete
    leftTargets.onSwitch = onLeftTargetSwitch
    local x, y = pinball:getObjectXY("dot4")
    leftTargets:add("dot4", x, y, "images/dot-off.png", "images/dot-on.png")
    local x, y = pinball:getObjectXY("dot5")
    leftTargets:add("dot5", x, y, "images/dot-off.png", "images/dot-on.png")

    -- Set up the right targets
    rightTargets = targetManager:new()
    rightTargets.onComplete = onrightTargetsComplete
    rightTargets.onSwitch = onrightTargetsSwitch
    local x, y = pinball:getObjectXY("dot1")
    rightTargets:add("dot1", x, y, "images/dot-off.png", "images/dot-on.png")
    local x, y = pinball:getObjectXY("dot2")
    rightTargets:add("dot2", x, y, "images/dot-off.png", "images/dot-on.png")
    local x, y = pinball:getObjectXY("dot3")
    rightTargets:add("dot3", x, y, "images/dot-off.png", "images/dot-on.png")

    -- Define the mission goals
    mission:define("red giant"):on("nova word")
    mission:define("hydrogen release"):on("left ramp"):on("right ramp")
    mission:define("fusion stage 1"):on("left targets"):on("left ramp")
    mission:define("fusion stage 2"):on("right targets"):on("right ramp")
    mission:define("fusion burn"):wait(60)      -- triggered via a timed delay
    mission:define("fusion unstable"):wait(60)  -- ditto
    mission:define("collapse star"):on("left ramp"):on("right ramp"):on("nova word")
    mission:define("wormhole"):on("black hole"):on("black hole"):on("black hole")
    mission:define("reset"):wait(15)
    mission:start()

    positionDrawingElements()

    -- Pre-game welcome
    led:add(0, "Welcome to Nova Pinball!")
    led:add(0, "Hit space to play")
end

function thisState:update (dt)
    states:update(dt)
    led:update(dt)
    updateLedDisplayMessages(dt)
    if (states:on("preview")) then
        if (previewPosition > -pinball.cfg.cameraOffset) then
            previewPosition = previewPosition - (dt*50)
            pinball.cfg.translateOffset.y = previewPosition
        end
    elseif (states:on("play")) then
        pinball:update(dt)
        bumperManager:update(dt)
        spriteStates:update(dt)
        mission:update(dt)
    end

end

function thisState:keypressed (key)
    if (states:on("preview")) then
        if (key == " ") then
            pinball.cfg.translateOffset.y = 0
            states:set("play")
            led:add(100, "Make the star go Nova!")
        end
        if (key == "escape") then mainstate:set("menu") end
    elseif (states:on("play")) then
        if (key == "escape") then states:set("paused") end
        if (key == "lshift") then pinball:moveLeftFlippers() end
        if (key == "rshift") then pinball:moveRightFlippers() end
        if (key == " " and #pinball.bodies.balls == 0) then
            pinball:newBall()
            led:add(100, "Make the star go Nova!")
        end
    elseif (states:on("paused")) then
        if (key == " ") then states:set("play") end
        if (key == "escape") then mainstate:set("menu") end
    end
    --if (key == "escape") then love.event.quit() end
    -- advance the mission goal
    if (key == "f2") then
        mission:skipWait()
        mission:check(mission:nextTarget())
    end
end

function thisState:keyreleased(key)
    if (key == "lshift") then pinball:releaseLeftFlippers() end
    if (key == "rshift") then pinball:releaseRightFlippers() end
end

function thisState:draw ( )

    -- Reset drawing color
    love.graphics.setColor (255, 255, 255, 255)

    -- Fix the coordinate system so that we draw relative to the table.
    pinball:setCamera()

    -- Draw the background image. It has a 20px border we account for.
    love.graphics.setColor(255, 255, 255, 255)
    sprites.background:draw()

    -- Draw targets and sprites
    novaTarget:draw()
    leftTargets:draw()
    rightTargets:draw()
    spriteStates:draw()

    -- Draw the pinball components
    pinball:draw()

    -- Draw the status box
    --love.graphics.setColor(0, 0, 0, 200)
    --love.graphics.rectangle("fill", 0, scrHeight - 60, scrWidth, scrHeight - 60)
    love.graphics.setColor(200, 200, 255, 255)
    led:draw()

    -- Simple text overlays
    if (states:on("paused")) then
        printShadowText("PAUSED", 200, {255, 128, 255, 200})
    end

end

function printShadowText(text, y, color)
    local w = love.graphics.getWidth()
    love.graphics.setColor(0, 0, 0, 200)
    love.graphics.printf (text, 1, y+1, w, "center")
    love.graphics.setColor(unpack(color))
    love.graphics.printf (text, 0, y, w, "center")
end

function thisState:resize (w, h)
    pinball:resize (w, h)
end

function positionDrawingElements()
    w, h = love.window.getDimensions()
    led.size.w = w
    led.size.h = 40
    led.position.y = h - led.size.h
end

function updateLedDisplayMessages(dt)
    missionStatusUpdateTime = missionStatusUpdateTime - dt
    if (missionStatusUpdateTime < 0 or dt == 0) then
        missionStatusUpdateTime = 20
        if (states:on("play")) then
            -- Display a hint of the next goal
            local title = mission:nextTarget()
            -- Show encouraging words while waiting on a goal
            if (title == "wait") then
                title = waitingWords[math.random(1, #waitingWords)]
            elseif (missionDescriptions[title]) then
                -- Display a hint of the next goal
                title = missionDescriptions[title]
            else
                -- A generic message if no descriptive text is available for this goal
                title = "Shoot for the " .. title
            end
            led:add(10, title)
        end
    end
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
        led:add(20, "Ball drained")
        led:add(0, "Hit space to play")
    end
end

function pinball.tagContact (tag, id)

    if (tag == "black hole") then
        local blackHoleVisible = spriteStates:item("black hole").visible
        if blackHoleVisible then
            local sign1 = math.random(-1, 1) < 0 and -1 or 1
            local sign2 = math.random(-10, 1) < 0 and -1 or 1   -- More chance to shoot up
            local v1 = (300 + math.random() * 600) * sign1
            local v2 = (300 + math.random() * 600) * sign2
            pinball:lockBall (id, sprites.blackhole.x, sprites.blackhole.y, 1, v1, v2)
            led:add(0, "Gravity Lock Bonus")
        end
    end

    novaTarget:switchOn(tag)
    leftTargets:switchOn(tag)
    rightTargets:switchOn(tag)
    bumperManager:hit(tag)
    mission:check(tag)
    
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
    sprite.angle = 0
    sprite.scale = 1
    function sprite:draw()
        love.graphics.draw(self.image, self.x, self.y, self.angle, self.scale, self.scale, self.ox, self.oy)
    end
    return sprite
end

function onNovaTargetSwitch(letter)

end

function onNovaTargetComplete()
    led:add(0, "Word Bonus!")
    mission:check("nova word")
end

function onLeftTargetSwitch(letter)

end

function onLeftTargetsComplete()
    mission:check("left targets")
end

function onrightTargetsSwitch(letter)

end

function onrightTargetsComplete()
    mission:check("right targets")
end

function mission.onMissionCheckPassed(signal)
    -- Force to display the next goal
    updateLedDisplayMessages(0)
end

function mission.onMissionAdvanced(title)

    if (title == "red giant") then
        led:add(10, "Star evolved into a Red Giant")
        spriteStates:item("red star"):setVisible(true):scale(0.001)
    elseif (title == "hydrogen release") then
        led:add(10, "Hydrogen released!")
    elseif (title == "fusion stage 1") then
        led:add(10, "Fusion first stage complete!")
        spriteStates:item("wheel 1"):setVisible(true):scale(0.0003)
    elseif (title == "fusion stage 2") then
        led:add(10, "Fusion second stage complete!")
        spriteStates:item("wheel 2"):setVisible(true):scale(0.0003)
    elseif (title == "fusion burn") then
        led:add(10, "Fusion burning... ")
    elseif (title == "fusion unstable") then
        led:add(10, "Fusion unstable!")
        spriteStates:item("rays"):setVisible(true):scale(0.0005)
    elseif (title == "collapse star") then
        led:add(10, "Star collapsing!")
        led:add(10, "Black hole created!")
        spriteStates:item("black hole"):setVisible(true):scale(0.001)
    elseif (title == "wormhole") then
        -- show the worm hole
        led:add(10, "Wormhole Alert!", true)
        pinball:setGravity(-0.1)
        pinball:setBallDampening(1)
        spriteStates:item("worm hole rays"):setVisible(true):scale(0.001)
        spriteStates:item("worm hole"):setVisible(true):scale(0.002)
        spriteStates:item("worm hole clouds"):setVisible(true):scale(0.002)
    elseif (title == "reset") then
        -- hide the nova rings and black hole
        led:add(11, "Super Bonus!")
        spriteStates:item("wheel 1"):scale(-0.1)
        spriteStates:item("wheel 2"):scale(-0.1)
        spriteStates:item("rays"):scale(-0.1)
        spriteStates:item("red star"):scale(-0.1)
        spriteStates:item("black hole"):scale(-0.1)
        -- hide the wormhole and restore gravity
        spriteStates:item("worm hole"):scale(-0.04)
        spriteStates:item("worm hole clouds"):scale(-0.04)
        -- Slowly retract the rays
        spriteStates:item("worm hole rays"):scale(-0.015)
        -- Show a star flare after reset
        spriteStates:item("star flare"):scale(0.001):setVisible(true)
        pinball:restoreGravity()
        pinball:setBallDampening(0)
    end

end

-- When a ball is locked with pinball:lockBall()
function pinball.ballLocked(id)
end

-- When a locked ball delay expired and is released into play
function pinball.ballUnlocked(id)
end

return thisState
