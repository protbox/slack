require "slack.run"

love.graphics.setDefaultFilter("nearest", "nearest")

slack.util = require "slack.util"
slack.class = require "slack.class"

function class_name(n)
	return slack.class:extend_as(n)
end

slack.node = require "slack.node"
slack.scene = require "slack.scene"
slack.level = require "slack.level"

--slack.font = love.graphics.newFont(SLACK_PATH .. "/res/gravreg_mod.ttf", 5)

slack.font = love.graphics.newImageFont(
	"slack/res/text.png",
	" abcdefghijklmnopqrstuvwxyz!\"$%+-*/.,'#=:()[]{}`|?\\@0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ<>;&"
)

-- load components
for _, file in ipairs(love.filesystem.getDirectoryItems("slack/components")) do
	local name = file:gsub(".lua$", "")
	local path = "slack.components." .. name
	slack.components[name] = require(path)
	print("[slack] Component '" .. name .. "' loaded")
end

slack.scene_manager = require "slack.managers.scene_manager"
slack.ent_manager = require "slack.managers.ent_manager"

slack.col = {}

-- setup input
local baton = require "lib.baton"
love.joystick.loadGamepadMappings("slack/res/gamecontrollerdb.txt")
local joystick = love.joystick.getJoysticks()[1]

slack.input = baton.new({ controls = slack.controls, joystick = joystick })

local function file_is_type(file)
	local ext = slack.util.get_ext(file)

	if ext == "png" or ext == "jpg" or ext == "jpeg" then
		return "Image"

	elseif ext == "mp3" or ext == "wav" or ext == "flac" or ext == "ogg" then
		return "Audio"
	end
end

function slack.load_assets(folder)
	local files_table = love.filesystem.getDirectoryItems(folder)
	for i,v in ipairs(files_table) do
		local file = folder.."/"..v
		local info = love.filesystem.getInfo(file)
		if info then
			if info.type == "file" then
				if file_is_type(file) == "Image" then
					slack.res[file] = love.graphics.newImage(file)
					print("[slack] Added image asset '" .. file .. "'")
				
				elseif file_is_type(file) == "Audio" then
					-- is file is located in res/music we want to stream
					-- otherwise static
					local is_stream = false
					if string.find(file, "res/music/") or string.find(file, "res\\music\\") then
						is_stream = true
					end

					slack.res[file] = love.audio.newSource(file, is_stream and "stream" or "static")
					print("[slack] Added audio asset '" .. file .. "' as " .. slack.res[file]:getType())
				end

			elseif info.type == "directory" then
				slack.load_assets(file)
			end
		end
	end
end

function slack.load_palette(path)
    local image_data = love.image.newImageData(path)
    local width, height = image_data:getDimensions()
    
    local cell_size = 8
    local cols = 8
    local rows = math.floor(height / cell_size)
    
    for row = 0, rows - 1 do
        for col = 0, cols - 1 do
            local x = col * cell_size + cell_size / 2
            local y = row * cell_size + cell_size / 2
            
            local r, g, b, a = image_data:getPixel(x, y)
            
            local index = row * cols + col + 1
            slack.col[index] = {r, g, b, a}
        end
    end
end

function snd(f)
    local s = "res/sfx/" .. f
    slack.res[s]:stop()
    slack.res[s]:play()
end
