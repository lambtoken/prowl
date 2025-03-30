local Concord = require("libs.concord")
local EventManager = require("src.state.events"):getInstance()
local soundManager = require("src.sound.SoundManager"):getInstance()
local GameState    = require("src.state.GameState"):getInstance()
local SceneManager = require("src.scene.SceneManager"):getInstance()
local stateSystem = Concord.system({pool = {state}})

function stateSystem:init()
    EventManager:on("setState", function(entity, newState)
        self:changeState(entity, newState)
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
        if entity.animation then
            EventManager:emit('enterIdle', entity)
            EventManager:emit('playAnimation', entity, "idle")
        end
    elseif state == "dying" then
        -- play death sound
        if entity.metadata.type == 'animal' then
            soundManager:playSound('death')
            SceneManager.currentScene.TextBubbleManager:killEntityBubbles(entity)
            EventManager:emit("playAnimation", entity, "death")
        end
        
    elseif state == "dead" then
        if entity.metadata.type == 'animal' then
            EventManager:emit("checkTeamStatus", entity.metadata.teamID)
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
        --    GameState.currentMatch.itemSystem:hasActives(entity) then
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