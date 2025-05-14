local Concord = require("libs.concord")
local CC = require("src.run.combat.crowdControlData")
local projectileData = require("src.generation.projectiles")
local projectileSystem = Concord.system({pool = {"projectile", "position", "renderable", "collider"}})

function projectileSystem:update()
    for _, entity in pairs(self.entities) do
    end
end

function projectileSystem:createProjectile(type, startX, startY, targetX, targetY, ownerId)
    local gs = require("src.state.GameState"):getInstance()
    gs.match:newProjectile(type, startX, startY, targetX, targetY, ownerId)
end

return projectileSystem