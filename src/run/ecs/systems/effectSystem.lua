local Concord = require "libs.concord"
local EventManager = require("src.state.events"):getInstance()

local EffectSystem = Concord.system({
    pool = {"status"},
    crowdControlPool = {"crowdControl"},
    dotPool = {"dot"},
    buffDebuffPool = {"buffDebuff"}
})

function EffectSystem:init()
    EventManager:on("addEffect", function(entity, effectType, effectName, duration, data)
        self:addEffect(entity, effectType, effectName, duration, data)
    end)
    
    EventManager:on("removeEffect", function(entity, effectType, effectName)
        self:removeEffect(entity, effectType, effectName)
    end)
end

function EffectSystem:addEffect(entity, effectType, effectName, duration, data)
    if not entity then return end
    
    data = data or {}
    data.duration = duration or 0
    data.timer = duration or 0
    
    -- Determine which component to use based on effect type
    local component
    if effectType == "status" and entity.status then
        component = entity.status
    elseif effectType == "crowdControl" and entity.crowdControl then
        component = entity.crowdControl
    elseif effectType == "dot" and entity.dot then
        component = entity.dot
    elseif effectType == "buffDebuff" and entity.buffDebuff then
        component = entity.buffDebuff
    else
        -- If the entity doesn't have the component, we can't add the effect
        return
    end
    
    -- Add the effect
    component.effects[effectName] = data
    
    -- Emit an event to notify of the new effect
    EventManager:emit("statusEffectBubble", entity, effectName)
end

function EffectSystem:removeEffect(entity, effectType, effectName)
    if not entity then return end
    
    -- Determine which component to use based on effect type
    local component
    if effectType == "status" and entity.status then
        component = entity.status
    elseif effectType == "crowdControl" and entity.crowdControl then
        component = entity.crowdControl
    elseif effectType == "dot" and entity.dot then
        component = entity.dot
    elseif effectType == "buffDebuff" and entity.buffDebuff then
        component = entity.buffDebuff
    else
        -- If the entity doesn't have the component, we can't remove the effect
        return
    end
    
    -- Remove the effect if it exists
    if component.effects[effectName] then
        component.effects[effectName] = nil
        
        -- Emit an event to notify of the removed effect
        EventManager:emit("removeStatusEffect", entity, effectName)
    end
end

function EffectSystem:update(dt)
    -- Update status effects
    for i = 1, self.pool.size do
        local entity = self.pool:get(i)
        self:updateEffects(entity, entity.status, dt)
    end
    
    -- Update crowd control effects
    for i = 1, self.crowdControlPool.size do
        local entity = self.crowdControlPool:get(i)
        self:updateEffects(entity, entity.crowdControl, dt)
    end
    
    -- Update DoT effects
    for i = 1, self.dotPool.size do
        local entity = self.dotPool:get(i)
        self:updateEffects(entity, entity.dot, dt)
    end
    
    -- Update buff/debuff effects
    for i = 1, self.buffDebuffPool.size do
        local entity = self.buffDebuffPool:get(i)
        self:updateEffects(entity, entity.buffDebuff, dt)
    end
end

function EffectSystem:updateEffects(entity, component, dt)
    if not component or not component.effects then return end
    
    local effectsToRemove = {}
    
    -- Update each effect's timer
    for effectName, effect in pairs(component.effects) do
        -- Only update effects with duration
        if effect.duration > 0 then
            effect.timer = effect.timer - dt
            
            -- If the effect has expired, mark it for removal
            if effect.timer <= 0 then
                table.insert(effectsToRemove, effectName)
            end
        end
    end
    
    -- Remove expired effects
    for _, effectName in ipairs(effectsToRemove) do
        component.effects[effectName] = nil
        EventManager:emit("removeStatusEffect", entity, effectName)
    end
end

return EffectSystem 