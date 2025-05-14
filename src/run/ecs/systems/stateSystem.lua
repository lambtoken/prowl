local Concord = require("libs.concord")
local EventManager = require("src.state.events"):getInstance()
local soundManager = require("src.sound.SoundManager"):getInstance()
local GameState    = require("src.state.GameState"):getInstance()
local SceneManager = require("src.scene.SceneManager"):getInstance()
local mobData = require("src.generation.mobs")
local objectData = require("src.generation.objects")
local on = require "src.run.ecs.on"

local stateSystem = Concord.system({pool = {"state"}})


function stateSystem:init()
    
    local matchState = GameState.match

    EventManager:on("setState", function(entity, newState)
        self:changeState(entity, newState)
    end)

    EventManager:on("onDeath", function(entity)
        on("onDeath", matchState, entity)
    end)

    EventManager:on("onDying", function(entity)
        on("onDying", matchState, entity)
    end)

    EventManager:on("onDeathAny", function(entity)
        on("onDeathAny", matchState, entity)
    end)

    EventManager:on("onDyingAny", function(entity)
        on("onDyingAny", matchState, entity)
    end)
end

function stateSystem:changeState(entity, newState)
    -- if entity.state.currentState == newState then
    --     return
    -- end

    self:onStateExit(entity, entity.state.current)
    entity.state.current = newState
    self:onStateEnter(entity, newState)
    -- self:onStateExit(entity, entity.currentState)
end

function stateSystem:onStateEnter(entity, state)
    if state == "idle" then
        entity.state.alive = true
        entity.state.interactable = true
        EventManager:emit('playAnimation', entity, "idle")        
    elseif state == "dying" then
        entity.state.alive = false
        entity.state.interactable = false
        if entity.metadata.type == 'animal' then
            soundManager:playSound('death')
            SceneManager.currentScene.TextBubbleManager:killEntityBubbles(entity)
            EventManager:emit("playAnimation", entity, "death")
            EventManager:emit("onDying", entity)
            EventManager:emit("onDyingAny", entity)
        end
        
    elseif state == "dead" then
        entity.state.alive = false
        entity.state.interactable = false
        if entity.metadata.type == 'animal' then
            EventManager:emit("checkTeamStatus", entity.metadata.teamID)
            EventManager:emit("onDeath", entity)
            EventManager:emit("onDeathAny", entity)
        end
    end
end

function stateSystem:onStateExit(entity, state)
    if state == "idle" then
        if entity.animation then
            EventManager:emit('stopAnimation', entity, "idle")
        end
    elseif state == "dying" then
    elseif state == "dead" then
    end
end

function stateSystem:hasActions(entity)
    if entity.state then
        if self:hasMovesLeft(entity) and
           entity.status.canMove then
        --    GameState.match.itemSystem:hasActives(entity) then
                return true
           end
           return false
    end
end

function stateSystem:hasMovesLeft(entity)
    if entity.state.currentTurnMoves >= entity.stats.current.moves then
        return false
    end
    return true
end

return stateSystem

-- spawning -- alive
-- idle  -- alive
-- dying -- alive
-- dead -- dead