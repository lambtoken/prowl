local EventManager = require("src.state.events"):getInstance()
local soundManager = require("src.sound.SoundManager"):getInstance()
local SceneManager = require("src.scene.SceneManager"):getInstance()
local on = require("src.run.ecs.on")

local states = {
    spawning = {
        duration = nil, -- No auto-expire
        onEnter = function(entity)
            entity.state.alive = true
            entity.state.interactable = false
            EventManager:emit("playAnimation", entity, "spawn")
        end
    },

    idle = {
        duration = nil,
        onEnter = function(entity)
            entity.state.alive = true
            entity.state.interactable = true
            EventManager:emit("playAnimation", entity, "idle")
        end,
        onExit = function(entity)
            if entity.animation then
                EventManager:emit("stopAnimation", entity, "idle")
            end
        end
    },

    dying = {
        duration = nil,
        onEnter = function(entity)
            entity.state.alive = false
            entity.state.interactable = false
            if entity.metadata.type == "animal" then
                soundManager:playSound("death")
                SceneManager.currentScene.TextBubbleManager:killEntityBubbles(entity)
                EventManager:emit("playAnimation", entity, "death")
                EventManager:emit("onDying", entity)
                EventManager:emit("onDyingAny", entity)
            end
        end
    },

    dead = {
        duration = nil,
        onEnter = function(entity)
            entity.state.alive = false
            entity.state.interactable = false
            if entity.metadata.type == "animal" then
                EventManager:emit("checkTeamStatus", entity.team.teamId)
                EventManager:emit("onDeath", entity)
                EventManager:emit("onDeathAny", entity)
            end
        end
    }
}

return states