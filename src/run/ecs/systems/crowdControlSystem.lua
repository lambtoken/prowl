local Concord = require("libs.concord")
local CCData = require("src.run.combat.crowdControlData")
local sceneManager = require("src.scene.SceneManager"):getInstance()
local EventManager = require("src.state.events"):getInstance()
local tablex = require "libs.batteries.tablex"

local crowdControlSystem = Concord.system({pool = {"status", "crowdControl"}})

-- standby event
-- seconds timer
-- oncancel callback to cancel the animations

-- alter is a mystery

function crowdControlSystem:createCC(type)
    local cc = tablex.copy(CCData[type])
    return cc
end

function crowdControlSystem:applyCC(entity, type, source)
    local cc = self:createCC(type)
    local matchState = sceneManager.currentScene.currentMatch

    if cc.callback(matchState, entity, source) then
        -- Create status effect bubble
        EventManager:emit("shortCCBubble", entity, cc.adjective)
        
        -- Set up removal of bubble when effect ends
        if cc.duration then
            EventManager:emit("registerTimer", entity, cc.duration, "removeStatusEffect", {
                entity = entity,
                effectName = cc.adjective
            })
        end
        
        return true
    end

    return false
end

function crowdControlSystem:updateEffects()
    for _, entity in ipairs(self.pool) do
        for _, effect in pairs(entity.crowdControl.effects) do
            if effect.duration > 0 then
                effect.duration = effect.duration - 1
            else
                effect = nil  -- Remove expired effect
            end
        end
    end
end

function crowdControlSystem:update(dt)
    for _, entity in ipairs(self.pool) do

        for _, effect in ipairs(entity.crowdControl.ccEffects) do
            if effect.duration > 0 then
                effect.duration = effect.duration - 1
            else
                effect = nil  -- Remove expired effect
            end
        end
    end
end

-- function crowdControlSystem:allCCDone()
--     for _, entity in ipairs(self.pool) do
--         if entity.crowdControl.ccEffects
--     end
-- end

return crowdControlSystem