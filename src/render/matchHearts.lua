local RM = require ('src.render.RenderManager'):getInstance()
local spriteTable = require 'src.render.spriteTable'

local hearts = {}
hearts.__index = hearts

function hearts:new(playerRef)
    local o = {
        player = playerRef
    }
    setmetatable(o, self)
    o.__index = self

    return o
end

function hearts:draw()
    local quad = love.graphics.newQuad(spriteTable["heart_empty"][1] * RM.spriteSize, spriteTable["heart_empty"][2] * RM.spriteSize, RM.spriteSize, RM.spriteSize, RM.image)

    for i = 1, self.player.stats.current.maxHp do
        love.graphics.draw(RM.image, quad,  math.floor((i - 1) * (RM.tileSize - 10)), 0 * RM.tileSize, 0, RM.increaseFactor)
    end

    quad = love.graphics.newQuad(spriteTable["heart"][1] * RM.spriteSize, spriteTable["heart"][2] * RM.spriteSize, RM.spriteSize, RM.spriteSize, RM.image)

    for i = 1, self.player.stats.current.hp do
        love.graphics.draw(RM.image, quad,  math.floor((i - 1) * (RM.tileSize - 10)), 0 * RM.tileSize, 0, RM.increaseFactor)
    end
end


return hearts