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

local play = {}
local states = nil
local pinball = require ("nova-pinball-engine")
local targetManager = require("modules.letter-targets")
local bumperManager = require("modules.bumpers")
local mission = require("modules.mission")
local spriteStates = require("modules.sprite-state-manager")
local led = require("modules.led-display")
local sprites = { }

-- Calculated to center the table in the screen
play.leftAlign = 0
-- Pre-game scroll effect drawing offset
play.previewPosition = 0
-- Table nudge shake offset
play.nudgeOffset = 0
-- Tracks when to display the current mission goal on the LED display
play.missionStatusUpdateTime = 0
-- Safe-mode fires a new ball if any ball drains
play.safeMode = 0
-- How long safe-mode lasts (seconds)
play.safeModePeriod = 60
-- Position to draw the balls remaining stat line (gets updated on resize)
play.ballStatXPosition = 0
-- Store the current player score
play.score = 0
play.scoreFormatted = "0"
play.balls = 6

-- A lookup of mission targets and their human readable texts
local missionDescriptions = {
    ["nova word"]="Complete the NOVA word bonus",
    }

-- A set of encouraging words while the mission state is waiting
local waitingWords = {
    "Keep it up",
    "Looking good",
    "Don't drop that ball",
    "Hope you're enjoying Nova Pinball",
    "You are in the Zone"
    }

function loadFromFile ( )
    local binser = require("modules.binser")
    local mydata, size = love.filesystem.read("nova.pinball", nil)
    local tableDefinition = binser.deserialize(mydata)
    pinball:loadTable(tableDefinition)
end

function play:gameInProgress()
    return states:on("play") or states:on("paused")
end

function play:load()

    -- Set up play states
    states = statemanager:new()
    states:add("preview")
    states:add("play")
    states:add("paused")

    -- Load sprites
    sprites.background = loadSprite ("images/background.png")
    sprites.launchCover = loadSprite("images/launcher-cover.png")
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
    sprites.star = loadSprite("images/stable-star.png")

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

    -- Position the launch cover over the ball
    sprites.launchCover.x = pinball.table.ball.x
    sprites.launchCover.y = pinball.table.ball.y
    
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
    sprites.star.x = x
    sprites.star.y = y
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
    spriteStates:add("star", sprites.star)
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
    bumperManager:add("left bumper", "images/bumper.png")
    bumperManager:add("middle bumper", "images/bumper.png")
    bumperManager:add("right bumper", "images/bumper.png")
    bumperManager:add("left kicker", "images/kicker.png")
    bumperManager:add("right kicker", "images/kicker.png", -1)

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
    leftTargets:add("dot4", x, y, "images/circle-target-off.png", "images/circle-target-on.png")
    local x, y = pinball:getObjectXY("dot5")
    leftTargets:add("dot5", x, y, "images/circle-target-off.png", "images/circle-target-on.png")

    -- Set up the right targets
    rightTargets = targetManager:new()
    rightTargets.onComplete = onrightTargetsComplete
    rightTargets.onSwitch = onrightTargetsSwitch
    local x, y = pinball:getObjectXY("dot1")
    rightTargets:add("dot1", x, y, "images/circle-target-off.png", "images/circle-target-on.png")
    local x, y = pinball:getObjectXY("dot2")
    rightTargets:add("dot2", x, y, "images/circle-target-off.png", "images/circle-target-on.png")
    local x, y = pinball:getObjectXY("dot3")
    rightTargets:add("dot3", x, y, "images/circle-target-off.png", "images/circle-target-on.png")

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

    play.positionDrawingElements()

    -- Pre-game welcome
    led:add(0, "Welcome to Nova Pinball")
    led:add(0, "Hit space to play")
end

function play:update (dt)
    states:update(dt)
    led:update(dt)
    play.updateLedDisplayMessages(dt)
    play.updateSafemode(dt)
    if (states:on("preview")) then
        if (self.previewPosition > -(pinball.table.size.height-scrHeight)) then
            self.previewPosition = self.previewPosition - (dt*50)
            pinball.cfg.translateOffset.y = self.previewPosition
        end
    elseif (states:on("play")) then
        play.updateNudge()
        pinball:update(dt)
        bumperManager:update(dt)
        spriteStates:update(dt)
        mission:update(dt)
    end

end

