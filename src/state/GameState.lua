local pretty = require 'libs.batteries.pretty'
local class = require 'libs.middleclass'

local rng = require 'src.utility.rng'

local GameState = {}
GameState.__index = GameState
local instance = nil

function GameState:new() 
    local o = {}
    setmetatable(o, self)
    self._index = self
    o:initialize()

    return o
end

function GameState:getInstance()
    if not instance then
        instance = GameState:new()
    end
    return instance
end

function GameState:initialize()
    self.isPaused = false
    self.run = nil
    self.unlocks = {}
    self.settings = {
        UIscale = 1,
        musicVolume = 1,
        soundEffectsVolume = 1,
        pickUpStyle = 'pivot',
        cursorSize = 1,
        cursor = 'classic',
        particles = true,
        particlesOnClick = true,
        screenShake = true,
        speed = 1,
        difficulty = "medium"
    }
    self.achievements = {}
    self:setSeed(os.time())
end

function GameState:setSeed(seed)
    self.seed = seed
    self.rng = rng:new(self.seed)
    self.rng:addGenerator('general')
end

function GameState:loadData()

end

function GameState:saveData()
    -- path??    


end

function GameState:setRun(run)
    self.run = run
    self.run:generateStages()
end

function GameState:removeRun()
    self.run = nil
end

function GameState:getRun()
    return self.run
end

return GameState