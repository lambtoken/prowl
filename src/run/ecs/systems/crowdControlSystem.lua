local Concord = require("libs.concord")
local CCData = require("src.run.combat.crowdControlData")
local sceneManager = require("src.scene.SceneManager"):getInstance()
local EventManager = require("src.state.events"):getInstance()
local tablex = require "libs.batteries.tablex"

local crowdControlSystem = Concord.system({pool = {statusEffect, crowdControl}})

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
        EventManager:emit("shortCCBubble", entity, cc.adjective)
        return true
    end

    return false
    --table.insert(entity.crowdControl.ccEffects, self:createCC(type))
    -- print("applied cc to ", entity.metadata.species)
end

function crowdControlSystem:updateEffects()
    for _, entity in ipairs(self.entities) do
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
        local state = entity.state

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