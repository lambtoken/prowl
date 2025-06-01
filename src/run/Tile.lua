local spriteTable = require 'src.render.spriteTable'
local RM = require ('src.render.RenderManager'):getInstance()

local Tile = {}
Tile.__index = Tile


function Tile:new(name, type, steppable)
    local o = {
        name = name,
        type = type or 'ground',
        steppable = steppable or false,
        reserved = false,
        quad = nil
    }
    setmetatable(o, self)
    o.__index = self
    o:initialize()

    return o
end

function Tile:initialize()
    if spriteTable[self.name] then
        self.quad = love.graphics.newQuad(
            spriteTable[self.name][1] * RM.spriteSize, 
            spriteTable[self.name][2] * RM.spriteSize, 
            RM.spriteSize, 
            RM.spriteSize, 
            RM.image
        )
    else
        self.quad = love.graphics.newQuad(
            spriteTable['chicken'][1] * RM.spriteSize, 
            spriteTable['chicken'][2] * RM.spriteSize, 
            RM.spriteSize, 
            RM.spriteSize, 
            RM.image
        )
    end
end


return Tile