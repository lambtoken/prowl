local class = require "libs.middleclass"
local mold = require "libs.mold"
local RM = require('src.render.RenderManager'):getInstance()
local spriteTable = require "src.render.spriteTable"
local statusEffectData = require "src.run.combat.statusEffectData"
local StatusBar = class("StatusBar")

function StatusBar:initialize(inputManager)
    self.inputManager = inputManager

    self.root = mold.Container:new()
    self.root:setRoot(RM.windowWidth, RM.windowHeight)
    self.root:setJustifyContent(mold.FLEX_JUSTIFY.CENTER)
    self.root:setAlignContent(mold.FLEX_ALIGN.CENTER)
    self.root:setDirection(mold.FLEX_DIRECTION.COLUMN)
    
    self.container = self.root:addContainer()
    self.container:setWidth("auto")
    self.container:setHeight("30px")
    self.container:setPosition(mold.POSITION_TYPES.FIXED)
    -- self.container:setMargin("auto", "left")
    -- self.container:setMargin("auto", "top")
    self.container:setDirection(mold.FLEX_DIRECTION.ROW)
    self.container:setJustifyContent(mold.FLEX_JUSTIFY.START)
    
    self.effectIcons = {}
    self.lastClickedAnimal = nil
    self.root:resize()
end

function StatusBar:update(dt)
    self.container:update(dt)
end

function StatusBar:updateEffectIcons(animal)
    self.effectIcons = {}
    self.container:clearChildren()
    
    if not animal then
        return
    end
    
    if animal.status and animal.status.effects then
        for _, effect in ipairs(animal.status.effects) do
            self:addEffectIcon(effect)
        end
    end
    
    if animal.crowdControl and animal.crowdControl.effects then
        for _, effect in ipairs(animal.crowdControl.effects) do
            self:addEffectIcon(effect)
        end
    end
    
    if animal.buffDebuff and animal.buffDebuff.effects then
        for _, effect in ipairs(animal.buffDebuff.effects) do
            self:addEffectIcon(effect)
        end
    end
    
    if animal.dot and animal.dot.effects then
        for _, effect in ipairs(animal.dot.effects) do
            self:addEffectIcon(effect)
        end
    end

    self.container:resize()
end

function StatusBar:addEffectIcon(effect)
    local sprite = self:getEffectSprite(effect.name)
    
    local icon

    if not sprite then
        sprite = spriteTable["generic_effect"]
    end

    icon = mold.QuadBox:new(RM.image, sprite[1] * RM.spriteSize, sprite[2] * RM.spriteSize, RM.spriteSize, RM.spriteSize)
    icon:setWidth("30px")
    icon:setHeight("30px")
    
    icon.effect = effect
    
    self.container:addChild(icon)
    table.insert(self.effectIcons, icon)
end

function StatusBar:getEffectSprite(effectName)
    return spriteTable[effectName]
end

function StatusBar:draw()
    self.root:draw()
end

return StatusBar 