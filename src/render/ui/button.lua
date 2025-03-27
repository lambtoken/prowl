local Class = require 'libs.middleclass'
local tween = require 'libs.tween'
local getFont = require 'src.render.getFont'

local Button = Class('button')

function Button:initialize(text, callback)
    self.text = text or ''
    self.callback = callback or nil
    self.screenX = nil
    self.screenY = nil
    self.textX = 0
    self.textY = 0
    self.width = 100
    self.height = 50
    self.size = 1
    self.hovered = false
    self.fadeTween = nil
    self.gradient = 0
    self.baseColor = {0.7, 0.7, 0.7}
    self.color = {0.7, 0.7, 0.7}
    self.colorDisabled = {0.4, 0.4, 0.4}
    self.disabled = false
    self.font = 'basis33'
    self.fontSize = 50
end

function Button:onHoverEnter()
    local length = 0.5
    self.fadeTween = tween.new(length, self, {gradient = 0.5}, 'linear')
end

function Button:onHoverExit()
    local length = 0.5
    self.fadeTween = tween.new(length, self, {gradient = 0}, 'linear')
end

function Button:load()
    self:adjust()
end

function Button:adjust()
    --adjust text pos
    self.textX = self.screenX + math.floor(self.width / 2 + 0.5) - math.floor(getFont(self.font, self.fontSize):getWidth(self.text) / 2 + 0.5)
    self.textY = self.screenY + math.floor(self.height / 2 + 0.5) - math.floor(getFont(self.font, self.fontSize):getHeight() / 2)
end

function Button:updatePos(x, y)
    self.screenX = x
    self.screenY= y
end

function Button:update(dt)
    if self.fadeTween then
        self.fadeTween:update(dt)
    end

    self.color[1] = self.baseColor[1] + self.gradient
end

function Button:draw()
    if self.screenX ~= nil and self.screenY ~= nil then
        if self.disabled then
            love.graphics.setColor(unpack(self.colorDisabled))
        else
            love.graphics.setColor(unpack(self.color))            
        end

        love.graphics.rectangle('fill', self.screenX, self.screenY, self.width, self.height)
        
        if self.disabled then
            love.graphics.setColor(0.7, 0.7, 0.7)
        else
            love.graphics.setColor(0, 0, 0)
        end

        love.graphics.setFont(getFont(self.font, self.fontSize))
        love.graphics.print(self.text, self.textX, self.textY)
        love.graphics.setColor(1, 1, 1)
    end
end

function Button:mousepressed(x, y, btn)
    if not self.disabled and x > self.screenX and y > self.screenY and x < self.screenX + self.width and y < self.screenY + self.height then
        self.pressed = true
        return true
    end
    return false
end

function Button:mousereleased(x, y, btn)
    if not self.disabled and x > self.screenX and y > self.screenY and x < self.screenX + self.width and y < self.screenY + self.height then
        if self.pressed then
            self.callback()
            self.pressed = false
        end
        return true
    end
    return false
end


return Button