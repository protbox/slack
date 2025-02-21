local node = class_name "Node"

function node:init(x, y, w, h, prop)
	self.components = {}
	self.x = x or 0
	self.y = y or 0
	self.w = w or 0
	self.h = h or 0
	self.prop = prop or {}
end

function node:add(comp, prop)
	if not slack.components[comp] then
		print("[ERROR] Invalid component '" .. comp .. "'")
		love.event.quit()
	end

	local new_comp = slack.components[comp](self, prop)
	self[new_comp.alias or string.lower(comp)] = new_comp
	table.insert(self.components, new_comp)
end

function node:update(dt)
	for _,comp in ipairs(self.components) do
		comp:update(dt)
	end
end

function node:draw()
	for _,comp in ipairs(self.components) do
		comp:draw()
	end
end

return node