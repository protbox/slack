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

-- arne 16 palette
slack.col = {
	[1] = slack.util.hex_to_color("000000"), 	-- black
	[2] = slack.util.hex_to_color("9d9d9d"),	-- light grey
	[3] = slack.util.hex_to_color("ffffff"),	-- white
	[4] = slack.util.hex_to_color("be2633"),	-- red
	[5] = slack.util.hex_to_color("e06f8b"),	-- pink
	[6] = slack.util.hex_to_color("493c2b"),	-- brown dark
	[7] = slack.util.hex_to_color("a46422"),	-- brown 2
	[8] = slack.util.hex_to_color("eb8931"),	-- brown 3
	[9] = slack.util.hex_to_color("f7e26b"),	-- yellow
	[10] = slack.util.hex_to_color("2f484e"),	-- dark grey
	[11] = slack.util.hex_to_color("44891a"),	-- dark green
	[12] = slack.util.hex_to_color("a3ce27"),	-- light green
	[13] = slack.util.hex_to_color("1b2632"),	-- navy blue
	[14] = slack.util.hex_to_color("005784"),	-- dark blue
	[15] = slack.util.hex_to_color("31a2f2"),	-- light blue
	[16] = slack.util.hex_to_color("b2dcef")	-- sky blue
}

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