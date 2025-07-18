local RM = require ('src.render.RenderManager'):getInstance()
local getFont = require 'src.render.getFont'
local tween = require 'libs.tween'
local fsm = require 'libs.batteries.state_machine'

local SlidingText = {}

function SlidingText:new()
    local obj = {
        text = '',
        transitionDuration = 0.3,
        stayDuration = 0.5,
        font = 'basis33',
        fontSize = 50,
        tweenX = 0,
        screenX = 0,
        opacity = 0,
    }
    obj.font = getFont('basis33', obj.fontSize)
    obj.state = fsm({
        enter = {
            o = obj,

            enter = function(s)
                s.o.tweenX = 0
                s.o.opacity = 0
                s.o.tween = tween.new(
                    s.o.transitionDuration, 
                    s.o, 
                    {
                        tweenX = 0.5,
                        opacity = 1
                    }, 
                    'inOutQuad'
                )
            end,
            update = function(s, dt) 
                if not s.o.tween:update(dt) then
                else
                    s.o.state:set_state('stay')
                end
            end,
            draw = function() end,
            exit = function() end
        },
        stay = {
            o = obj,

            enter = function(s) 
                s.timer = 0
            end,
            update = function(s, dt) 
                s.timer = s.timer + dt
                if s.timer > s.o.stayDuration then
                    s.o.state:set_state('exit')
                end
            end,
            draw = function() end,
            exit = function() end
        },
        exit = {
            o = obj,
            
            enter = function(s) 
                s.o.tween = tween.new(
                    s.o.transitionDuration, 
                    s.o, 
                    {
                        tweenX = 1,
                        opacity = 0
                    }, 
                    'outInQuad'
                )
            end,
            update = function(s, dt) 
                if not s.o.tween:update(dt) then
                else
                    s.o.state:set_state('done')
                end
            end,
            draw = function() end,
            exit = function() end
        },
        done = {
            enter = function() end,
            update = function() end,
            draw = function() end,
            exit = function() end
        }
    }, 'enter')
    
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function SlidingText:resize(w, h)
    local font = getFont("basis33", self.fontSize)
    local fontHeight = font:getHeight()

    self.halfTextWidth = getFont("basis33", self.fontSize):getWidth(self.text) / 2
    self.screenY = h / 6 - fontHeight / 2
end

function SlidingText:slide(text, color)
    self.text = text
    self.color = color or {1, 1, 1}
    self:resize(RM.windowWidth, RM.windowHeight)
    self.state:set_state("enter")
end

function SlidingText:draw()
    if self.text == '' or not self.halfTextWidth then
        return
    end

    -- print(self.opacity, self.tweenX, self.color[1], self.color[2], self.color[3], self.color[4])
    love.graphics.setFont(getFont('basis33', self.fontSize))
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.opacity)
    -- love.graphics.print(self.text, 100, 100)
    love.graphics.print(self.text, self.tweenX * RM.windowWidth - self.halfTextWidth, self.screenY + math.sin(love.timer.getDelta()) * 20)
end

function SlidingText:update(dt)
    self.state:update(dt)
end

return SlidingText