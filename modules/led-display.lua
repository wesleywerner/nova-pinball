local led = {}
led.queue = {}
led.position = {x=0, y=0}
led.size = {w=400, h=200}
led.current = nil
led.WaitTime = 1.5

-- Add a new message to display.
-- Higher priorities get displayed first.
-- Sticky messages show until another message of the same or higher priority is added.
function led:add(priority, message, sticky)
    local m = {
        priority=priority,
        message=message,
        sticky=sticky,
        timer=0,
        position={x=0, y=self.size.h},
        direction="up"
        }
    -- Avoid duplicating current message
    if (self.current and self.current.message == message) then return end
    -- Unsticky current
    if (self.current and self.current.sticky and self.current.priority < priority) then
        self.current.sticky = false
    end
    -- Priority message
    if (self.current and self.current.priority < priority) then
        self.current.timer = 0
        table.insert(self.queue, 1, m)
    else
        table.insert(self.queue, m)
    end
    
end

function led:update(dt)
    -- Get the next message
    if (not self.current and #self.queue > 0) then self.current = table.remove(self.queue, 1) end
    -- Update message scroll
    if (self.current and self.current.direction == "up") then
        self.current.position.y = self.current.position.y - (dt*100)
        if (self.current.position.y <= 0) then
            self.current.direction = "wait"
            self.current.timer = self.WaitTime
        end
    end
    if (self.current and self.current.direction == "down") then
        self.current.position.y = self.current.position.y + (dt*100)
        if (self.current.position.y >= self.size.h) then
            self.current.direction = "destroy"
        end
    end
    if (self.current and self.current.direction == "wait" and not self.current.sticky) then
        self.current.timer = self.current.timer - dt
        if (self.current.timer <= 0) then
            self.current.direction = "down"
        end
    end
    if (self.current and self.current.direction == "destroy") then
        self.current = nil
    end
end

function led:draw()
    if (self.current) then
        printShadowText(
            self.current.message,
            self.position.y + self.current.position.y,
            {200, 200, 255, 255}
            )
    end
end

return led
