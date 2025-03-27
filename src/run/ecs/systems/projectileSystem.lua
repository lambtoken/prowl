local Concord = require("libs.concord")
local CC = require("src.run.combat.crowdControlData")

local projectileSystem = Concord.system({pool = {pos, renderable}})


function projectileSystem:update()
    for _, entity in pairs(self.entities) do
        for _, effect in pairs(entity.crowdControl.effects) do
            if effect.duration > 0 then
                effect.duration = effect.duration - 1
            else
                effect = nil  -- Remove expired effect
            end
        end
    end
end

function projectileSystem:newProjectile(type, startX, startY, targetX, targetY, velocity, onHitCallback)

end

return projectileSystem