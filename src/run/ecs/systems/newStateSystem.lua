local Concord = require("libs.concord")
local EventManager = require("src.state.events"):getInstance()
local states = require("src.run.ecs.states")

local stateSystem = Concord.system({ pool = { "state" } })

function stateSystem:init()
    EventManager:on("setState", function(entity, stateName)
        self:startState(entity, stateName)
    end)

    EventManager:on("clearState", function(entity, stateName)
        self:endState(entity, stateName)
    end)
end

function stateSystem:startState(entity, stateName)
    local stateDef = states[stateName]
    if not stateDef then return end

    if not entity.state.activeStates[stateName] then
        -- Make a fresh copy for this entity
        local stateInstance = {
            name = stateName,
            duration = stateDef.duration,
            timer = 0
        }
        entity.state.activeStates[stateName] = stateInstance

        if stateDef.onEnter then
            stateDef.onEnter(entity)
        end
    end
end

function stateSystem:endState(entity, stateName)
    local stateDef = states[stateName]
    if not stateDef then return end

    if entity.state.activeStates[stateName] then
        entity.state.activeStates[stateName] = nil

        if stateDef.onExit then
            stateDef.onExit(entity)
        end
    end
end

function stateSystem:update(dt)
    for _, entity in ipairs(self.pool) do
        for name, instance in pairs(entity.state.activeStates) do
            local def = states[name]

            instance.timer = instance.timer + dt

            if def.onUpdate then
                def.onUpdate(dt, entity)
            end

            if instance.duration and instance.timer >= instance.duration then
                self:endState(entity, name)
            end
        end
    end
end

return stateSystem
