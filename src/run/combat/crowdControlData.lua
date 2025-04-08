local ccFunctions = require "src.run.combat.crowdControlFunctions"
local soundManager = require("src.sound.SoundManager"):getInstance()

local data = {

    knockback = {
        affects = {
            canMove = false,
            canAttack = false,
            canUseAbilities = false,
            displacable = false
        },
        interuptsCasting = true,
        duration = 1,
        intensity = 1,
        callback = function(matchState, target, source)
            
            if not target.status or not target.status.current.isDisplaceable then
                return false
            end
            
            local destX, destY = matchState.moveSystem:getDestination(target)

            local dx = target.position.x - source.position.x
            local dy = target.position.y - source.position.y
                        
            dx = dx ~= 0 and (dx / math.abs(dx)) or 0
            dy = dy ~= 0 and (dy / math.abs(dy)) or 0

            local knockbackX, knockbackY = ccFunctions.checkPath(matchState, destX, destY, dx, dy, 1)

            if target.position.x == knockbackX and target.position.y == knockbackY then
                return false
            else
                soundManager:playSound("knockback")
                matchState.moveSystem:move(target, 'knockback', knockbackX, knockbackY)
                return true
            end
        end,
        animation = {},
        adjective = "knocked"
    },


    pull = {
        affects = {
            canMove = false,
            canAttack = false,
            canUseAbilities = false,
            displacable = false
        },
        interuptsCasting = true,
        duration = 1,
        intensity = 1,
        animation = {},
        adjective = "pulled"
    },


    displace = {
        affects = {
            canMove = false,
            canAttack = false,
            canUseAbilities = false,
            displacable = false
        },
        interuptsCasting = true,
        duration = 0.7,
        intensity = 1,
        callback = function(matchState, target, source)
            if not target.status or not target.status.current.isDisplaceable then
                return false
            end

            local destX, destY = matchState.moveSystem:getDestination(target)

            local dx = target.position.x - source.position.x
            local dy = target.position.y - source.position.y
                        
            local ldx, ldy = dy, -dx
            local rdx, rdy = -dy, dx
            
            ldx = ldx ~= 0 and (ldx / math.abs(ldx)) or 0
            ldy = ldy ~= 0 and (ldy / math.abs(ldy)) or 0
            rdx = rdx ~= 0 and (rdx / math.abs(rdx)) or 0
            rdy = rdy ~= 0 and (rdy / math.abs(rdy)) or 0
            
            local lSteppable = matchState:isSteppable(destX + ldx, destY + ldy, target)
            local rSteppable = matchState:isSteppable(destX + rdx, destY + rdy, target)
            
            if lSteppable and rSteppable then
                if math.random() > 0.5 then
                    dx, dy = ldx, ldy
                else
                    dx, dy = rdx, rdy
                end
            elseif lSteppable and not rSteppable then
                dx, dy = ldx, ldy
            elseif not lSteppable and rSteppable then
                dx, dy = rdx, rdy
            else
                return false
            end
            
            local displaceX, displaceY = ccFunctions.checkPath(matchState, destX, destY, dx, dy, 1)
            
            if target.position.x == displaceX and target.position.y == displaceY then
                return false
            else
                soundManager:playSound("displace")
                matchState.moveSystem:move(target, 'displace', displaceX, displaceY)
                return true
            end
        end,
        animation = {},
        adjective = "displaced"
        
    },


    taunt = {
        affects = {
            canUseAbilities = false
        },
        interuptsCasting = true,
        animation = {},
        callback = function(matchState, targetEntity, sourceEntity)
            matchState.combatSystem:attack(targetEntity, sourceEntity)
        end,
        adjective = "taunted"
    },
    

    -- INTENSITY
    fear = {
        affects = {
            canMove = false,
            canAttack = false,
            canUseAbilities = false,
        },
        interuptsCasting = true,
        animation = {},
        adjective = "feared"
    },


    panic = {
        affects = {
            canUseAbilities = false,
        },
        interuptsCasting = true,
        animation = {},
        duration = 3,
        callback = function(matchState, targetEntity, moves)
            for i = 1, moves do
                matchState.moveSystem:queueMove(targetEntity, 'panic')
            end
        end,
        adjective = "panicking"
    }
}

return data