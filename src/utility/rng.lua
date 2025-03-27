local rngManager = {}
rngManager.__index = rngManager


function rngManager:new(seed)

    local o = {
        seed = seed or os.time(),
        generators = {}
    }

    setmetatable(o, self)
    self.__index = self
    return o
end


function rngManager:setSeed(seed)
    assert(seed, "Seed cannot be nil.")

    self.seed = seed

    for i in pairs(self.generators) do
        i:setSeed(seed)
    end
end

function rngManager:setSeedTo(generator, seed)
    assert(seed, "Seed cannot be nil.")
    assert(self.generators[generator], "Generator " .. generator .. " doesn't exist!")

    self.generators[generator]:setSeed(seed)
end


function rngManager:addGenerator(name)
    assert(name, "No name provided for the generator!")
    assert(not self.generators[name], "Generator with that name already exists!")
    self.generators[name] = love.math.newRandomGenerator(self.seed)
end


function rngManager:removeGenerator(name)
    assert(name, "No name provided for the generator!")
    assert(self.generators[name], "Generator '" .. name .. "' doesn't exist to be removed!")
    self.generators[name] = nil
end


function rngManager:getStates()

    local states = {}

    for i, v in pairs(self.generators) do
        states[i] = v:getState()
    end

    return states

end


function rngManager:setState(name, state)
    self.generators[name]:setState(state)
end


function rngManager:setStates(stateArr)
    for i, v in pairs(stateArr) do
        assert(self.generators[i], "Rng generator '" .. v .. "' does not exist!")
        self.generators[i]:setState(v)
    end
end

function rngManager:get(generatorName, bottom, top)
    assert(self.generators[generatorName], "Generator ".. generatorName .. " doesn't exist.")

    if bottom and top then
        return self.generators[generatorName]:random(bottom, top)
    else
        return self.generators[generatorName]:random()
    end
    
end


return rngManager