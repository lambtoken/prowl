local Concord = require("libs.concord")
local RM = require('src.render.RenderManager'):getInstance()

local position = Concord.component("position", function(component, x, y)
    component.x = x or 0
    component.y = y or 0
    component.screenX = (component.x) * RM.tileSize
    component.screenY = (component.y) * RM.tileSize
    component.dirX = 0
    component.dirY = 0
    component.prevX = component.x
    component.prevY = component.y
    component.lastStepX = component.x
    component.lastStepY = component.y
    component.moveTweens = {}
    component.snapTween = nil
end)

return position

