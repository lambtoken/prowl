local RM = require ('src.render.RenderManager'):getInstance()
local spriteTable = require 'src.render.spriteTable'

local FIELD_SIZE = 28

local quads = {
    dot = love.graphics.newQuad(
        spriteTable["pattern_dots"][1] * RM.spriteSize, 
        spriteTable["pattern_dots"][2] * RM.spriteSize, 
        7, 
        7, 
        RM.image
    ),
    remove = love.graphics.newQuad(
        spriteTable["pattern_remove"][1] * RM.spriteSize, 
        spriteTable["pattern_remove"][2] * RM.spriteSize, 
        7, 
        7, 
        RM.image
    ),
    dir = {}
}

for i = 1, 3 do
    quads.dir[i] = {}
    for j = 1, 3 do
        if not (x == 2 and y == 2) then
            quads.dir[i][j] = love.graphics.newQuad(
                spriteTable["pattern_dir"][1] * RM.spriteSize + (j - 1) * 7, 
                spriteTable["pattern_dir"][2] * RM.spriteSize + (i - 1) * 7, 
                7, 
                7, 
                RM.image
            )
        end
    end
    
end


local Pattern = {}
Pattern.__index = Pattern

function Pattern:new(patternData) 
    local o = {
        patternData = patternData,
    }

    setmetatable(o, self)
    o.__index = self

    return o
end

function Pattern:init()
    self.width = #self.patternData[3][1] * FIELD_SIZE
    self.height = #self.patternData[3] * FIELD_SIZE
    self.fieldScaleFactor = FIELD_SIZE / 7
end

function Pattern:draw(offsetX, offsetY)

    love.graphics.push()

    love.graphics.translate(offsetX, offsetY)

    love.graphics.setColor(0,0,0,1)
    love.graphics.rectangle("fill", self.screenX, self.screenY, self.width, self.height)
    
    love.graphics.setColor(1,1,1)

    local patternType = self.patternData[1]
    local patternShape = self.patternData[3]

    if patternType == "add" then
        for y, row in ipairs(patternShape) do
            for x, field in ipairs(row) do
                if y == math.ceil(#patternShape / 2) and x == math.ceil(#patternShape[1] / 2) then
                    love.graphics.setColor(0.3, 0.3, 0.3)
                    love.graphics.rectangle("fill", self.screenX + (x - 1) * FIELD_SIZE, self.screenY + (y - 1) * FIELD_SIZE, FIELD_SIZE, FIELD_SIZE)
                end

                if field == 1 then
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.draw(RM.image, quads.dot, self.screenX + (x - 1) * FIELD_SIZE, self.screenY + (y - 1) * FIELD_SIZE, 0, self.fieldScaleFactor, self.fieldScaleFactor)
                end
            end
        end

    elseif patternType == "extend" then
        for y, row in ipairs(patternShape) do
            for x, field in ipairs(row) do
                if y == math.ceil(#patternShape / 2) and x == math.ceil(#patternShape[1] / 2) then
                    love.graphics.setColor(0.3, 0.3, 0.3)
                    love.graphics.rectangle("fill", self.screenX + (x - 1) * FIELD_SIZE, self.screenY + (y - 1) * FIELD_SIZE, FIELD_SIZE, FIELD_SIZE)
                end
                if field == 1 and not (x == 2 and y == 2) then
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.draw(RM.image, quads.dir[y][x], self.screenX + (x - 1) * FIELD_SIZE, self.screenY + (y - 1) * FIELD_SIZE, 0, self.fieldScaleFactor, self.fieldScaleFactor)
                end
            end
       end
    
    elseif patternType == "remove" then
        for y, row in ipairs(patternShape) do
            for x, field in ipairs(row) do
                if y == math.ceil(#patternShape / 2) and x == math.ceil(#patternShape[1] / 2) then
                    love.graphics.setColor(0.3, 0.3, 0.3)
                    love.graphics.rectangle("fill", self.screenX + (x - 1) * FIELD_SIZE, self.screenY + (y - 1) * FIELD_SIZE, FIELD_SIZE, FIELD_SIZE)
                end
                if field == 1 and not (x == 2 and y == 2) then
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.draw(RM.image, quads.remove, self.screenX + (x - 1) * FIELD_SIZE, self.screenY + (y - 1) * FIELD_SIZE, 0, self.fieldScaleFactor, self.fieldScaleFactor)
                end
            end
        end 
    end


    love.graphics.setColor(0.3, 0.3, 0.3)

    for y = 1, #patternShape + 1 do
        for x = 1, #patternShape[1] + 1 do
            love.graphics.line(self.screenX, self.screenY + (y - 1) * FIELD_SIZE, self.screenX + self.width, self.screenY + (y - 1) * FIELD_SIZE)
            love.graphics.line(self.screenX + (y - 1) * FIELD_SIZE, self.screenY, self.screenX + (y - 1) * FIELD_SIZE, self.screenY + self.height)
        end
    end

    love.graphics.pop()
    love.graphics.setColor(1,1,1)
end

function Pattern:mousemoved(x, y)
    if x >= self.screenX and y >= self.screenY and x <= (self.screenX + self.width) and y <= (self.screenY + self.height) then
        return true
    end
end

function Pattern:mousepressed(x, y, btn)
    if x >= self.screenX and y >= self.screenY and x <= self.screenX + self.width and y <= self.screenY + self.height then
        return true
    end
    return false
end

function Pattern:mousereleased(x, y, btn)
    if x > self.screenX and y > self.screenY and x < self.screenX + self.width and y < self.screenY + self.height then
        return true
    end
    return false
end

return Pattern