local Class = require 'libs.middleclass'
local tween = require 'libs.tween'
local Button = require 'src.render.ui.button'
local mouse = require 'src.input.mouse'
local soundM = require('src.sound.SoundManager'):getInstance()

local ButtonContainer = Class('buttonContainer')

function ButtonContainer:initialize(buttons)
    self.buttons = buttons or {}
    self.screenX = 0
    self.screenY = 0
    self.width = nil
    self.height = nil
    self.marginBottom = 10
end

function ButtonContainer:addButton(text, callback)
    local btn = Button:new(text, callback)
    table.insert(self.buttons, btn)
end

function ButtonContainer:handleMouseHover(x, y)
    if x and y then
        for i, _ in ipairs(self.buttons) do
            local prevHovered = _.hovered
            if _.screenX < x and _.screenY < y and _.screenX + _.width > x and _.screenY + _.height > y then
                if prevHovered == false then
                    if true then
                        _.hovered = true
                        _:onHoverEnter()
                    end
                end
                else
                    if prevHovered == true then
                        _.hovered = false
                        _:onHoverExit()
                    end
            end
            
        end
    end
end

function ButtonContainer:mousePressed(x, y, button)
    for i, _ in ipairs(self.buttons) do
        if _.screenX < x and _.screenY < y and _.screenX + _.width > x and _.screenY + _.height > y then
            if not _.disabled then
                if button == 1 then
                    soundM:playSound('click1')
                    _.callback()
                end
            end
        end
    end
end


function ButtonContainer:calcHeight()
    self.height = #self.buttons * (self.buttons[1].height + 10)
end

function ButtonContainer:calcButtonsPos()
    for i, _ in ipairs(self.buttons) do
        _.screenX = self.screenX
        _.screenY = self.screenY + (i - 1) * (_.height + 10)
        _.width = self.width
        _:load()
    end
end

function ButtonContainer:load()
    self:calcButtonsPos()
end

function ButtonContainer:update(dt)
    self:handleMouseHover(mouse.x, mouse.y)

    for i, _ in ipairs(self.buttons) do
        _:update(dt)
    end
end

function ButtonContainer:draw()
    for i, _ in ipairs(self.buttons) do
        _:draw()
    end
end

return ButtonContainer