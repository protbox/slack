-- A majority of the code for this component was taken from Hamdy's LDtk LOVE library. License below!

-- A basic LDtk loader for LÖVE created by Hamdy Elzonqali
-- Last tested with LDtk 0.9.3
--
-- ldtk.lua
--
-- Copyright (c) 2021 Hamdy Elzonqali
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do
-- so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

local LDtk = slack.node:extend_as("LDtk")

local json = require "lib.json"

local cache = {
    tilesets = {

    },
    quods = {

    },
    batch = {

    }
}

local _path

--------- LAYER OBJECT ---------
--This is used as a switch statement for lua. Much better than if-else pairs.
local flipX = {
    [0] = 1,
    [1] = -1,
    [2] = 1,
    [3] = -1
}

local flipY = {
    [0] = 1,
    [1] = 1,
    [2] = -1,
    [3] = -1
}

local oldColor = {}

function LDtk:change_color(c, layers)
    for n,tileset in pairs(cache.tilesets) do
        cache.batch[n] = love.graphics.newSpriteBatch(tileset)
    end
end

--creates the layer object from data. only used here. ignore it
function LDtk.create_layer_object(ldtk, self, data, auto)
    
    self._offsetX = {
        [0] = 0,
        [1] = data.__gridSize,
        [2] = 0,
        [3] = data.__gridSize,
    }

    self._offsetY = {
        [0] = 0,
        [1] = 0,
        [2] = data.__gridSize,
        [3] = data.__gridSize,
    }

    --getting tiles information
    if auto then
        self.tiles = data.autoLayerTiles
        self.intGrid = data.intGridCsv
    else 
        self.tiles = data.gridTiles
        self.intGrid = nil
    end

    self._tilesLen = #self.tiles

    self.relPath = data.__tilesetRelPath
    self.path = ldtk.getPath(data.__tilesetRelPath)

    self.id = data.__identifier
    self.x, self.y = data.__pxTotalOffsetX, data.__pxTotalOffsetY
    self.visible = data.visible
    self.color = {1, 1, 1, data.__opacity}

    self.width = data.__cWid
    self.height = data.__cHei
    self.gridSize = data.__gridSize

    --getting tileset information
    self.tileset = ldtk.tilesets[data.__tilesetDefUid]
    self.tilesetID = data.__tilesetDefUid

    --creating new tileset if not created yet
    if not cache.tilesets[data.__tilesetDefUid] then
        --loading tileset
        cache.tilesets[data.__tilesetDefUid] = slack.res[self.path]

        --creating spritebatch
        cache.batch[data.__tilesetDefUid] = love.graphics.newSpriteBatch(cache.tilesets[data.__tilesetDefUid])

        --creating quads for the tileset
        cache.quods[data.__tilesetDefUid] = {}
        local count = 0
        for ty = 0, self.tileset.__cHei - 1, 1 do
            for tx = 0, self.tileset.__cWid - 1, 1 do
                cache.quods[data.__tilesetDefUid][count] =
                    love.graphics.newQuad(
                        self.tileset.padding + tx * (self.tileset.tileGridSize + self.tileset.spacing),
                        self.tileset.padding + ty * (self.tileset.tileGridSize + self.tileset.spacing),
                        self.tileset.tileGridSize,
                        self.tileset.tileGridSize,
                        cache.tilesets[data.__tilesetDefUid]:getWidth(),
                        cache.tilesets[data.__tilesetDefUid]:getHeight()
                    )
                count = count + 1
            end
        end
    end
end

--draws tiles
local function draw_layer_object(self)
    if self.visible then
        --Saving old color
        oldColor[1], oldColor[2], oldColor[3], oldColor[4] = love.graphics.getColor()

        --Clear batch
        cache.batch[self.tileset.uid]:clear()

        -- Fill batch with quads
         for i = 1, self._tilesLen do
            cache.batch[self.tileset.uid]:add(
                cache.quods[self.tileset.uid][self.tiles[i].t],
                self.x + self.tiles[i].px[1] + self._offsetX[self.tiles[i].f],
                self.y + self.tiles[i].px[2] + self._offsetY[self.tiles[i].f],
                0,
                flipX[self.tiles[i].f],
                flipY[self.tiles[i].f]
            )
        end
        
        --Setting layer color 
        love.graphics.setColor(self.color)
        --Draw batch
        love.graphics.draw(cache.batch[self.tileset.uid])

        --Resotring old color
        love.graphics.setColor(oldColor)
    end
