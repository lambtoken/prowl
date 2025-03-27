local RM = require ('src.render.RenderManager'):getInstance()
local tween = require "libs.tween"

local transitions = {}

transitions.instant = {
    onExit = {},
    onEnter = {}
}

transitions.instant.length = 0

transitions.instant.onExit.enter = function() end
transitions.instant.onExit.update = function(dt) end
transitions.instant.onExit.draw = function() end
transitions.instant.onExit.exit = function() end
transitions.instant.onEnter.enter = function() end
transitions.instant.onEnter.update = function(dt) end
transitions.instant.onEnter.draw = function() end
transitions.instant.onEnter.exit = function() end

transitions.fade = {
    onExit = {},
    onEnter = {}
}

transitions.fade.length = 2
transitions.fade.alpha = 0

transitions.fade.onExit.enter = function()
    transitions.fade.alpha = 0
    transitions.fade.tween = tween.new(transitions.fade.length, transitions.fade, {alpha = 1}, "inOutSine")
end

transitions.fade.onExit.update = function(dt)
    transitions.fade.tween:update(dt)
end

transitions.fade.onExit.draw = function()
    love.graphics.setColor(0,0,0, transitions.fade.alpha)
    love.graphics.rectangle('fill', 0, 0, RM.windowWidth, RM.windowHeight)
end

transitions.fade.onExit.exit = function() end

transitions.fade.onEnter.enter = function()
    transitions.fade.alpha = 1
    transitions.fade.tween = tween.new(transitions.fade.length, transitions.fade, {alpha = 0}, "inOutSine")
end

transitions.fade.onEnter.update = function(dt)
    transitions.fade.tween:update(dt)
end

transitions.fade.onEnter.draw = function()
    love.graphics.setColor(0,0,0, transitions.fade.alpha)
    love.graphics.rectangle('fill', 0, 0, RM.windowWidth, RM.windowHeight)
end

transitions.fade.onEnter.exit = function() end

return transitions