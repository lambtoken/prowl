local Concord = require("libs.concord")
local spriteTable = require "src.render.spriteTable"
local RM = require ('src.render.RenderManager'):getInstance()
local animationDefaults = require "src.render.match.animationDefaults"

local function defaultTransform()
    return {
        rotation = animationDefaults.rotation,
        scaleX = animationDefaults.scaleX,
        scaleY = animationDefaults.scaleY,
        translateX = animationDefaults.translateX,
        translateY = animationDefaults.translateY,
        flipX = animationDefaults.flipX,
    }
end

local function newQuad(spriteName)
    return {
        sprite = spriteTable[spriteName],
        texture = love.graphics.newQuad(
            spriteTable[spriteName][1] * RM.spriteSize, 
            spriteTable[spriteName][2] * RM.spriteSize, 
            RM.spriteSize, 
            RM.spriteSize, 
            RM.image),
        transform = defaultTransform(),
        animations = {},
        requests = {},
        flipXTween = nil,
        forDeletion = {},
    }
end

local renderable = Concord.component("renderable", function(component, spriteName)
    component.layers = { newQuad(spriteName) }
    component.transform = defaultTransform()
    component.animations = {}
    component.forDeletion = {}
    component.width = 16
    component.height = 16
end)

return renderable