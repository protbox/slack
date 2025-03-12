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

function util.get_quads(sheet, tsize)
    local i = 1
    local tsize = tsize or 16
    local sw, sh = sheet:getDimensions()
    local quads = {}
    for y = 0, (sh/tsize) - 1 do
        for x = 0, (sw/tsize) - 1 do
            quads[i] = love.graphics.newQuad(x*tsize, y*tsize, tsize, tsize, sw, sh)
            i = i + 1
        end
    end

    return quads
end

return util