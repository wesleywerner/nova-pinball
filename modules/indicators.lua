local indicators = {}
indicators.items = {}

function indicators:update(dt)
    for _, ind in pairs(self.items) do
        if (ind.on) then
            ind.timer = ind.timer - dt
            if (ind.timer < 0) then
                ind.displayIndex = ind.displayIndex + 1
                ind.timer = ind.delay
                if (ind.displayIndex > #ind.images) then
                    ind.displayIndex = 1
                end
            end
        end
    end
end

function indicators:draw()
    for _, ind in pairs(self.items) do
        local img = ind.images[ind.displayIndex]
        love.graphics.draw(img.image, ind.x, ind.y, 0, 1, 1, img.ox, img.oy)
    end
end

function indicators:add(tag, x, y, imageList)
    local ind = {}
    ind.on = false
    ind.x = x
    ind.y = y
    ind.displayIndex = 1
    ind.images = {}
    ind.timer = 0
    ind.delay = 1
    for _, p in ipairs(imageList) do
        local img = loadSprite(p)
        table.insert(ind.images, img)
    end
    self.items[tag] = ind
end

function indicators:set(tag, state)
    local ind = self.items[tag]
    if (ind) then
        ind.on = state
    end
end

function indicators:reset()
    for _, ind in pairs(self.items) do
        ind.on = false
        ind.displayIndex = 1
    end
end

return indicators
