local util = {}

function util.get_ext(path)
	local ext = path:match("^.+(%..+)$")
	return ext:sub(2, #ext)
end

function util.hex_to_color(hex, alpha)
    return { tonumber("0x" .. hex:sub(1,2)) / 255,
           tonumber("0x" .. hex:sub(3,4)) / 255,
           tonumber("0x" .. hex:sub(5,6)) / 255,
           alpha or 1 }
end

return util