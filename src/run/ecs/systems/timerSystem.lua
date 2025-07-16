local Concord = require("libs.concord")
local EventManager = require("src.state.events"):getInstance()
local gs = require("src.state.GameState"):getInstance()

local callbackRegistry = {
    lifeSteal = function(data) gs.match.combatSystem:heal(data.entity, data.amount) end,
    explosion = function(data) gs.match.combatSystem:explode(data.entity, data.amount) end,
    removeStatusEffect = function(data) 
        if gs.match and gs.match.TextBubbleManager then
            gs.match.TextBubbleManager:endStatusEffect(data.bubbleId)
        end
    end,
    despawnProjectile = function(data)
        -- this is fine for now
        if gs.match and gs.match.ecs and data.entityId then
            local entity = gs.match:getEntityById(data.entityId)
            if entity.metadata and entity.metadata.type == "projectile" then
                gs.match.stateSystem:changeState(entity, "dead")
            end
        end
    end
}

local timerSystem = Concord.system({pool = {"timers"}})

function timerSystem:init()
    EventManager:on("registerTimer", function(entity, time, callbackId, data)
        table.insert(entity.timers.timers, self:newTimer(time, callbackId, data))
    end)
end

function timerSystem:newTimer(time, callbackId, data)
    return {
        currentTime = 0,
        duration = time,
        callbackId = callbackId,
        data = data
    }
end

function timerSystem:update(dt)

    for index, entity in ipairs(self.pool) do
        for i = #entity.timers.timers, 1, -1 do
            local timer = entity.timers.timers[i]

            timer.currentTime = timer.currentTime + dt

            if timer.currentTime >= timer.duration then
                callbackRegistry[timer.callbackId](timer.data)
                table.remove(entity.timers.timers, i)
            end
        end
    end

end

function timerSystem:allTimersDone()
    for i, e in ipairs(self.pool) do
        if e.timers and #e.timers.timers > 0 then
            return false
        end
    end
    return true
end

return timerSystem