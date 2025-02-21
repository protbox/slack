local ent_manager = class_name "EntityManager"

function ent_manager:init()
    self.ents = {}
end

function ent_manager:add(entity)
    table.insert(self.ents, entity)
    self:sort_by_layer()
end

function ent_manager:remove(entity)
    for i, e in ipairs(self.ents) do
        if e == entity then
            table.remove(self.ents, i)
            break
        end
    end
end

function ent_manager:sort_by_layer()
    table.sort(self.ents, function(a, b)
        return (a.layer or 0) < (b.layer or 0)
    end)
end

function ent_manager:update(dt)
    for i, entity in ipairs(self.ents) do
        if entity.remove then
            if entity._destroy then
                entity:_destroy()
            end

            table.remove(self.ents, i)

        elseif entity.update then
            entity:update(dt)
        end
    end
end

function ent_manager:draw()
    for _, entity in ipairs(self.ents) do
        if entity.draw then
            entity:draw()
        end
    end
end

return ent_manager
