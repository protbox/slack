local level = slack.scene:extend_as("Level")

local bump = require "lib.bump"

local abs = math.abs
local vis = {
    things = {}, -- stuff inside the visible screen
    len = 0,     -- how much stuff is inside the visible screen
    x = slack.viewport.x,
    y = slack.viewport.y
}

function level:init(...)
	level.super.init(self, ...)

    self.world = bump.newWorld(32)
end

function level:reset(keep_obj)
    vis.things = keep_obj and { [1] = keep_obj } or {}
    self.world = bump.newWorld(32)
    self.ent_mgr.ents = keep_obj and { [1] = keep_obj } or {}
    if keep_obj then
        self.ent_mgr.world:add(keep_obj, keep_obj.x, keep_obj.y, keep_obj.w, keep_obj.h)
    end
end

function level:list_of_stuff_i_can_see()
    local stuff = vis.things

    for i = #stuff, 1, -1 do
        stuff[i] = nil
    end

    for i=#self.ent_mgr.ents, 1, -1 do
        local ent = self.ent_mgr.ents[i]
        if ent.remove then
            self.world:remove(ent)
            table.remove(self.ent_mgr.ents, i)
        else
            -- persistant entities are always "seen"
            if ent.persist or (abs(ent.x - self.player.x) < vis.x and
                abs(ent.y - self.player.y) < vis.y) then
                    table.insert(stuff, ent)
            else
                -- if view limited, then object is removed when it can't be seen
                -- useful for temporary objects like projectiles
                if ent.view_limited then
                    ent.remove = true
                end
            end
        end
    end

    return stuff, #stuff
end

function level:update(dt)
    -- I don't think we want to update the base
    -- as we only want to update visible entities
    -- However, we lose access to component updates, so idk.
    --level.super.update(self, dt)
    
    vis.things, vis.len = self:list_of_stuff_i_can_see()
    for i=vis.len, 1, -1 do
        if vis.things[i] ~= nil then
            if vis.things[i].remove then
                vis.things[i]:destroy()
            else
                vis.things[i]:update(dt)
            end
        end
    end
end

function level:draw()
    for i=1, vis.len do
        if vis.things[i] ~= nil then vis.things[i]:draw() end
    end
end

return level