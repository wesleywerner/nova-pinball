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

local mission = {}
mission.steps = {}
mission.currentIdx = nil
mission.build = nil

function mission:update(dt)
    if (self:current().wait) then
        self:current().wait = self:current().wait - dt
        -- expire the delay
        if (self:current().wait < 0) then
            self:current().wait = nil
            self:testState()
        end
    end
end

function mission:current()
    return self.steps[self.currentIdx]
end

function mission:define(title)
    local step = {title=title, needs={}, has={}}
    table.insert(self.steps, step)
    self.build = step
    return self
end

function mission:start()
    self.currentIdx = 1
    for _, v in pairs(self.steps) do
        print("mission '" .. v.title .. "' needs: ")
        for k, p in pairs(v.needs) do
            print(k)
        end
        if (v.wait) then print("wait delay of " .. v.wait) end
    end
end

function mission:on(signal)
    self.build.needs[signal] = 1
    return self
end

function mission:wait(delay)
    self.build.wait = delay
    return self
end

function mission:check(signal)
    --print("mission goal checking " .. signal)
    if (self:current().needs[signal] and not self:current().has[signal]) then
        print("got signal", signal)
        self:current().has[signal] = 1
        self:testState()
    --else
        --print("signal not a goal")
        --print("needs it?", self:current().needs[signal])
        --print("has it?", self:current().has[signal])
    end
end

function mission:testState()
    for dependency, _ in pairs(self:current().needs) do
        -- This step is missing a dependency
        if (not self:current().has[dependency]) then return end
        -- This step still has a delay
        if (self:current().wait) then return end
    end
    -- We have all we need to advance
    if (self.onMissionAdvanced) then self.onMissionAdvanced(self:current().title) end
    if (self.currentIdx < #self.steps) then
        self.currentIdx = self.currentIdx + 1
    else
        -- Reset the missions
        for _, step in pairs(self.steps) do
            step.has = {}
        end
    end
end

function mission:nextTarget()
    -- This step still has a delay
    if (self:current().wait) then return "wait" end
    for dependency, _ in pairs(self:current().needs) do
        -- This step is missing a dependency
        if (not self:current().has[dependency]) then return dependency end
    end
    return "NONE"
end

return mission
