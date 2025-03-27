local Concord = require("libs.concord")
local EventManager = require("src.state.events"):getInstance()
-- import mobs and items data

local effectSystem = Concord.system({pool = {metadata, state}})

-- handles
--      stat buffs and debuffs
--      disabling
--      defensive
--      

function effectSystem:init()

    
end

function effectSystem:newStatusEffect()
    -- 1 turn stun
    local e = {
        duration = 1,
        targets = {
            canAttack = false,
            canMove = false,
            canUseAbilities = false,
        },
        interuptCasting = true,
    }
end

function effectSystem:updateState()
    for index, value in ipairs(self.pool) do
        
    end
end

return effectSystem