local particles = require "src.render.particles"
local RM = require ('src.render.RenderManager'):getInstance()

local ParticleManager = {}
ParticleManager.__index = ParticleManager

function ParticleManager:new()
    local o = {
        pool = {},
        hit = particles.hit(),
        heal = particles.heal()
    }

    setmetatable(o, self)
    o.__index = self
    return o
end


local pool = {}

local activeSystems = {}


function ParticleManager:getSystem(type)
    local ps

    if #pool > 0 then
        ps = table.remove(pool)
    else
        ps = self:createSystem(type)
    end
    ps.active = true
    table.insert(activeSystems, ps)
    return ps
end


function ParticleManager:createSystem(type)
    local ps

    if type == "hit" then
        ps = particles.hit()
    elseif type == "heal" then
        ps = particles.heal()
    elseif type == "poison" then
        ps = particles.poison()
    elseif type == "step" then
        ps = particles.step()
    else
        return nil
    end

    return ps
end

function ParticleManager:play(type, x, y, arg1)
    if type == "hit" then
        arg1 = arg1 or 5
        self.hit.system:setPosition(x + RM.tileSize / 2, y + RM.tileSize / 2)
        self.hit.system:emit(arg1)
    elseif type == "heal" then
        arg1 = arg1 or 3
        self.heal.system:setPosition(x + RM.tileSize / 2, y + RM.tileSize / 2)
        self.heal.system:emit(arg1)
    end
end


function ParticleManager:update(dt)
    if self.hit then
        self.hit.system:update(dt)
    end

    if self.heal then
        self.heal.system:update(dt)
    end
    -- for i = #activeSystems, 1, -1 do
    --     local ps = activeSystems[i]
    --     if ps.system then
    --         ps.system:update(dt)
    --         -- Check if the system is done emitting particles (use your own condition)
    --         if not ps.system:isActive() then
    --             -- Move the system back to the pool
    --             table.remove(activeSystems, i)
    --             table.insert(pool, ps.system)
    --         end
    --     end
    -- end
end


function ParticleManager:draw()
    love.graphics.draw(self.hit.system)
    love.graphics.draw(self.heal.system)
    -- for _, ps in ipairs(activeSystems) do
    --     if ps.system then
    --         love.graphics.draw(ps.system, ps.x, ps.y)
    --     end
    -- end
end


function ParticleManager:stopSystem(ps)
    for i, activePs in ipairs(activeSystems) do
        if activePs == ps then
            table.remove(activeSystems, i)
            table.insert(pool, activePs.system)
            break
        end
    end
end


return ParticleManager