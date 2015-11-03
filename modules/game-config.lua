local config = {values={}}

config.settings = {
    {meta = "cameraFollowsBall",
    title = "Camera",
    options = {"Ball", "Table"},
    values = {1, 2},
    default = 1,
    details = {"Zoomed in and follows the ball",
              "Zoomed out, full table visible"
              }
    },
    {meta = "flashingTargets",
    title = "Mission Hints",
    options = {"LED", "Lights", "Full", "None"},
    values = {1, 2, 3, 4},
    default = 3,
    details = {"Hints in the LED display",
              "Hints with flashing lights",
              "Hints with both LED and lights",
              "No hints"
              }
    },
    {meta = "fullscreen",
    title = "Screen",
    options = {"Full Screen", "Window"},
    values = {1, 2},
    default = 2,
    details = {"",
              ""
              }
    },
}

-- Load config from file
function config:load()
    local exists = love.filesystem.exists("config")
    if (exists) then
        local binser = require("modules.binser")
        local data, size = love.filesystem.read("config", nil)
        config.values = binser.deserialize(data)
    end
    config:applyMissing()
end

-- Apply default values to any missing settings
function config:applyMissing()
    for _, default in pairs(self.settings) do
        if (not self.values[default.meta]) then
            self.values[default.meta] = default.default
        end
    end
end

-- Reset all values back to defaults
function config:applyDefaults()
    for _, default in pairs(self.settings) do
        self.values[default.meta] = default.default
    end
end

-- Save config to file
function config:save()
    local binser = require("modules.binser")
    local data = binser.serialize(config.values)
    love.filesystem.write("config", data, nil)
end

-- Return the option title for a given meta and value
function config:getValue(meta, value)
    for _, setting in pairs(self.settings) do
        if (setting.meta == meta) then
            return setting.options[value]
        end
    end
end

function config:get(meta)
    return self.values[meta]
end

return config
