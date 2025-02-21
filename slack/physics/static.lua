local static = slack.node:extend_as("StaticBody")

function static:init(...)
    static.super.init(self, ...)

    self.is_oneway = self.prop.oneway or false
    self.layer = self.prop.layer or 1

    if slack.scene_manager.current.world then
        slack.scene_manager.current.world:add(self, self.x, self.y, self.w, self.h)
    end
end

function static:get_center_point()
    return self.x+self.w/2, self.y+self.h/2
end

function static:update(dt)
    static.super.update(self, dt)
end

function static:draw()
    static.super.draw(self)
end

function static:get_distance(e2)
    return math.sqrt((e2.x - self.x) ^ 2 + (e2.y - self.y) ^ 2)
end

function static:draw_rect()
    local rx, ry, rw, rh = slack.scene_manager.current.world:getRect(self)
    love.graphics.rectangle("line", rx, ry, rw, rh)
end

function static:update_hitbox(x, y, w, h)
    slack.scene_manager.current.world:update(self, x, y, w, h)
end

function static:destroy()
    self.remove = true
end

return static