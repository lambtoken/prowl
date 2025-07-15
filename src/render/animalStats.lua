local RM = require ('src.render.RenderManager'):getInstance()
local getFont = require 'src.render.getFont'
local spriteTable = require 'src.render.spriteTable'
local statusBar = require 'src.render.ui.match.StatusBar'

local animalStats = {}
animalStats.__index = animalStats

function animalStats:new()
    local o = {
        animalRef = nil,
        font = getFont('basis33', 24),
        portraitSize = 64,
        hpBarWidth = 150,
        hpBarHeight = 25,
        margin = 15,
        portraitQuad = nil,
        itemSize = 40,
        maxItems = 8,
        animationTime = 0,
        animationSpeed = 2,
        animationAmplitude = 2,
    }

    o.textHeight = o.font:getHeight()
    o.width = o.portraitSize + o.hpBarWidth + 3 * o.margin
    o.height = o.portraitSize + 2 * o.textHeight + 4 * o.margin
    o.screenX = 0
    o.screenY = RM.windowHeight - o.height

    o.statusBar = statusBar:new()

    setmetatable(o, self)
    o.__index = self

    return o
end

function animalStats:positionStatusBar()
    self.statBoxSize = self.portraitSize + 2 * self.margin + self.hpBarWidth + 2 * self.margin
    self.itemsStartX = self.screenX + self.statBoxSize
    self.itemsStartY = RM.windowHeight - self.itemSize - self.margin
    self.itemSpacing = self.itemSize + self.margin

    self.statusBar.container:setPos(
        self.itemsStartX, 
        RM.windowHeight - self.statusBar.container.ch - self.itemSize * 2
    )
end

function animalStats:loadAnimal(animal)
    self.animalRef = animal
    if animal and animal.metadata.type == 'animal' then
        local species = animal.metadata.name
        self.portraitQuad = love.graphics.newQuad(spriteTable[species][1] * RM.spriteSize, spriteTable[species][2] * RM.spriteSize, RM.spriteSize, RM.spriteSize, RM.image)
        self.portraitScaleFactor = self.portraitSize / RM.spriteSize
        self.statusBar:updateEffectIcons(animal)
        self:positionStatusBar()
        self.statusBar.root:resize()
        -- print(self.statusBar.container.cx, self.statusBar.container.cy)
    end
end

function animalStats:update(dt)
    self.animationTime = self.animationTime + dt * self.animationSpeed
    self.statusBar:update(dt)
end

function animalStats:draw()
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill', self.screenX, self.screenY, self.width, self.height)

    local i = 0

    local species = self.animalRef.metadata.name
    local level = self.animalRef.stats.level
    local atk = self.animalRef.stats.current.atk
    local def = self.animalRef.stats.current.def
    local hp = self.animalRef.stats.current.hp
    local maxHp = self.animalRef.stats.current.maxHp
    local crit = self.animalRef.stats.current.crit
    local ls = self.animalRef.stats.current.lifeSteal
    local energy = self.animalRef.stats.energy or 1
    local maxEnergy = self.animalRef.stats.energy or 1
    local energyBarWidth = self.hpBarWidth
    local energyBarHeight = 12
    local currentEnergyBarWidth = energyBarWidth * energy / maxEnergy
    local hpBarY = self.screenY + self.margin + self.portraitSize - self.hpBarHeight + math.sin(self.animationTime) * self.animationAmplitude
    local energyBarY = hpBarY + self.hpBarHeight + 8

    love.graphics.setColor(1, 1, 1)

    love.graphics.draw(RM.image, self.portraitQuad, self.screenX + self.margin, self.screenY + self.margin, 0, self.portraitScaleFactor, self.portraitScaleFactor)

    local currentHpBarWidth = self.hpBarWidth * hp / maxHp

    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", self.screenX + self.portraitSize + 2 * self.margin, hpBarY, self.hpBarWidth, self.hpBarHeight)
    
    local green = hp / maxHp
    local red = 1 - green + (1 - green) * 0.2

    love.graphics.setColor(red, green, 0.4)
    love.graphics.rectangle("fill", self.screenX + self.portraitSize + 2 * self.margin, hpBarY, currentHpBarWidth, self.hpBarHeight)

    love.graphics.setColor(1, 1, 1)

    love.graphics.setFont(self.font)
    love.graphics.print(species, self.screenX + self.portraitSize + 2 * self.margin, self.screenY + self.margin)

    local statsLeftColX =  self.screenX + self.margin
    local statsRightColX =  self.screenX + self.margin + (self.width - 2 * self.margin) / 2
    local statsFirstRowY =  self.screenY + 2 * self.margin + self.portraitSize 
    local statsSecondRowY =  self.screenY + 3 * self.margin + self.portraitSize + self.textHeight

    local hpX = self.screenX + self.portraitSize + 2 * self.margin + self.hpBarWidth / 2 
    local hpY = hpBarY

    local hpText = hp .. '/' .. maxHp

    love.graphics.print(hpText, hpX - self.font:getWidth(hpText) / 2, hpY)

    love.graphics.print('atk: ' .. atk, statsLeftColX, statsFirstRowY)
    love.graphics.print('def: ' .. def, statsRightColX, statsFirstRowY)
    love.graphics.print('crit: ' .. crit, statsLeftColX, statsSecondRowY)
    love.graphics.print('ls: ' .. ls, statsRightColX, statsSecondRowY)

    local levelX = self.screenX + self.width - self.margin - self.font:getWidth(level)
    local levelY = self.screenY + self.margin

    love.graphics.print(level, levelX, self.screenY + self.margin)

    self.statBoxSize = self.portraitSize + 2 * self.margin + self.hpBarWidth + 2 * self.margin
    self.itemsStartX = self.screenX + self.statBoxSize
    self.itemsStartY = RM.windowHeight - self.itemSize - self.margin
    self.itemSpacing = self.itemSize + self.margin

    -- drawing empty slots
    for i = 1, self.maxItems do
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("line", self.itemsStartX + (i-1) * self.itemSpacing, self.itemsStartY, self.itemSize, self.itemSize)
    end

    -- drawing items
    if self.animalRef.inventory and self.animalRef.inventory.items then
        for i, item in ipairs(self.animalRef.inventory.items) do
            if i <= self.maxItems then
                love.graphics.setColor(1, 1, 1)
                local itemQuad = love.graphics.newQuad(spriteTable[item.name][1] * RM.spriteSize, spriteTable[item.name][2] * RM.spriteSize, RM.spriteSize, RM.spriteSize, RM.image)
                local itemScale = self.itemSize / RM.spriteSize
                love.graphics.draw(RM.image, itemQuad, self.itemsStartX + (i-1) * self.itemSpacing, self.itemsStartY, 0, itemScale, itemScale)
            end
        end
    end

    self.statusBar:draw()
end

return animalStats