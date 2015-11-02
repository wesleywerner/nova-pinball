local config = {values={}}

-- Default values
config.values.cameraFollowsBall = true
config.values.flashingTargets = true
config.values.fullscreen = false

function config:load()
    local exists = love.filesystem.exists("config")
    if (exists) then
        local binser = require("modules.binser")
        local data, size = love.filesystem.read("config", nil)
        config.values = binser.deserialize(data)
    end
end

function config:save()
    local binser = require("modules.binser")
    local data = binser.serialize(config.values)
    love.filesystem.write("config", data, nil)
end

return config
