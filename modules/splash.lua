local splash = {}

function splash:load()
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
    -- Word positioning
    self.titleY = 0
    self.loaded = true
    -- Fadeout
    self.fading = false
    self.fadeAlpha = 0
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
        if (self.titleY < scrHeight/2) then self.titleY = self.titleY + (100*dt) end
        if (self.fading) then
            self.fadeAlpha = self.fadeAlpha + (127*dt)
            if self.fadeAlpha >= 255 then
                self.fadeAlpha = 255
                self:unload()
                mainstate:set("menu")
                return
            end
        end
        self.sprites:update(dt)
    end
end

function splash:draw(dt)
    if self.loaded then
        love.graphics.setColor(0, 255, 0)
        love.graphics.circle("fill", self.center.x, self.center.y, self.r)
        love.graphics.setColor(255, 255, 255)
        self.sprites:draw()
        printShadowText("Radeocity", self.titleY, {255, 255, 255})
        if self.fading then
            love.graphics.setColor(32, 32, 64, self.fadeAlpha)
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
