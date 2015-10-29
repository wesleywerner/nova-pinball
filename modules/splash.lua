local splash = {}

function splash:load()
    love.graphics.setFont(smallFont)
    love.graphics.setBackgroundColor(0, 0, 0, 255)
    -- center of screen
    self.center = {}
    self.center.x = scrWidth / 2
    self.center.y = scrHeight / 2
    -- circle radius
    self.r = 226
    -- sprites
    self.heart = loadSprite("images/radeocity-heart.png")
    self.spokes = loadSprite("images/radeocity-spokes.png")
    self.spokes.x = self.center.x
    self.spokes.y = self.center.y
    self.heart.x = self.center.x
    self.heart.y = self.center.y
    -- sprite manager
    self.sprites = spritemanager:new()
    self.sprites:add("spokes", self.spokes):setRotation(0.1)
    self.sprites:add("heart", self.heart)
    -- Fadeout
    self.timeout = 5
    self.fading = false
    self.fadeAlpha = 0
    -- Loading message
    local actions = {
        "Carving", "Grinding", "Wiring", "Winding", "Tightening", "Counting"
        }
    local things = {
        " Flippers",
        " Balls",
        " Bumpers",
        " Kickers",
        " Slingshots",
        " Bolts",
        }
    self.loadingMessage = actions[math.random(1, #actions)] .. things[math.random(1, #things)] .. "..."
    -- Done Loading
    self.loaded = true
end

function splash:unload()
    self.loaded = nil
    self.heart = nil
    self.spokes = nil
    self.sprites = nil
end

function splash:update(dt)
    if self.loaded then
        if (self.heart.scale == 1) then self.sprites:item("heart"):scale(-0.2) end
        if (self.heart.scale < 0.85) then self.sprites:item("heart"):scale(0.3) end
        if (self.fading) then
            self.fadeAlpha = self.fadeAlpha + (127*dt)
            if self.fadeAlpha >= 255 then
                self.fadeAlpha = 255
                self:unload()
                mainstate:set("menu")
                love.graphics.setFont(largeFont)
                return
            end
        end
        self.timeout = self.timeout - (1*dt)
        if (self.timeout < 0) then self.fading = true end
        self.sprites:update(dt)
    end
end

function splash:draw(dt)
    if self.loaded then
        love.graphics.setColor(0, 255, 0)
        love.graphics.circle("fill", self.center.x, self.center.y, self.r)
        love.graphics.setColor(255, 255, 255)
        self.sprites:draw()
        printShadowText(self.loadingMessage, scrHeight - 30, {200, 200, 100})
        if self.fading then
            love.graphics.setColor(0, 0, 0, self.fadeAlpha)
            love.graphics.rectangle("fill", 0, 0, scrWidth, scrHeight)
        end
    end
end

function splash:keypressed(key)
    if not self.fading then
        self.fading = true
    end
end

return splash
