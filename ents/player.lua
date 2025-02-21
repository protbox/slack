local character = require "slack.physics.character"
local player = character:extend_as("Player")

function player:init(...)
    player.super.init(self, ...)
end

function player:update(dt)
    player.super.update(self, dt)
end

return player