function play:keypressed (key)
    if (states:on("preview")) then
        if (key == " ") then
            pinball.cfg.translateOffset.y = 0
            states:set("play")
            led:add(100, "Make the star go Nova")
        end
        if (key == "escape") then mainstate:set("menu") end
    elseif (states:on("play")) then
        if (key == "escape") then states:set("paused") end
        if (key == "lshift") then pinball:moveLeftFlippers() end
        if (key == "rshift") then pinball:moveRightFlippers() end
        if (key == " ") then
            if (#pinball.bodies.balls == 0) then
                pinball:newBall()
                led:add(100, "Make the star go Nova")
            else
                pinball:nudge(20, 20)
                play.nudgeOffset = 20
            end
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

function play:keyreleased(key)
    if (key == "lshift") then pinball:releaseLeftFlippers() end
    if (key == "rshift") then pinball:releaseRightFlippers() end
    if key == "s" then play.activateBallSaver() end
end

function play:draw ( )

    -- Reset drawing color
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.setColor (255, 255, 255, 255)

    -- Center in the screen
    love.graphics.translate(play.leftAlign, 0)

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

    -- Draw the launch cover over the pinball components
    -- (reposition the camera as the pinball module resets it after it draws)
    love.graphics.setColor (255, 255, 255, 255)
    sprites.launchCover:draw()

    -- Draw the status box
    love.graphics.origin()
    --love.graphics.setColor(0, 0, 0, 200)
    --love.graphics.rectangle("fill", 0, scrHeight - 60, scrWidth, scrHeight - 60)
    play:drawStats()
    love.graphics.setFont(largeFont)
    led:draw()

    -- Simple text overlays
    if (states:on("paused")) then
        printShadowText("PAUSED", 200, {255, 128, 255, 200})
    end

end

function play:resize (w, h)
    play.positionDrawingElements()
    pinball:resize (w, h)
end

function play:drawStats()
    local height = 20
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.rectangle("fill", 0, 0, scrWidth, height)
    love.graphics.setFont(smallFont)

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print("Balls:" .. play.balls, play.ballStatXPosition, 2)
    love.graphics.print("Score:" .. play.scoreFormatted, 10, 2)
end

function play.updateNudge()
    if (play.nudgeOffset > 0) then
        pinball.cfg.translateOffset.y = play.nudgeOffset
        play.nudgeOffset = play.nudgeOffset - (play.nudgeOffset / 2)
    end
end

function play.positionDrawingElements()
    led.size.w = scrWidth
    led.size.h = 40
    led.position.y = scrHeight - led.size.h
    play.ballStatXPosition = scrWidth - smallFont:getWidth("Balls: 0") - 10
    play.leftAlign = (scrWidth - pinball.table.size.width) / 2
end

function play.updateLedDisplayMessages(dt)
    play.missionStatusUpdateTime = play.missionStatusUpdateTime - dt
    if (play.missionStatusUpdateTime < 0 or dt == 0) then
        play.missionStatusUpdateTime = 20
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

function pinball.drawKicker (tag, x, y, points)
    --love.graphics.setLineWidth (1)
    --love.graphics.setColor(108, 196, 113)
    --love.graphics.polygon("fill", points)
    bumperManager:draw(tag, x, y)
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

    --love.graphics.setColor(108, 113, 196)
    --love.graphics.polygon("fill", points)
    --love.graphics.setLineWidth (4)
    --love.graphics.setColor(68, 73, 156)
    --love.graphics.polygon("line", points)

    ---- The flipper body is positioned relative to it's center, given
    ---- as the origin parameter. When we draw the image we offset by the
    ---- origin to line the top-left corner of our image with the body.
    love.graphics.setColor(255, 255, 255, 255)
    local scaleX = (orientation == "left") and 1 or -1  -- a negative scale flips the image horizontally
    love.graphics.draw(sprites.leftflipper.image, position.x, position.y, angle, scaleX, 1, origin.x, origin.y)
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
    if (play.safeMode > 0) then
        led:add(10, "Ball Saved")
        pinball:newBall()
    elseif (ballsInPlay == 0) then
        led:add(20, "Ball drained")
        play.balls = play.balls - 1
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
            play.addScore(2500)
            led:add(0, "Gravity Lock Bonus")
        end
    end

    if (tag == "left bumper" or tag == "middle bumper" or tag == "right bumper") then
        play.addScore(500)
    elseif (tag == "left kicker" or tag == "right kicker") then
        play.addScore(750)
    end

    novaTarget:switchOn(tag)
    leftTargets:switchOn(tag)
    rightTargets:switchOn(tag)
    bumperManager:hit(tag)
    mission:check(tag)
    
end

function onNovaTargetSwitch(letter)

end

function onNovaTargetComplete()
    play.addScore(1250)
    led:add(0, "Word Bonus")
    mission:check("nova word")
end

function onLeftTargetSwitch(letter)

end

function onLeftTargetsComplete()
    play.addScore(100)
    mission:check("left targets")
end

function onrightTargetsSwitch(letter)

end

function onrightTargetsComplete()
    play.addScore(100)
    mission:check("right targets")
end

function mission.onMissionCheckPassed(signal)
    -- Force to display the next goal
    play.updateLedDisplayMessages(0)
end

function mission.onMissionAdvanced(title)

    if (title == "red giant") then
        play.addScore(1000)
        led:add(10, "Star evolved into a Red Giant")
        spriteStates:item("red star"):setVisible(true):scale(0.001)
    elseif (title == "hydrogen release") then
        play.addScore(1250)
        led:add(10, "Hydrogen released")
    elseif (title == "fusion stage 1") then
        play.addScore(1500)
        led:add(10, "Fusion first stage complete")
        spriteStates:item("wheel 1"):setVisible(true):scale(0.0003)
    elseif (title == "fusion stage 2") then
        play.addScore(1750)
        led:add(10, "Fusion second stage complete")
        spriteStates:item("wheel 2"):setVisible(true):scale(0.0003)
    elseif (title == "fusion burn") then
        led:add(10, "Fusion burning... ")
    elseif (title == "fusion unstable") then
        led:add(10, "Fusion unstable")
        spriteStates:item("rays"):setVisible(true):scale(0.0005)
    elseif (title == "collapse star") then
        play.addScore(2250)
        led:add(10, "Star collapsing")
        led:add(10, "Black hole created")
        play.showBlackHole()
    elseif (title == "wormhole") then
        led:add(10, "Wormhole Alert!", true)
        play.showWormhole()
    elseif (title == "reset") then
        play.addScore(10000)
        led:add(11, "Supergravity Bonus")
        play.resetMissionSprites()
        play.showStarFlare()
        play.insertBonusMission()
    elseif (title == "bonus ball notice") then
        led:add(0, "Matter Jetisson")
        led:add(0, "Score another ball")
    elseif (title == "bonus ball") then
        play.addScore(15000)
        play.releaseBonusBall()
        play.activateBallSaver()
    end

end

function play.resetMissionSprites()
    -- hide the nova rings and black hole
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
end

function play.showStarFlare()
    spriteStates:item("star flare"):scale(0.001):setVisible(true)
    pinball:restoreGravity()
    pinball:setBallDampening(0)
end

function play.showBlackHole()
    spriteStates:item("black hole"):setVisible(true):scale(0.01)
end

function play.showWormhole()
    pinball:setGravity(0)
    pinball:setBallDampening(1)
    spriteStates:item("worm hole rays"):setVisible(true):scale(0.001)
    spriteStates:item("worm hole"):setVisible(true):scale(0.002)
    spriteStates:item("worm hole clouds"):setVisible(true):scale(0.002)
end

function play.insertBonusMission()
    if (not mission:has("bonus ball")) then
        -- Pre-mission notice
        local n = mission:define("bonus ball notice")
        n:wait(30)
        n:moveAfter("hydrogen release")
        -- Multi-ball mission
        local m = mission:define("bonus ball")
        m:on("left bumper")
        m:on("nova word")
        m:on("right bumper")
        m:on("nova word")
        m:on("middle bumper")
        m:on("left targets")
        m:on("right targets")
        m:moveAfter("bonus ball notice")
    end
end

function play.releaseBonusBall()
    led:add(10, "Multi-ball Bonus")
    pinball:newBall()
end

function play.updateSafemode(dt)
    if (play.safeMode > 0) then
        play.safeMode = play.safeMode - dt
        if (play.safeMode < 0) then
            play.deactivateBallSaver()
        end
    end
end

function play.activateBallSaver()
    led:add(10, "Safe Mode Activated")
    play.safeMode = play.safeModePeriod
end

function play.deactivateBallSaver()
    play.safeMode = 0
    led:add(10, "Safe Mode Off")
end

function play.addScore(amount)
    play.score = play.score + amount
    -- store a thousand-formatted value
    local formatted = play.score
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k==0) then break end
    end
    play.scoreFormatted = formatted
end

-- When a ball is locked with pinball:lockBall()
function pinball.ballLocked(id)
end

-- When a locked ball delay expired and is released into play
function pinball.ballUnlocked(id)
end

return play
