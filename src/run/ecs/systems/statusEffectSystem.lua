local Concord = require("libs.concord")
local tablex = require "libs.batteries.tablex"
local statusDefaults = require "src.run.ecs.defaults.statusDefaults"
local statusEffectData = require "src.run.combat.statusEffectData"
local EventManager = require("src.state.events"):getInstance()
local SceneManager = require("src.scene.SceneManager"):getInstance()
local gs = require("src.state.GameState"):getInstance()

local statusEFfectSystem = Concord.system({pool = {status}})

function statusEFfectSystem:newStatusEffect(name, source, duration)
    assert(statusEffectData[name], "Status effect: " .. name .. " does not exist.")
    duration = duration or 1
    
    local effect = {
        name = name,
        source = source,
        duration = duration,
        mod = tablex.copy(statusEffectData[name].mod),
        removeBubble = true
    }

    return effect
end

function statusEFfectSystem:giveStatusEffect(entity, source, name, duration)
    local effect = self:newStatusEffect(name, source, duration)

    for index, e in ipairs(entity.status.effects) do
        if e.name == name then
            e.removeBubble = false
        end
    end

    effect.bubbleId = SceneManager.currentScene.TextBubbleManager:newBubble("statusEffect", entity, statusEffectData[name].adjective)
    
    table.insert(entity.status.effects, effect)
end

function statusEFfectSystem:applyAllStatusEffects()
    for _, entity in ipairs(self.pool) do 
        local statusEffects = entity.status

        -- Apply defaults
        for key, value in pairs(statusDefaults) do
            entity.status[key] = value
        end

        for _, effect in ipairs(statusEffects.effects) do 
            for target, value in pairs(effect.mod) do 
                entity.status[target] = value 
            end
        end
    end
end

function statusEFfectSystem:onStandBy(teamId)
    for _, entity in ipairs(self.pool) do

        if entity.metadata.teamID ~= teamId then goto continue end

        for i = #entity.status.effects, 1, -1 do
            local effect = entity.status.effects[i]

            if effect.duration > 0 then
                effect.duration = effect.duration - 1
            else
                table.remove(entity.status.effects, i)
                if effect.removeBubble then
                    SceneManager.currentScene.TextBubbleManager:endStatusEffect(effect.bubbleId)
                end
            end
        end
        ::continue::
    end
end

-- reset animations

-- add status effect:
-- type, duration(turns)
-- send to ps entity address and type


-- for ps
-- have a periodical cleanup function
-- reuse inactive ps

return statusEFfectSystem