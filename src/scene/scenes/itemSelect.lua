local Scene = require 'src.scene.scene'
local RM = require ('src.render.RenderManager'):getInstance()
local tween = require 'libs.tween'
local Item = require 'src.render.ui.ItemSelectItem'
local getRandomItems = require 'src.generation.functions.getRandomItems'
local pretty         = require 'libs.batteries.pretty'
local checkerShader = love.graphics.newShader(require('src.render.shaders.checker_shader'))
local SoundManager  = require('src.sound.SoundManager'):getInstance()
-- local newItem = require 'src.run.newItem'

local itemMargin = 100
local itemSize = 200
local nItems = 3

local itemSelect = Scene:new('itemSelect')

function itemSelect:resize()
    itemSize = RM.windowHeight / 5
    self.screenX = RM.windowWidth / 2 - ((nItems) * itemSize + (nItems - 1) * itemMargin) / 2
    self.screenY = RM.windowHeight / 2 - itemSize / 2

    for index, item in ipairs(self.items) do
        item.screenX = self.screenX + ((index - 1) * itemSize) + ((index - 1) * itemMargin)
        item.screenY = self.screenY
        item:setSize(itemSize)
    end
end

function itemSelect:enter()
    self.items = {} 
    
    local randomItems = getRandomItems(3, nItems)

    randomItems[1] = 'mace'

    for i = 1, nItems do
        local item = Item:new(randomItems[i])
        item:setSize(itemSize)
        table.insert(self.items, item)
    end

    self:resize()

    SoundManager:playSound('arrow')
end

function itemSelect:update(dt)
    checkerShader:send("time", love.timer.getTime())
end

function itemSelect:draw()
    love.graphics.setShader(checkerShader)
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle('fill', 0, 0, RM.windowWidth, RM.windowHeight)
    love.graphics.setShader()
    love.graphics.setColor(1, 1, 1)

    for index, item in ipairs(self.items) do
        item:draw()
    end
end

function itemSelect:mousemoved(x, y)
    for index, item in ipairs(self.items) do
        item:mousemoved(x, y)
    end
end

function itemSelect:mousepressed(x, y, btn)
    if btn == 1 then
        for index, item in ipairs(self.items) do
            item:mousepressed(x, y, btn)
        end
    end
end

return itemSelect

-- onClick adds those items to the players first animal in the team