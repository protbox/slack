local static = require "slack.physics.static"
local character = static:extend_as("CharacterBody")

function character:init(...)
    character.super.init(self, ...)

    self.vx = 0
    self.vy = 0
    self.gravity = 1600
    self.speed = 60
    self.grounded = false
    self.bounciness = 0.0
    self.air_time = 0.0
    self.l, self.t = self.x, self.y
    self.filter = function(item, other)
        if other.is_oneway and (item.y > other.y-(item.h)) then return false
        elseif other.is_collectable then return "cross"
        else return "slide" end
    end
end

function character:update(dt)
    character.super.update(self, dt)

    local future_l = self.x + self.vx * dt
    local future_t = self.y + self.vy * dt
    local next_l, next_t, cols, clen = slack.scene_manager.current.world:move(self, future_l, future_t, self.filter)

    for i=1, clen do
        local col = cols[i]

        self:collides(col.normal, col.other, col.type)
    end

    self.x, self.y = next_l, next_t
end

function character:apply_gravity(dt)
    if not self.grounded then
        self.air_time = self.air_time + dt
        self.vy = self.vy + (self.gravity * self.air_time) * dt
    else
        self.air_time = 0.0
    end
end

function character:collides(normal, other, col_type)
    -- if character bumps their head, reset y velocity
    if normal.y == 1 and col_type == "slide" then
        self.vy = 0
    end
end

return character