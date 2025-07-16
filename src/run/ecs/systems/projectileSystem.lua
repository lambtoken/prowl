local Concord = require("libs.concord")
local CC = require("src.run.combat.crowdControlData")
local projectileData = require("src.generation.projectiles")
local EventManager = require("src.state.events"):getInstance()
local gs = require("src.state.GameState"):getInstance()

local projectileSystem = Concord.system({pool = {"projectile", "position", "renderable", "collider"}})

function projectileSystem:init()
    self.stoppedProjectiles = {}
end

function projectileSystem:update(dt)
    local activeEntities = {}
    for _, entity in ipairs(self.pool) do
        activeEntities[entity] = true
    end
    
    for entity, _ in pairs(self.stoppedProjectiles) do
        if not activeEntities[entity] then
            self.stoppedProjectiles[entity] = nil
        end
    end
    
    for _, entity in ipairs(self.pool) do
        if not entity.projectile or not entity.metadata or entity.metadata.type ~= "projectile" then
            goto continue
        end
        
        local wasMoving = self.stoppedProjectiles[entity] == false or self.stoppedProjectiles[entity] == nil
        local isNowStopped = entity.position.customMove == nil
        
        if wasMoving and isNowStopped and not entity.projectile.despawnTimerStarted then
            entity.projectile.despawnTimerStarted = true
                        
            table.insert(entity.timers.timers, gs.match.timerSystem:newTimer(entity.projectile.despawnTime, "despawnProjectile", {
                entityId = entity.metadata.id
            }))
        end
        
        self.stoppedProjectiles[entity] = isNowStopped
        
        ::continue::
    end
end

function projectileSystem:createProjectile(type, startX, startY, targetX, targetY, ownerId)
    gs.match:newProjectile(type, startX, startY, targetX, targetY, ownerId)
end

return projectileSystem