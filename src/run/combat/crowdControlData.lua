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

            -- acount for if target already knockbacked so multiple kbs stack
            -- calculate where will that knockback take them and then work from there
            -- local knockbacks = matchState.moveSystem.getOfType('knockback')
            -- if #knockbacks > 0 then
            
            --     

            -- end
            
            if not target.status or not target.status.current.isDisplaceable then
                return false
            end

            local dx = target.position.x - source.position.x
            local dy = target.position.y - source.position.y
                        
            dx = dx ~= 0 and (dx / math.abs(dx)) or 0
            dy = dy ~= 0 and (dy / math.abs(dy)) or 0
    

            if matchState:isSteppable(target.position.x + dx, target.position.y + dy, target) then
                local knockbackX, knockbackY = ccFunctions.calculateKnockbackPosition(matchState, source.position.x, source.position.y, target.position.x, target.position.y, 1, matchState.terrain)
                soundManager:playSound("knockback")
                matchState.moveSystem:move(target, 'knockback', knockbackX, knockbackY)
                
                return true
            end
 
            return false
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

            local dx = target.position.x - source.position.lastStepX
            local dy = target.position.y - source.position.lastStepY
                        
            local ldx, ldy = dy, -dx
            local rdx, rdy = -dy, dx
            
            ldx = ldx ~= 0 and (ldx / math.abs(ldx)) or 0
            ldy = ldy ~= 0 and (ldy / math.abs(ldy)) or 0
            rdx = rdx ~= 0 and (rdx / math.abs(rdx)) or 0
            rdy = rdy ~= 0 and (rdy / math.abs(rdy)) or 0
            
            local lSteppable = matchState:isSteppable(target.position.x + ldx, target.position.y + ldy, target)
            local rSteppable = matchState:isSteppable(target.position.x + rdx, target.position.y + rdy, target)
            
            if lSteppable and rSteppable then
                local side = math.random() > 0.5 and "left" or "right"
                local displaceX, displaceY = ccFunctions.calculatePerpendicularPosition(matchState, source.position.lastStepX, source.position.lastStepY, target.position.x, target.position.y, 1, matchState.terrain, side)
                soundManager:playSound("displace")
                matchState.moveSystem:move(target, 'displace', displaceX, displaceY)

                return true
            elseif lSteppable and not rSteppable then
                local displaceX, displaceY = ccFunctions.calculatePerpendicularPosition(matchState, source.position.lastStepX, source.position.lastStepY, target.position.x, target.position.y, 1, matchState.terrain, 'left')
                soundManager:playSound("displace")
                matchState.moveSystem:move(target, 'displace', displaceX, displaceY)

                return true
            elseif not lSteppable and rSteppable then
                local displaceX, displaceY = ccFunctions.calculatePerpendicularPosition(matchState, source.position.lastStepX, source.position.lastStepY, target.position.x, target.position.y, 1, matchState.terrain, 'right')
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