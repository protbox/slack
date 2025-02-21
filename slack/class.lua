local class = {}
class.__index = class

-- initializer
function class:init() end

function class:extend_as(name)
    local cls = {}
    cls["__call"] = class.__call
    cls.__index = cls
    cls.super = self
    cls.__name = name or "Anonymoose"
    setmetatable(cls, self)
    return cls
end

function class:is(name)
    return self.__name == name
end

function class:__call(...)
    local inst = setmetatable({}, self)
    inst:init(...)
    return inst
end

return class
