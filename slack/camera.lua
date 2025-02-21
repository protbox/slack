local camera = class_name "camera"

function camera:init(follow, map_size)
    assert(map_size ~= nil, "camera:init() expects a follow target and map_size")
    
    self.new_camera_x = 0
    self.new_camera_y = 0
    self.camera_min_x = 0
    self.camera_min_y = 0
    self.camera_x = 0
    self.camera_y = 0
    self.tile_size = 16
    self.map_size = map_size
    self.lerp_speed = 10.0
    self.stick = false
    self.follow = follow -- target to follow
end

function camera:update(dt)
    if not self.stick then
        self.new_camera_x = - (self.follow.x) + (slack.viewport.x/2) - self.follow.w
        self.new_camera_y = - (self.follow.y) + (slack.viewport.y/2) - self.follow.h

        self.camera_x = self.camera_x + (self.new_camera_x-self.camera_x) / self.lerp_speed
        self.camera_y = self.camera_y + (self.new_camera_y-self.camera_y) / self.lerp_speed

        if self.camera_x > 0 then
            self.camera_x = 0
        end

        if self.camera_y > 0 then
            self.camera_y = 0
        end

        self.camera_x_min = -self.map_size.x  + slack.viewport.x
        self.camera_y_min = -self.map_size.y  + slack.viewport.y
        if self.camera_x < self.camera_x_min then
            self.camera_x = self.camera_x_min
        end

        if self.camera_y < self.camera_y_min then
            self.camera_y = self.camera_y_min
        end
    end
end

function camera:set()
    love.graphics.push()
    love.graphics.translate(self.camera_x, self.camera_y)
end

function camera:unset()
    love.graphics.pop()
end

return camera
