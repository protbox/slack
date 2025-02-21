local scene = slack.node:extend_as("Scene")

function scene:init()
	scene.super.init(self)

	self.ent_mgr = slack.ent_manager()
	love.graphics.setBackgroundColor(slack.col[1])
end

function scene:_ready() end

function scene:update(dt)
	scene.super.update(self, dt)

	self.ent_mgr:update(dt)
end

function scene:draw()
	love.graphics.setColor(1, 1, 1, 1)

	scene.super.draw(self)
	self.ent_mgr:draw()
end

function scene:mousepressed(x, y, button, istouch, presses)
end

function scene:mousereleased(x, y, button)
end

function scene:keypressed(key, sc)
end

return scene
