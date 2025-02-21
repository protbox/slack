require "slack"

local res = require "slack.res"

function love.load()
	love.graphics.setFont(slack.font)
	slack.load_assets("res")
	
	slack.scene_manager:add({
		"scenes.game"
	})
	slack.scene_manager:switch("scenes.game")
end

function love.update(dt)
	slack.input:update(dt)
	slack.scene_manager:update(dt)
end

function love.draw()
	res.set(slack.viewport.x, slack.viewport.y)
	slack.scene_manager:draw()
	res.unset()
end

-- if making an app instead of game, these may be more useful than baton
--[[
function love.keypressed(key, sc)
	slack.scene_manager.current:keypressed(key, sc)
end

function love.keyreleased(key, sc)
	slack.scene_manager.current:keyreleased(key, sc)
end

function love.mousepressed(x, y, btn)
	local x, y = res.get_mouse_position(slack.viewport.x, slack.viewport.y)
	slack.scene_manager.current:mousepressed(x, y, btn)
end

function love.mousereleased(x, y, btn)
	local x, y = res.get_mouse_position(slack.viewport.x, slack.viewport.y)
	slack.scene_manager.current:mousereleased(x, y, btn)
end

function love.mousemoved(x, y, dx, dy)
	local x, y = res.get_mouse_position(slack.viewport.x, slack.viewport.y)
	slack.scene_manager.current:mousemoved(x, y, dx, dy)
end

function love.textinput(text)
	slack.scene_manager.current:textinput(text)
end
]]