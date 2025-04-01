local class = require 'libs.middleclass'
local Node = require 'src.run.Node'
local matchConfig = require 'src.run.matchConfig'
local GameState   = require('src.state.GameState'):getInstance()
local MatchNode = class("match", Node)
local pickSimple = require "src.generation.functions.pickSimple"
local variantRates = require "src.generation.matchTypeRates"
local bosses = require "src.generation.stageBosses"

function MatchNode:initialize(type, place)
    Node:initialize(self)
    self.type = type
    self.place = place
    self.variant = nil
    self.mystery = false
    self.passed = false
    self.to = {}
    self.from = {}
    self.x = 0
    self.y = 0
    self.screenX = 0
    self.screenY = 0
    self.sprite = nil
    self.matchManager = nil
end

function MatchNode:random()

    self.place = matchConfig.places[math.ceil(GameState.run.rng:get("stageGen") * #matchConfig.places)]
    self.variant = pickSimple(variantRates[self.place])

    assert(self.variant, "No variants defined for " .. self.place)
    
    self.spriteName = self.place .. '_node'

end

function MatchNode:bossRoom(level)

    self.place = bosses[level].name
    self.level = bosses[level].level
    
    self.variant = 'normal'

    self.spriteName = self.place

end

return MatchNode