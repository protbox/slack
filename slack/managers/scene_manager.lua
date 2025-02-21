local scene_manager = slack.class:extend_as("SceneManager")

-- lua doesn't always seem to have unpack
-- so I've created it here if it's missing
if not table.unpack then
    function table.unpack(t, i, j)
        i = i or 1
        j = j or #t
        if i > j then
            return
        end
        return t[i], table.unpack(t, i + 1, j)
    end
end


local scene_manager = {
    current       = nil,
    scenes        = {},
    is_fading     = false,
    fade_alpha    = 0.0,
    fade_duration = 0.2,
    fade_timer    = 0.0,
    target_scene  = nil
}

function scene_manager:add(scenes_table)
    assert(scenes_table ~= nil and type(scenes_table) == "table", "Expected a table of scenes")
    -- old way of doing things was ["SceneName"] = require()
    -- now it's just "path.scene"
    --[[for name, path in pairs(scenes_table) do
        self.scenes[name] = require(path)()
        self.scenes[name]._name = name
    end]]

    for _,scene in ipairs(scenes_table) do
        self.scenes[scene] = require(scene)()
        self.scenes[scene]._name = scene
    end
end

function scene_manager:get_scene(name)
    assert(self.scenes[name], "No such scene: " .. name)
    return self.scenes[name]
end

function scene_manager:switch(name, ...)
    assert(self.scenes[name], "Cannot switch to scene '" .. name .. "' because it doesn't exist")
    if self.current and self.current._exit then
        self.current:_exit()
    end
    self.current = self.scenes[name]
    if self.current._ready then
        self.current:_ready(...)
    end
end

function scene_manager:fade_to(scene_name, ...)
    self.target_scene = { name = scene_name, args = {...} }
    self.is_fading    = "fade_out"
    self.fade_timer   = 0.0
end

function scene_manager:update(dt)
    if self.is_fading == "fade_out" then

        self.fade_timer = self.fade_timer + dt
        self.fade_alpha = math.min(1.0, self.fade_timer / self.fade_duration)
        
        if self.fade_alpha >= 1.0 then
            self:switch(self.target_scene.name, table.unpack(self.target_scene.args))
            
            self.is_fading  = "fade_in"
            self.fade_timer = 0.0
        end
    elseif self.is_fading == "fade_in" then
        -- Fade in
        self.fade_timer = self.fade_timer + dt
        local progress  = self.fade_timer / self.fade_duration
        self.fade_alpha = math.max(0.0, 1.0 - progress)
        
        if self.fade_alpha <= 0.0 then
            self.is_fading = false
        end
    elseif self.current then
        self.current:update(dt)
    end
end

function scene_manager:draw()
    if self.current then
        self.current:draw()
    end
    
    if self.is_fading == "fade_out" or self.is_fading == "fade_in" then
        love.graphics.setColor(0, 0, 0, self.fade_alpha)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function scene_manager:mousepressed(x, y, button, istouch, presses)
    if self.current and self.current.mousepressed then
        self.current:mousepressed(x, y, button, istouch, presses)
    end
end

return scene_manager