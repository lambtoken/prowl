local test = require("src.test.tinytest")
local gs = require("src.state.GameState"):getInstance()
local mm = require("src.run.MatchManager")
local factory = require("src.run.EntityFactory")

local tests_tests = test.new()

tests_tests:add("just a test", function()
    test.eq(1, 1)
end)

tests_tests:add("attack", function()

    gs.match:init()

    local phoenix = factory:createAnimal("phoenix", 0, 0, 1)
    local chicken = factory:createAnimal("chicken", 0, 0, 1)

    gs.match.combatSystem:attack(phoenix, chicken)
    test.eq(chicken.stats.current.hp, 0)
end)

return tests_tests

-- we can either create the match manager once
-- or create a new one for each test

-- the best way is to create a new one for each test
-- this way we can test the match manager in isolation
-- and we can reset the game state between tests

-- the reason we did this is because the match manager
-- in it's item system has functions that we needed
-- in other scenes, like giveItem()