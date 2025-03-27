local RM = require ('src.render.RenderManager'):getInstance()
local getFont = require 'src.render.getFont'
local spriteTable = require 'src.render.spriteTable'

local animalStats = {}
animalStats.__index = animalStats

function animalStats:new()
    local o = {
        animalRef = nil,
        font = getFont('basis33', 18),
        portraitSize = 48,
        hpBarWidth = 100,
        hpBarHeight = 20,
        margin = 10,
        portraitQuad = nil,
    }

    o.textHeight = o.font:getHeight()
    o.width = o.portraitSize + o.hpBarWidth + 3 * o.margin
    o.height = o.portraitSize + 2 * o.textHeight + 4 * o.margin
    o.screenX = 0
    o.screenY = RM.windowHeight - o.height

    setmetatable(o, self)
    o.__index = self

    return o
end

function animalStats:loadAnimal(animal)
    self.animalRef = animal
    if animal and animal.metadata.type == 'animal' then
        local species = animal.metadata.species
        self.portraitQuad = love.graphics.newQuad(spriteTable[species][1] * RM.spriteSize, spriteTable[species][2] * RM.spriteSize, RM.spriteSize, RM.spriteSize, RM.image)
        self.portraitScaleFactor = self.portraitSize / RM.spriteSize
    end
end

function animalStats:draw()

    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', self.screenX, self.screenY, self.width, self.height)

    local i = 0

    local species = self.animalRef.metadata.species
    local level = self.animalRef.stats.level
    local atk = self.animalRef.stats.current.atk
    local def = self.animalRef.stats.current.def
    local hp = self.animalRef.stats.current.hp
    local maxHp = self.animalRef.stats.current.maxHp
    local crit = self.animalRef.stats.current.crit
    local ls = self.animalRef.stats.current.lifeSteal

    love.graphics.setColor(1, 1, 1)

    love.graphics.draw(RM.image, self.portraitQuad, self.screenX + self.margin, self.screenY + self.margin, 0, self.portraitScaleFactor, self.portraitScaleFactor)

    local currentHpBarWidth = self.hpBarWidth * hp / maxHp

    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", self.screenX + self.portraitSize + 2 * self.margin, self.screenY + self.margin + self.portraitSize - self.hpBarHeight, self.hpBarWidth, self.hpBarHeight)
    
    local green = hp / maxHp
    local red = 1 - green + (1 - green) * 0.2

    love.graphics.setColor(red, green, 0.4)
    love.graphics.rectangle("fill", self.screenX + self.portraitSize + 2 * self.margin, self.screenY + self.margin + self.portraitSize - self.hpBarHeight, currentHpBarWidth, self.hpBarHeight)

    love.graphics.setColor(1, 1, 1)

    love.graphics.setFont(self.font)
    love.graphics.print(species, self.screenX + self.portraitSize + 2 * self.margin, self.screenY + self.margin)

    local statsLeftColX =  self.screenX + self.margin
    local statsRightColX =  self.screenX + self.margin + (self.width - 2 * self.margin) / 2
    local statsFirstRowY =  self.screenY + 2 * self.margin + self.portraitSize 
    local statsSecondRowY =  self.screenY + 3 * self.margin + self.portraitSize + self.textHeight

    local hpX = self.screenX + self.portraitSize + 2 * self.margin + self.hpBarWidth / 2 
    local hpY = self.screenY + self.margin + self.portraitSize - self.hpBarHeight

    local hpText = hp .. '/' .. maxHp

    love.graphics.print(hpText, hpX - self.font:getWidth(hpText) / 2, hpY)

    love.graphics.print('atk: ' .. atk, statsLeftColX, statsFirstRowY)
    love.graphics.print('def: ' .. def, statsRightColX, statsFirstRowY)
    love.graphics.print('crit: ' .. crit, statsLeftColX, statsSecondRowY)
    love.graphics.print('ls: ' .. ls, statsRightColX, statsSecondRowY)

    local levelX = self.screenX + self.width - self.margin - self.font:getWidth(level)
    local levelY = self.screenY + self.margin

    love.graphics.print(level, levelX, self.screenY + self.margin)

end

return animalStats