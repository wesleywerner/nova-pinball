local touch = {}

-- Customize button colors
touch.colors = {}
touch.colors.fill = {0, 200, 100, 200}
touch.colors.border = {200, 255, 255, 200}
touch.colors.font = {255, 255, 255, 200}

-- A zone is a state when to show a button.
touch.zones = {}

-- Add a button to a zone, it's title, position and the key
-- it bubbles to love.keypressed/keyreleased.
-- Position is given as a table of percentages to the display size
-- as top, left, bottom, right values:
--      { top=10, left=10, bottom=15, right=15 }
--  (A button 10% top-left and 15% bottom-right of the device size)
function touch.add(self, zone, key, title, position, image)
    
    if not self.zones[zone] then
        -- Set up a new zone collection
        self.zones[zone] = {}
    end
    
--    if image then
--        position.bottom = position.top + image:getWidth()
--        position.right = position.left + image:getHeight()
--    end
    
    local touchData = {
        title=title,
        position=position,
        key=key,
        image=image
    }
    
    table.insert(self.zones[zone], touchData)
    
end

function touch.determine_zone(self, zone, x, y)
    
    -- Test if this zone has buttons
    if not self.zones[zone] then return end
    
    -- Coordinate button positions to a dynamic display size
    local W, H = love.graphics.getDimensions()
    
    for _, button in pairs(self.zones[zone]) do
        
        local bx = button.position.left / 100 * W
        local by = button.position.top / 100 * H
        local bh = button.position.bottom / 100 * H
        local bw = button.position.right / 100 * W
        
        if x > bx and x < bw and y > by and y < bh then
            return button.key
        end
        
    end

end

function touch.draw(self, zone)
    
    -- Test if this zone has buttons
    if not self.active or not self.zones[zone] then return end
    
    -- Coordinate button positions to a dynamic display size
    local W, H = love.graphics.getDimensions()
    
    -- Set button drawing style
    love.graphics.setColor({255, 255, 255, 128})
    love.graphics.setLineWidth(1)
    
    for _, button in pairs(self.zones[zone]) do
        
        local x = button.position.left / 100 * W
        local y = button.position.top / 100 * H
        local h = button.position.bottom / 100 * H - y
        local w = button.position.right / 100 * W - x
            
        -- Image
        if button.image then
            
           love.graphics.draw(button.image,
               x+w/2, y+h/2,
               0, 1, 1,
               button.image:getWidth()/2,
               button.image:getHeight()/2)
            
            if DEBUG then
                love.graphics.rectangle("line", x, y, w, h)
            end

        else
            
            -- Fill
            love.graphics.setColor(touch.colors.fill)
            love.graphics.rectangle("fill", x, y, w, h)
            
            -- Border
            love.graphics.setColor(touch.colors.border)
            love.graphics.rectangle("line", x, y, w, h)
            
            -- Title
            love.graphics.setColor(touch.colors.font)
            love.graphics.printf(button.title, x, y+h/2, w, "center")
            
        end
        
    end
    
end

function touch.pressed(self, zone, x, y)
    
    if not self.active then return end
    
    local key = self:determine_zone(zone, x, y)
    
    if key then love.keypressed(key) end
    
end

function touch.released(self, zone, x, y)
    
    if not self.active then return end
    
    local key = self:determine_zone(zone, x, y)
    
    if key then love.keyreleased(key) end
    
end

function touch.addKeyboard(self)
    
    local numbers = "0123456789"
    local alpha1 = "abcdefghijklm"
    local alpha2 = "nopqrstuvwxyz"
    local special = {"backspace", "return"}
    
    for col = 1, #numbers  do
        local key = numbers:sub(col, col)
        local width = 7.6
        local x= (col-1)*width
        self:add("kb", key, key, {left=x, top=60, bottom=70, right=x+width})
    end

    for col = 1, #alpha1  do
        local key = alpha1:sub(col, col)
        local width = 7.6
        local x= (col-1)*width
        self:add("kb", key, key, {left=x, top=70, bottom=80, right=x+width})
    end

    for col = 1, #alpha2  do
        local key = alpha2:sub(col, col)
        local width = 7.6
        local x= (col-1)*width
        self:add("kb", key, key, {left=x, top=80, bottom=90, right=x+width})
    end

    for col, n in ipairs(special) do
        local width = 30
        local x= (col-1)*width
        self:add("kb", n, n, {left=x, top=90, bottom=100, right=x+width})
    end

end

-- Hook the touch regions for android devices
if DEBUG or love.system.getOS() == "Android" then
    touch.active = true
    touch:addKeyboard()
end

return touch