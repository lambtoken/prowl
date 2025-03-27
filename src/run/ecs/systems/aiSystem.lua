local Concord = require("libs.concord")
local gs = require('src.state.GameState'):getInstance()
local sceneManager = require('src.scene.SceneManager'):getInstance()
local soundManager = require('src.sound.SoundManager'):getInstance()
local EventManager = require('src.state.events'):getInstance()
local pretty       = require('libs.batteries.pretty')
local mobData = require "src.generation.mobs"

local aiSystem = Concord.system({pool = {position, stats, crowdControl, state}})

function aiSystem:update(dt)
    for _, entity in ipairs(self.pool) do
    end
end

function aiSystem:getAllMoves(entity)
    for _, e in ipairs(self.pool) do
        if e ~= entity then
            
        end
    end
end


return aiSystem