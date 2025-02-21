local ent = slack.node:extend_as("Entity")

function ent:init(...)
    ent.super.init(self, ...)
end

function ent:set_layer(new_layer, manager)
    self.layer = new_layer
    manager:sort_by_layer()
end

function ent:update(dt)
end

function ent:draw()
end

return ent
