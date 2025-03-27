local RM = require ('src.render.RenderManager'):getInstance()
local Pattern = require 'src.render.ui.pattern'
local getFont = require 'src.render.getFont'
local items = require('src.generation.items')
local stringFormater = require('src.utility.stringFormater')


local ItemDetails = {}
ItemDetails.__index = ItemDetails

function ItemDetails:new(itemName)
    local o = {
        itemData = items[itemName],
        margin = 10,
        font = getFont('basis33', 15),
        nameFont = getFont('basis33', 25),
        patternFont = getFont('basis33', 20),
        width = 300,
        screenX = 0,
        screenY = 0,
        statsScreenX = 0,
        statsScreenY = 0,
        statsHeight = 0,
        patternsScreenX = 0,
        patternsScreenY = 0,
        patternsHeight = 0,
        passiveScreenX = 0,
        passiveScreenY = 0,
        passiveHeight = 0,
    }
        
    setmetatable(o, self)
    o.__index = self

    return o
end


function ItemDetails:init()
    
    if self.itemData.pattern and #self.itemData.pattern > 0 then
        self.patterns = {}
        for index, pattern in ipairs(self.itemData.pattern) do
            local p = Pattern:new(pattern)
            p:init()
            table.insert(self.patterns, p)
        end
    end

    self:positionElements()
    
    self.height = 2 * self.margin + self.nameFont:getHeight() + self.statsHeight + self.patternsHeight + self.passiveHeight

    if self.statsHeight > 0 then
        self.height = self.height + self.margin
    end

    if self.patternsHeight > 0 then
        self.height = self.height + self.margin
    end

end


function ItemDetails:positionElements()

    --stats
    if self.itemData.stats and #self.itemData.stats > 0 then
        self.statsScreenX = self.margin
        -- uga buga doubled the margins
        self.statsScreenY = 4 * self.margin + self.nameFont:getHeight()
        self.statsHeight = #self.itemData.stats * self.font:getHeight() + (#self.itemData.stats - 1) * self.margin
    else
        self.statsScreenY = 2 * self.margin + self.nameFont:getHeight()
    end

    -- patterns
    if self.itemData.pattern and #self.itemData.pattern > 0 then
        self.patternScreenY = self.statsScreenY and self.statsScreenY + self.statsHeight or (self.screenY + 2 * self.margin + self.nameFont:getHeight())
                              
        for index, pattern in ipairs(self.patterns) do
            pattern.screenX = self.margin
            pattern.screenY = self.patternScreenY + self.patternsHeight + index * (self.patternFont:getHeight() + self.margin)
            self.patternsHeight = self.patternsHeight + pattern.height + 2 * self.margin + self.patternFont:getHeight()
        end
    else
        self.patternsScreenY = self.statsScreenY
    end

    -- passive
    if self.itemData.passive and self.itemData.passive.description then
        self.passiveScreenX = self.margin
        self.passiveScreenY = self.patternsScreenY

        self.formatedPassive = stringFormater(self.itemData.passive.description, self.font, self.width - self.margin * 2)

        self.passiveHeight = #self.formatedPassive * self.font:getHeight() + (#self.formatedPassive - 1) * self.margin

    else
        self.passiveScreenY = self.patternsScreenY
    end
end


function ItemDetails:drawStats(stats, index)
    if stats[1] == 'increase' then
        love.graphics.print('+' .. stats[3] .. ' ' .. stats[2], self.screenX + self.statsScreenX, self.screenY + self.statsScreenY + index * self.font:getHeight() + (index - 1) * self.margin)
    elseif stats[1] == 'decrease' then
        love.graphics.print('-' .. stats[3] .. ' ' .. stats[2], self.screenX + self.statsScreenX, self.screenY + self.statsScreenY + index * self.font:getHeight() + (index - 1) * self.margin)
    elseif stats[1] == 'increaseP' then
        love.graphics.print('+' .. stats[3] .. '% ' .. stats[2], self.screenX + self.statsScreenX, self.screenY + self.statsScreenY + index * self.font:getHeight() + (index - 1) * self.margin)
    elseif stats[1] == 'decreaseP' then
        love.graphics.print('-' .. stats[3] .. '% ' .. stats[2], self.screenX + self.statsScreenX, self.screenY + self.statsScreenY + index * self.font:getHeight() + (index - 1) * self.margin)
    elseif stats[1] == 'swap' then
        love.graphics.print('swap ' .. stats[2] .. ' with ' .. stats[3], self.screenX + self.statsScreenX, self.screenY + self.statsScreenY + index * self.font:getHeight() + (index - 1) * self.margin)
    end
end


function ItemDetails:draw()

    love.graphics.setColor(0,0,0,1)
    love.graphics.rectangle("fill", self.screenX, self.screenY, self.width, self.height)

    love.graphics.setColor(1,1,1)
    love.graphics.setFont(self.nameFont)

    love.graphics.print(self.itemData.name, self.screenX + self.margin, self.screenY + self.margin)

    if self.itemData.stats and #self.itemData.stats > 0 then
        love.graphics.setFont(self.font)
        for index, stats in ipairs(self.itemData.stats) do
            self:drawStats(stats, index - 1)
        end
    end

    if self.patterns then
        love.graphics.setFont(self.patternFont)

        for index, pattern in ipairs(self.patterns) do
            love.graphics.print(pattern.patternData[1] .. '-' .. pattern.patternData[2], self.screenX + pattern.screenX, self.screenY + pattern.screenY - self.patternFont:getHeight())
            pattern:draw(self.screenX, self.screenY)
        end
    end

    if self.formatedPassive then
        love.graphics.setFont(self.font)

        for i, row in ipairs(self.formatedPassive) do
            love.graphics.print(row, self.screenX + self.passiveScreenX, self.screenY + self.passiveScreenY + (i - 1) * self.margin)
        end 
    end

end


function ItemDetails:mousemoved(x, y)
    self.screenX = x
    self.screenY = y
    
    if self.screenX > RM.windowWidth - self.width then
        self.screenX = self.screenX - (self.screenX + self.width - RM.windowWidth)  
    end

    if self.screenY > RM.windowHeight - self.height then
        self.screenY = self.screenY - (self.screenY + self.height - RM.windowHeight)    
    end

    -- self:positionElements()
end


function ItemDetails:mousepressed(x, y, btn)
    if x >= self.screenX and y >= self.screenY and x <= self.screenX + self.width and y <= self.screenY + self.height then
        return true
    end
    return false
end


function ItemDetails:mousereleased(x, y, btn)
    if x > self.screenX and y > self.screenY and x < self.screenX + self.width and y < self.screenY + self.height then
        return true
    end
    return false
end


return ItemDetails