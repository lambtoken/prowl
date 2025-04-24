local Match = require "src.run.MatchManager"

local Test = require "src.run.tests.test"

local tests = {}
local testmatch = nil

local function instantiate()
-- create a new match
   testmatch = Match:new() 
-- add some animals
-- add some items
end

local function print_tests_results()

end

return function()
    instantiate()
    
    for key, value in pairs(tests) do
        value:run()
    end

    print_tests_results()
end