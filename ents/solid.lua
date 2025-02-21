local static = require "slack.physics.static"
local solid = static:extend_as("Solid")

function solid:init(...)
    solid.super.init(self, ...)
end

return solid