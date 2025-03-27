local Concord = require("libs.concord")

local statusEFfectSystem = Concord.system({pool = {status}})

function statusEFfectSystem:applyAllStatusEffects()
    for _, entity in ipairs(self.pool) do 
        local statusEffects = entity.statusEffects

        for _, entity in ipairs(statusEffects.effects) do 
            
        end
    end
end

function statusEFfectSystem:updateEffects()
    for _, entity in pairs(self.pool) do
        for i = #entity.statusEffect.effects, 1, -1 do
            local effect = entity.statusEffect.effects[i]

            if effect.duration > 0 then
                effect.duration = effect.duration - 1
            else
                effect = nil  -- Remove expired effect
            end
        end
    end
end

-- reset animations

-- add status effect:
-- type, duration(turns)
-- send to ps entity address and type


-- for ps
-- have a periodical cleanup function
-- reuse inactive ps

return statusEFfectSystem