end

----------- HELPER FUNCTIONS ------------
--LDtk uses hex colors while LÖVE uses RGB (on a scale of 0 to 1)
-- Converts hex color to RGB
function LDtk.hex2rgb(hex)
    return { tonumber("0x" .. hex:sub(2,3)) / 255,
           tonumber("0x" .. hex:sub(4,5)) / 255,
           tonumber("0x" .. hex:sub(6,7)) / 255}
end


--Checks if a table is empty.
local function is_empty(t)
    for _, _ in pairs(t) do
        return false
    end
    return true
end

function LDtk:init(parent, prop)
	LDtk.super.init(self)
	
	self.parent = parent
	self.alias = "ldtk"

	self.levels = {}
    self.levelsNames = {}
    self.tilesets = {}
    self.currentLevelIndex = nil
    self.currentLevelName  = ''
    self.flipped = false
    self.cache = cache
	self.data = json.decode(love.filesystem.read(prop.file))
    self.entities = {}
    self.x, self.y = prop.x or 0, prop.y or 0
    self.countOfLevels = #self.data.levels
    self.countOfLayers = #self.data.defs.layers
    
    --creating a table with the path to .ldtk file separated by '/', 
    --used to get the path relative to main.lua instead of the .ldtk file. Ignore it.
    _path = {}
    for str in string.gmatch(prop.file, "([^"..'/'.."]+)") do
        table.insert(_path, str)
    end
    _path[#_path] = nil

    for index, value in ipairs(self.data.levels) do
        self.levels[value.identifier] = index
    end

    for key, value in pairs(self.levels) do
        self.levelsNames[value] = key
    end

    for index, value in ipairs(self.data.defs.tilesets) do
        self.tilesets[value.uid] = self.data.defs.tilesets[index]
    end

    if level then
        self:goto_level(level)
    end
end

function LDtk.getPath(relPath)
    local newPath = ''
    local newRelPath = {}
    local pathLen = #_path

    for str in string.gmatch(relPath, "([^"..'/'.."]+)") do
        table.insert(newRelPath, str)
    end

    for i = #newRelPath, 1, -1 do
        if newRelPath[i] == '..' then
            pathLen = pathLen - 1
            newRelPath[i] = nil
        end
    end

    for i = 1, pathLen, 1 do
        newPath = newPath .. (i > 1 and '/' or '') .. _path[i]
    end

    local keys = {}
    for key, _ in pairs(newRelPath) do
        table.insert(keys, key)
    end
    table.sort(keys)


    local len = #keys
    for i = 1, len, 1 do
        newPath = newPath .. (newPath ~= '' and '/' or '') .. newRelPath[keys[i]]
    end

    return newPath
end

local types = {
    Entities = function (obj, parent, currentLayer, order, level)
        for _, value in ipairs(currentLayer.entityInstances) do
            local props = {}

            for _, p in ipairs(value.fieldInstances) do
                props[p.__identifier] = p.__value
            end

            if parent._ldtk_on_entity then
	            parent:_ldtk_on_entity(obj, {
	                id = value.__identifier,
	                iid = value.iid,
	                x = value.px[1],
	                y = value.px[2],
	                width = value.width,
	                height = value.height,
	                px = value.__pivot[1],
	                py = value.__pivot[2],
	                order = order,
	                visible = currentLayer.visible,
	                props = props
	            }, level)
	        end
        end
    end,

    Tiles = function (obj, parent, currentLayer, order, level)
        if not is_empty(currentLayer.gridTiles) then
            local layer = {draw = draw_layer_object}
            LDtk.create_layer_object(obj, layer, currentLayer, false)
            layer.order = order
            if parent._ldtk_on_layer then parent:_ldtk_on_layer(obj, layer, level) end
        end
    end,

    IntGrid = function (obj, parent, currentLayer, order, level)
        if not is_empty(currentLayer.autoLayerTiles) and currentLayer.__tilesetDefUid then
            local layer = {draw = draw_layer_object}
            LDtk.create_layer_object(obj, layer, currentLayer, true)
            layer.order = order
            if parent._ldtk_on_layer then parent:_ldtk_on_layer(obj, layer, level) end
        end
    end,

    AutoLayer = function (obj, parent, currentLayer, order, level)
        if not is_empty(currentLayer.autoLayerTiles) and currentLayer.__tilesetDefUid then
            local layer = {draw = draw_layer_object}
            LDtk.create_layer_object(obj, layer, currentLayer, true)
            layer.order = order
            if parent._ldtk_on_layer then parent:_ldtk_on_layer(obj, layer, level) end
        end
    end
}


--Load a level by its index (int)
function LDtk:goto_level(index)
    if index > self.countOfLevels or index < 1 then
        error('There are no levels with that index.')
    end

    self.currentLevelIndex = index
    self.currentLevelName  = self.levelsNames[index]

    local layers
    if self.data.externalLevels then
        layers = json.decode(love.filesystem.read(self.getPath(self.data.levels[index].externalRelPath))).layerInstances
    else
        layers = self.data.levels[index].layerInstances
    end
    
    local levelProps = {}
    for _, p in ipairs(self.data.levels[index].fieldInstances) do
        levelProps[p.__identifier] = p.__value
    end

    local levelEntry = {
        backgroundColor = LDtk.hex2rgb(self.data.levels[index].__bgColor),
        id = self.data.levels[index].identifier,
        worldX  = self.data.levels[index].worldX,
        worldY = self.data.levels[index].worldY,
        width = self.data.levels[index].pxWid,
        height = self.data.levels[index].pxHei,
        neighbours = self.data.levels[index].__neighbours,
        index = index,
        bg_image = self.data.levels[index].bgRelPath and self.data.levels[index].bgRelPath or false,
        props = levelProps
    }

    if self.parent._ldtk_on_level_loaded then self.parent:_ldtk_on_level_loaded(self, levelEntry) end

    

    if self.flipped then
        for i = self.countOfLayers, 1, -1 do
            types[layers[i].__type](self, self.parent, layers[i], i, levelEntry)
        end    
    else
        for i = 1, self.countOfLayers do
            types[layers[i].__type](self, self.parent, layers[i], i, levelEntry)
        end
    end
    

    if self.parent._ldtk_on_level_ready then self.parent:_ldtk_on_level_ready(self, levelEntry) end
end

--loads a level by its name (string)
function LDtk:level(name)
    self:goto_level(self.levels[tostring(name)] or error('There are no levels with the name: "' .. tostring(name) .. '".\nDid you save? (ctrl +s)'))
end

--loads next level
function LDtk:next()
    self:goto_level(self.currentLevelIndex + 1 <= self.countOfLevels and self.currentLevelIndex + 1 or 1)
end

--loads previous level
function LDtk:previous()
    self:goto_level(self.currentLevelIndex - 1 >= 1 and self.currentLevelIndex - 1 or self.countOfLevels)
end

--reloads current level
function LDtk:reload()
    self:goto_level(self.currentLevelIndex)
end

--gets the index of a specific level
function LDtk.getIndex(name)
    return ldtk.levels[name]
end

--get the name of a specific level
function LDtk.getName(index)
    return ldtk.levelsNames[index]
end

--gets the current level index
function LDtk:getCurrent()
    return self.currentLevelIndex
end

--get the current level name
function LDtk:getCurrentName()
    return ldtk.levelsNames[self:getCurrent()]
end

--sets whether to invert the loop or not
function LDtk:setFlipped(flipped)
    self.flipped = flipped
end

--gets whether the loop is inverted or not
function LDtk:getFlipped()
    return self.flipped
end

--remove the cahced tiles and quods. you may use it if you have multiple .ldtk files
function LDtk.removeCache()
    cache = {
        tilesets = {
            
        },
        quods = {
            
        },
        batch = {

        }
    }
    collectgarbage()
end

--[[function LDtkdraw()
	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.draw(
		slack.res[self.filename],
		self.parent.x,
		self.parent.y,
		self.angle,
        self.flip and -1 or 1, 1, -- scale
        self.flip and self.offset.x+self.parent.w or self.offset.x, self.offset.y)
end]]

return LDtk