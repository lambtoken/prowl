local class = require 'libs.middleclass'
local Stage = require 'src.run.Stage'
local rng = require 'src.utility.rng'
local EntityFactory = require "src.run.EntityFactory"
local gs = require("src.state.GameState"):getInstance()
local sceneManager = require("src.scene.SceneManager"):getInstance()
local stageConfig = require "src.run.stageConfig"

local Run = class("Run")

function Run:initialize(starterSpecies, seed)
    self.starterSpecies = starterSpecies
    self.currentStage = 1
    self.stages = {}
    self.team = {}
    self.currentNodeCoords = {1, 1}
    self.runHealth = 5

    self.idCounter = 0

    self:addAnimal(starterSpecies)
end

function Run:nextStage()
    self.currentStage = self.currentStage + 1
    self.currentNodeCoords = {1, 1}
end

function Run:generateStages()
    for i = 1, 3, 1 do
        self.stages[i] = Stage:new(i)
        self.stages[i]:generate()
    end
end

-- function Run:generateMatches()
--     self.stages[1]
-- end

function Run:setSeed(seed)
    self.seed = seed
    self.rng = rng:new(self.seed)
    self.rng:addGenerator('stageGen')
    self.rng:addGenerator('general')
end

function Run:addAnimal(species)
    table.insert(self.team, EntityFactory:createAnimal(species, 0, 0, 1))
end

function Run:decreaseHealth()
    self.runHealth = math.max(0, self.runHealth - 1)
end

function Run:giveItemAndProgress(itemName)
    gs.match.itemSystem:giveItem(gs.run.team[1], itemName)
    gs.currentMatchNode.passed = true
    
    if self.currentNodeCoords[1] == #stageConfig.format - 1 then
        self:nextStage()
    else
        self.currentNodeCoords = {gs.currentMatchNode.x, gs.currentMatchNode.y}
    end

    sceneManager:switchScene( "runMap")
end

function Run:setOutcome()
    if self.runHealth > 0 then
        self.runWon = true
        return
    end
        
    self.runWon = false
    
end

return Run