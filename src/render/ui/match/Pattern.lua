local spriteTable = require "src.render.spriteTable"
local RM = require ('src.render.RenderManager'):getInstance()

local moveTexture = love.graphics.newQuad(spriteTable['moveMark'][1] * RM.spriteSize, spriteTable['moveMark'][2] * RM.spriteSize, RM.spriteSize, RM.spriteSize, RM.image)
local attackTexture = love.graphics.newQuad(spriteTable['attackMark'][1] * RM.spriteSize, spriteTable['attackMark'][2] * RM.spriteSize, RM.spriteSize, RM.spriteSize, RM.image)


local Pattern = {}
Pattern.__index = Pattern

function Pattern:new(inputManager)
    local o = {
        inputManager = inputManager,
        moveCanvas = nil,
        attackCanvas = nil,
        patternsPrepared = false
    }
    setmetatable(o, self)
    self.__index = self

    return o
end

function Pattern:loadAnimal(animal)
    self.animal = animal
end

function Pattern:preparePatterns()
    RM.pushScreen()

    local moveCanvasWidth = #self.animal.stats.currentPatterns.movePattern[1] * RM.tileSize
    local moveCanvasHeight = #self.animal.stats.currentPatterns.movePattern * RM.tileSize

    local attackCanvasWidth = #self.animal.stats.currentPatterns.atkPattern[1] * RM.tileSize
    local attackCanvasHeight = #self.animal.stats.currentPatterns.atkPattern * RM.tileSize
    
    self.moveCanvas = love.graphics.newCanvas(moveCanvasWidth, moveCanvasHeight)
    love.graphics.setCanvas(self.moveCanvas)

    for y, row in ipairs(self.animal.stats.currentPatterns.movePattern) do
        for x, cell in ipairs(row) do
            if cell == 1 then
                love.graphics.draw(
                    RM.image, 
                    moveTexture, 
                    (x - 1) * RM.tileSize, 
                    (y - 1) * RM.tileSize,
                    0,
                    RM.increaseFactor, 
                    RM.increaseFactor
                )
            end
        end
    end

    self.attackCanvas = love.graphics.newCanvas(attackCanvasWidth, attackCanvasHeight)
    love.graphics.setCanvas(self.attackCanvas)

    for y, row in ipairs(self.animal.stats.currentPatterns.atkPattern) do
        for x, cell in ipairs(row) do
            if cell == 1 then
                love.graphics.draw(
                    RM.image, 
                    attackTexture, 
                    (x - 1) * RM.tileSize, 
                    (y - 1) * RM.tileSize, 
                    0,
                    RM.increaseFactor, 
                    RM.increaseFactor
                )
            end
        end
    end

    self.moveAdjX = math.floor(#self.animal.stats.currentPatterns.movePattern[1] / 2) * RM.tileSize
    self.moveAdjY = math.floor(#self.animal.stats.currentPatterns.movePattern / 2) * RM.tileSize

    self.attackAdjX = math.floor(#self.animal.stats.currentPatterns.atkPattern[1] / 2) * RM.tileSize
    self.attackAdjY = math.floor(#self.animal.stats.currentPatterns.atkPattern / 2) * RM.tileSize

    love.graphics.pop()
    love.graphics.setCanvas()
end

-- tons of room for optimization for these next 2 functions
function Pattern:drawMovePattern()
    -- local patternX = self.inputManager.hoveredTileX - self.animal.position.x + math.ceil(#self.animal.stats.currentPatterns.movePattern[1] / 2)
    -- local patternY = self.inputManager.hoveredTileY - self.animal.position.y + math.ceil(#self.animal.stats.currentPatterns.movePattern / 2)
    
    -- if patternX <= #self.animal.stats.currentPatterns.movePattern[1]
    -- and patternX > 0 
    -- and patternY <= #self.animal.stats.currentPatterns.movePattern
    -- and patternY > 0 
    -- and self.animal.stats.currentPatterns.movePattern[patternY][patternX] == 1 then
        
    --     love.graphics.setColor(1, 1, 1, 1)
    -- else
        
    --     love.graphics.setColor(1, 1, 1, 0.5) 
    -- end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.moveCanvas, self.animal.position.screenX - self.moveAdjX, self.animal.position.screenY - self.moveAdjY)
end

function Pattern:drawAttackPattern()
    local patternX = self.inputManager.hoveredTileX - self.animal.position.x + math.ceil(#self.animal.stats.currentPatterns.movePattern[1] / 2)
    local patternY = self.inputManager.hoveredTileY - self.animal.position.y + math.ceil(#self.animal.stats.currentPatterns.movePattern / 2)
    
    if patternX <= #self.animal.stats.currentPatterns.movePattern[1]
    and patternX > 0 
    and patternY <= #self.animal.stats.currentPatterns.movePattern
    and patternY > 0 
    and self.animal.stats.currentPatterns.movePattern[patternY][patternX] == 1 then
        self.isInsideMovePattern = true
        love.graphics.setColor(1, 1, 1, 1)
    else
        self.isInsideMovePattern = false
        love.graphics.setColor(1, 1, 1, 0) 
    end
    love.graphics.draw(self.attackCanvas, self.inputManager.hoveredTileX * RM.tileSize - self.attackAdjX, self.inputManager.hoveredTileY * RM.tileSize - self.attackAdjY)
    love.graphics.setColor(1, 1, 1, 1)
end

function Pattern:update(dt) end

return Pattern