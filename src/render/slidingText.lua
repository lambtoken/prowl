local RM = require ('src.render.RenderManager'):getInstance()
local getFont = require 'src.render.getFont'
local tween = require 'libs.tween'
local fsm = require 'libs.batteries.state'

local SlidingText = {}

function SlidingText:new()
    local o = {
        text = '',
        transitionDuration = 0.3,
        stayDuration = 0.5,
        fontSize = 50,
        tweenX = 0,
        screenY = 0,
        opacity = 0,
    }
    o.font = getFont('basis33', o.fontSize)
    o.state = fsm({
        o = o,
        enter = {
            enter = function(s)
                s.o.tweenX = 0
                s.o.opacity = 0
                s.o.tween = tween.new(
                    s.o.transitionDuration, 
                    s.o, 
                    {
                        screenX = 0.5,
                        opacity = 1
                    }, 
                    'inOutQuad'
                )
            end,
            update = function(dt) 
                if s.o.tween:update(dt) then
                else
                    o.state:setState('exit')
                end
            end,
            draw = function() end,
            exit = function() end
        },
        stay = {
            enter = function(s) 
                s.timer = 0
            end,
            update = function(dt, s) 
                s.timer = s.timer
            end,
            draw = function() end,
            exit = function() end
        },
        exit = {
            enter = function(s) 
                s.o.tween = tween.new(
                    s.o.transitionDuration, 
                    s.o, 
                    {
                        screenX = 1,
                        opacity = 0
                    }, 
                    'outInQuad'
                )
            end,
            update = function(dt) 
                if s.o.tween:update(dt) then
                else
                    o.state:setState('done')
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
    
    setmetatable(o, self)
    self.__index = self
    return o
end

function SlidingText:resize(w, h)
    self.halfTextWidth = getFont("basis33", self.fontSize):getWidth(self.text) / 2
    self.screenY = RM.windowHeight / 4
end

function SlidingText:slide(text)
    self.text = text
    self.state:set_state("enter")
end

function SlidingText:draw()
    getFont(self.font)
    love.graphics.setColor(1, 1, 1, self.opacity)
    love.graphics.print(self.text, self.tweenX * RM.windowWidth - self.halfTextWidth, self.screenY + math.sin(love.timer.getDelta()) * 20)
end

function SlidingText:update(dt)
    if self.tween:update(dt) then
        self.tween:update(dt)
    end
end

return SlidingText