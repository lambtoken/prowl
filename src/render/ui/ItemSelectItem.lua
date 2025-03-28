local RM = require ('src.render.RenderManager'):getInstance()
local spriteTable = require 'src.render.spriteTable'
local gs = require('src.state.GameState'):getInstance()
local sceneManager = require('src.scene.SceneManager'):getInstance()
local ItemDetails = require('src.render.ui.itemDetails')
local stageConfig = require('src.run.stageConfig')

local ItemSelectItem = {}
ItemSelectItem.__index = ItemSelectItem

function ItemSelectItem:new(itemName) 
    local o = {
        itemName = itemName,
        itemDetails = ItemDetails:new(itemName),
        animationTimer = 0,
        animationTime = 1,
        animationQuad = 0
    }
    
    o.itemDetails:init()

    print(itemName)
    o.texture = love.graphics.newQuad(spriteTable[o.itemName][1] * RM.spriteSize, spriteTable[o.itemName][2] * RM.spriteSize, RM.spriteSize, RM.spriteSize, RM.image)

    setmetatable(o, self)
    o.__index = self

    return o
end

function ItemSelectItem:setSize(size)
    self.width = size
    self.height = size
    self.itemScaleFactor = size / RM.spriteSize
end

function ItemSelectItem:draw()
    if self.hovered then
        love.graphics.setColor(0.8,0.8,0.8, 0.4)
        love.graphics.rectangle("fill", self.screenX, self.screenY, self.width, self.height)
    end

    love.graphics.setColor(1,1,1)
    love.graphics.draw(RM.image, self.texture, self.screenX, self.screenY, 0, self.itemScaleFactor, self.itemScaleFactor)
    love.graphics.setColor(1,1,1)
    
    if self.hovered then
        self.itemDetails:draw()
    end
end

function ItemSelectItem:update(dt)
end

function ItemSelectItem:mousemoved(x, y)
    if x >= self.screenX and y >= self.screenY and x <= (self.screenX + self.width) and y <= (self.screenY + self.height) then
        self.hovered = true
        self.itemDetails:mousemoved(x, y)
    else
        self.hovered = false
    end
end

function ItemSelectItem:mousepressed(x, y, btn)
    
    if x >= self.screenX and y >= self.screenY and x <= self.screenX + self.width and y <= self.screenY + self.height then
       
        gs.currentMatch.itemSystem:giveItem(gs.run.team[1], self.itemName)
        gs.currentMatchNode.passed = true
        
        if gs.run.currentNodeCoords[1] == #stageConfig.format - 1 then
            gs.run:nextStage()
        else
            gs.run.currentNodeCoords = {gs.currentMatchNode.x, gs.currentMatchNode.y}
        end

        sceneManager:switchScene( "runMap")
    end
    return false
end

function ItemSelectItem:mousereleased(x, y, btn)
    if x > self.screenX and y > self.screenY and x < self.screenX + self.width and y < self.screenY + self.height then
        return true
    end
    return false
end

return ItemSelectItem