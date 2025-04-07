local Concord = require("libs.concord")
local animationData = require("src.render.match.animationData")
local EventManager = require("src.state.events"):getInstance()
local tween = require "libs.tween"
local tablex= require "libs.batteries.tablex"
local animationDefaults = require "src.render.match.animationDefaults"


local animationSystem = Concord.system({pool = {"position", "renderable"}})


function animationSystem:init()
    
    EventManager:on("playAnimation", function(entity, animation)
        animationSystem:playAnimation(entity, animation)
    end)
end

function animationSystem:collectTweens(layer)
    for _, entity in ipairs(self.pool) do 
        
        if #layer.animations > 0 then
            local sums = tablex.copy(animationDefaults)
            
            for _, animation in ipairs(layer.animations) do 
                for _, t in ipairs(animation.tweens) do
                    if animation.timePassed >= t.delay and animation.timePassed < (t.delay + t.tween.duration) and not t.tween:isComplete() or animation.loop then
                        sums[t.target] = sums[t.target] + t.x
                    end
                end
            end
        
            for property, sum in pairs(sums) do
                if property ~= "flipX" then
                    layer.transform[property] = sum
                end
            end
        end
    end
end

function animationSystem:updateAnimations(layer, entity, dt)
        
    local animations = layer.animations
    
    for i = #animations, 1, -1 do
        local animation = animations[i]

        animation.timePassed = animation.timePassed + dt

        local allTweensComplete = true
        for _, t in ipairs(animation.tweens) do

            if animation.timePassed >= t.delay then
                if not t.tween:update(dt) then
                    allTweensComplete = false
                end
            else
                allTweensComplete = false
                break
            end

        end

        -- this shouldn't be here. but it fixes a looping glitch for now
        self:collectTweens(layer)

        if allTweensComplete then
            if animation.loop then
                animation.timePassed = 0
                for _, t in ipairs(animation.tweens) do
                    t.tween:reset()
                    t.x = t.from
                end
            else
                if animation.onFinish then
                    animationData[animation.name].onFinish(entity)
                end
                table.remove(animations, i)
            end
        end
    end


    if layer.flipXTween then
        layer.flipXTween:update(dt)
    end
end


function animationSystem:update(dt)
    for _, entity in ipairs(self.pool) do 
        local state = entity.state
        
        if state and state.current == "dead" then
            goto continue
        end
        
        local renderable = entity.renderable
        
        self:updateAnimations(entity.renderable, entity, dt)

        for index, layer in ipairs(renderable.layers) do
        
            local animations = layer.animations
            self:updateAnimations(layer, entity, dt)
            
        end
        ::continue::
    end
end


function animationSystem:createAnimation(name)
    local anim = {}

    anim.cancelCategory = animationData[name].cancelCategory
    anim.tweens = {}
    anim.name = name
    anim.loop = animationData[name].loop
    anim.stackable = animationData[name].stackable
    anim.timePassed = 0
    anim.onFinish = animationData[name].onFinish
    
    for _, tweenData in ipairs(animationData[name].tweens) do
        local t = tablex.copy(tweenData)
        
        t.x = t.from

        t.tween = tween.new(
            t.duration,
            t,
            {x = t.to},
            t.func
        )
        
        table.insert(anim.tweens, t)
    end

    return anim
end


function animationSystem:playAnimation(target, name, layer)
    assert(animationData[name], "Animation " .. name .. " does not exist!")
    layer = layer or 0

    -- 0 is for master animations
    if layer == 0 then
        table.insert(target.renderable.animations, animationSystem:createAnimation(name))
    else
        table.insert(target.renderable.layers[layer].animations, animationSystem:createAnimation(name))
    end
end


-- function animationSystem:__getAnimations(name)

-- end


function animationSystem:stopAnimation(target, name)

    for _, animation in ipairs(target.renderable.animations) do 
        if animation.name == name then
            table.remove(target.animation.animations, _)
        end
    end
end

function animationSystem:face(entity, side)
    assert(side == "left" or side == "right", "Expected left or right, instead got " .. side)
    if side == "left" then
        entity.renderable.flipXTween = tween.new(0.5, entity.renderable.transform, {flipX = 1}, "inOutBack")
    elseif side == "right" then
        entity.renderable.flipXTween = tween.new(0.5, entity.renderable.transform, {flipX = -1}, "inOutBack")
    end
end

function animationSystem:allAnimationsDone()
    for _, entity in ipairs(self.pool) do 

        for i = #entity.renderable.animations, 1, -1 do
            local animation = entity.renderable.animations[i]

            if not (animation.name == "idle" or animation.name == "death") then
                return false
            end

        end

        for index, layer in ipairs(entity.renderable.layers) do
            for i = #layer.animations, 1, -1 do
                local animation = layer.animations[i]
    
                if not (animation.name == "idle" or animation.name == "death") then
                    return false
                end
    
            end
        end
    end
    return true
end

function animationSystem:removeAll(entity)
    
    for _, layer in ipairs(entity.renderable.layers) do
        layer.animations = {}
    end

end

return animationSystem