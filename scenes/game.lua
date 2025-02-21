local game = slack.level:extend_as("Game")

function game:init()
	game.super.init(self)
end

function game:_ready()
end

function game:update(dt)
	game.super.update(self, dt)
end

function game:draw()
	game.super.draw(self)
end

return game