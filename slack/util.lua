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

function util.get_quads(sheet, tsize, theight)
    local i = 1
    local w = tsize
    local h = theight or w
    local sw, sh = sheet:getDimensions()
    local quads = {}
    for y = 0, (sh/h) - 1 do
        for x = 0, (sw/w) - 1 do
            quads[i] = love.graphics.newQuad(x*w, y*h, w, h, sw, sh)
            i = i + 1
        end
    end

    return quads
end

return util