local particles = require "src.render.particles"
local RM = require("src.render.RenderManager"):getInstance()

local ParticleManager = {}
ParticleManager.__index = ParticleManager

function ParticleManager:new()
    local o = {
        pool = {},
        activeSystems = {},
        nextId = 0
    }
    setmetatable(o, self)
    return o
end

function ParticleManager:createSystem(type)
    if type == "hit" then
        return particles.hit()
    elseif type == "heal" then
        return particles.heal()
    elseif type == "poison" then
        return particles.poison()
    elseif type == "step" then
        return particles.step()
    else
        return nil
    end
end

function ParticleManager:getSystem(type)
    self.pool[type] = self.pool[type] or {}

    if #self.pool[type] > 0 then
        return table.remove(self.pool[type])
    else
        return self:createSystem(type)
    end
end

function ParticleManager:play(type, x, y, countOrDuration, mode)
    mode = mode or "burst"
    local ps = self:getSystem(type).system
    if not ps then return nil end

    ps:setPosition(x + RM.tileSize / 2, y + RM.tileSize / 2)

    local id = self.nextId
    self.nextId = self.nextId + 1

    local entry = {
        id = id,
        type = type,
        system = ps,
        mode = mode
    }

    if mode == "burst" then
        ps:setEmitterLifetime(-1)
        ps:emit(countOrDuration or 5)
    elseif mode == "continuous" then
        local duration = countOrDuration or 1.0
        ps:setEmitterLifetime(duration)
        ps:setEmissionRate(20)
        ps:start()
        entry.dieAt = love.timer.getTime() + duration
    end

    self.activeSystems[id] = entry
    return id
end

function ParticleManager:update(dt)
    local now = love.timer.getTime()
    for id, psEntry in pairs(self.activeSystems) do
        local ps = psEntry.system
        ps:update(dt)

        local remove = false
        if psEntry.mode == "burst" then
            remove = ps:getCount() == 0
        elseif psEntry.mode == "continuous" then
            remove = (now >= (psEntry.dieAt or 0)) and ps:getCount() == 0
        end

        if remove then
            self.pool[psEntry.type] = self.pool[psEntry.type] or {}
            table.insert(self.pool[psEntry.type], ps)
            self.activeSystems[id] = nil
        end
    end
end

function ParticleManager:draw()
    for _, psEntry in pairs(self.activeSystems) do
        love.graphics.draw(psEntry.system)
    end
end

function ParticleManager:stopSystem(id)
    local psEntry = self.activeSystems[id]
    if not psEntry then return end

    psEntry.system:stop()
    self.pool[psEntry.type] = self.pool[psEntry.type] or {}
    table.insert(self.pool[psEntry.type], psEntry.system)
    self.activeSystems[id] = nil
end

return ParticleManager
