local renderManager = require ('src.render.RenderManager'):getInstance()
local mouse = require 'src.input.mouse'
local tween = require 'libs.tween'
local spriteTable = require 'src.render.spriteTable'
local soundM = require('src.sound.SoundManager'):getInstance()
local RenderManager = require('src.render.RenderManager'):getInstance()

local instance = nil

local Cursor = {}

function Cursor:new()
    local o = {
        clickTween = nil,
        shrinkTime = 0.05,
        growTime = 0.2,
        shrinkRatio = 0.8,
        cursorShrink = 1,
        cursorSize = 1.3,
        cursorSprite = 'cursor_fat',
        texture = nil,
        visibility = true
    }

    o.hitCircle = love.graphics.newImage("assets/circle.png")
    o.hitCircle:setFilter("linear", "linear")

    o.ps = love.graphics.newParticleSystem(o.hitCircle, 8)
    o.ps:setColors(0.55078125, 0.55078125, 0.55078125, 0.8)
    o.ps:setDirection(math.pi / 2)
    o.ps:setEmissionArea("uniform", 12.888281822205, 17.54238319397, 1.6396528482437, false)
    o.ps:setEmitterLifetime(-1)
    o.ps:setInsertMode("top")
    o.ps:setLinearAcceleration(2.6848933696747, 4.6990547180176, 2.6848933696747, 4.2623910903931)
    o.ps:setLinearDamping(5.1610202789307, 9.7910566329956)
    o.ps:setParticleLifetime(0.2, 0.3)
    o.ps:setRadialAcceleration(1.0876464844, 1.5854492188)
    o.ps:setRelativeRotation(false)
    o.ps:setRotation(0, 0)
    o.ps:setSizes(0.04)
    o.ps:setSizeVariation(0)
    o.ps:setSpeed(510.38748168945, 1058.87890625)
    o.ps:setSpin(0, 0)
    o.ps:setSpinVariation(0)
    o.ps:setSpread(3.8895909786224)
    o.ps:setTangentialAcceleration(1.9331232309341, -1.9331232309341)

    setmetatable(o, self)
    self.__index = self
    return o
end

function Cursor:getInstance()
    if not instance then
        instance = self:new()
    end

    return instance
end

function Cursor:load()
    love.mouse.setVisible(false)
    self.texture = love.graphics.newQuad(spriteTable[self.cursorSprite][1] * renderManager.spriteSize, spriteTable[self.cursorSprite][2] * renderManager.spriteSize, renderManager.spriteSize, renderManager.spriteSize, renderManager.image)
end

function Cursor:draw()
    if self.visibility then
        love.graphics.setColor(1,1,1,1)
        RenderManager.pushScreen()
        love.graphics.draw(self.ps)
        love.graphics.pop()
        local x, y = love.mouse.getPosition()
        love.graphics.draw(renderManager.image, self.texture, x, y, 0, renderManager.increaseFactor * self.cursorShrink * self.cursorSize)
    end
end

function Cursor:update(dt)
    if self.clickTween and self.clickTween:update(dt) then end
    self.ps:update(dt)
end

function Cursor:mousepressed(xx, yy, click)
    if click == 1 then
        local x, y = love.mouse.getPosition()
        -- soundM:playSound('click10')
        soundM:playSound('pclick5')
        self.cursorShrink = self.shrinkRatio
        self.clickTween = tween.new(self.shrinkTime, self, {cursorShrink = self.shrinkRatio}, "inQuint")
        self.ps:setPosition(x, y)
        self.ps:emit(5)
        --self.ps:start()
    end
end

function Cursor:mousereleased(x, y, click)
    if click == 1 then
        -- soundM:playSound('click2')
        self.clickTween = tween.new(self.growTime, self, {cursorShrink = 1}, "outQuint")
    end
end

function Cursor:setVisibility(boolean)
    self.visibility = boolean
end

return Cursor