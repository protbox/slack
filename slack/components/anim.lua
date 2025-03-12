local anim = slack.node:extend_as("AnimatedSprite")

local anim8 = require "lib.anim8"

function anim:init(parent, prop)
	anim.super.init(self)

	self.parent = parent
	self.alias = "anim"
	self.offset = prop.offset or { x = 0, y = 0 }
	self.pos = { x = self.parent.x+self.offset.x, y = self.parent.y+self.offset.y }
	--self.h_size = prop.h_size or 1
	--self.v_size = prop.v_size or 1
	self.frame_w = prop.frame_w or 16
	self.frame_h = prop.frame_h or 16
	self.filename = prop.filename or ""
	self.angle = 0
	self.flip = false

	local spritesheet = slack.res[self.filename]
	--self.frame_w = spritesheet:getWidth() / self.h_size
	--self.frame_h = spritesheet:getHeight() / self.v_size
	self.grid = anim8.newGrid(self.frame_w, self.frame_h, spritesheet:getDimensions())
	self.state = prop.state or "idle"
	self.anims = {}
end

function anim:add_state(state, row, frames, fps, fn)
	self.anims[state] = anim8.newAnimation(self.grid(frames, row), fps, fn or nil)
end

function anim:set_state(state)
	-- check if it's a blocking state
	if self.anims[self.state].is_blocking then
		local a = self.anims[self.state]
		-- are some states allowed to override the block?
		if a.block_exclude and a.block_exclude[state] then
			-- give it a pass
		else
			-- otherwise back out
			return
		end
	end

	-- if it's a different state, switch the current one back to frame 1
	if self.state ~= state then self.anims[self.state]:gotoFrame(1) end
	self.state = state
end

function anim:get_current_pos()
	return self.anims[self.state].position
end

function anim:update(dt)
	self.anims[self.state]:update(dt)
end

function anim:draw()
	-- draw shadow
	--[[if not self.parent.no_shadow then
		love.graphics.setColor(slack.shadow_color)
	    self.anims[self.state]:draw(
			slack.res[self.filename],
			self.parent.x+2,
			self.parent.y+2,
			self.angle,
	        self.flip and -1 or 1, 1, -- scale
	        self.flip and self.offset.x+self.parent.w or self.offset.x, self.offset.y)

		love.graphics.setColor(1, 1, 1, 1)
	end]]

	self.anims[self.state]:draw(
		slack.res[self.filename],
		self.parent.x,
		self.parent.y,
		self.angle,
        self.flip and -1 or 1, 1, -- scale
        self.flip and self.offset.x+self.parent.w or self.offset.x, self.offset.y)
end

return anim
