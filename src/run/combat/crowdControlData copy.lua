local DURATION_UNIT = require "src.run.combat.DURATION_UNIT"

local data = {

    stun = {
        affects = {
            canMove = false,
            canAttack = false,
            canUseAbilities = false,
            displacable = true
        },
        interuptsCasting = true,
        durationUnit = DURATION_UNIT.TURNS,
        duration = 1,
        animation = {},
        adjective = "stunned"
    },


    snare = {
        affects = {
            canMove = false,
            canAttack = true,
            canUseAbilities = false,
            displacable = true
        },
        interuptsCasting = true,
        duration = 1,
        animation = {},
        adjective = "snared"
    },


    knockback = {
        affects = {
            canMove = false,
            canAttack = false,
            canUseAbilities = false,
            displacable = false
        },
        interuptsCasting = true,
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
        animation = {},
        adjective = "pulled"
    },


    displace = {
        affects = {
            canMove = false,
            canAttack = false,
            canUseAbilities = false,
            displacable = true
        },
        interuptsCasting = true,
        animation = {},
        adjective = "displaced"
    },


    taunt = {
        affects = {
            canMove = true,
            canAttack = true,
            canUseAbilities = false,
            displacable = true,
            forcedAttack = true
        },
        interuptsCasting = true,
        animation = {},
        callback = function(matchState, targetEntity, sourceEntity)
            matchState.combatSystem:attack(targetEntity, sourceEntity)
        end,
        adjective = "taunted"
    },
    

    fear = {
        affects = {
            canMove = true,
            canAttack = true,
            canUseAbilities = false,
            displacable = true,
            forcedRandomMovement = true
        },
        interuptsCasting = true,
        animation = {},
        adjective = "feared"
    },


    panic = {
        affects = {
            canMove = true,
            canAttack = true,
            canUseAbilities = false,
            displacable = true,
            forcedRandomMovement = true
        },
        interuptsCasting = true,
        animation = {},
        callback = function(matchState, targetEntity)
            for i = 1, 3 do
                matchState.moveSystem:queueMove(entity, 'panic')
            end
        end,
        adjective = "panicking"
    },


    disarm = {
        affects = {
            canMove = true,
            canAttack = false,
            canUseAbilities = true,
            displacable = true
        },
        interuptsCasting = true,
        duration = 1,
        animation = {},
        adjective = "disarmed"
    },


    suppression = {
        affects = {
            canMove = true,
            canAttack = true,
            canUseAbilities = false,
            displacable = true
        },
        interuptsCasting = true,
        duration = 1,
        animation = {},
        adjective = "suppressed"
    },


    sleep = {
        affects = {
            canMove = false,
            canAttack = false,
            canUseAbilities = false,
            displacable = true
        },
        interuptsCasting = true,
        duration = {1, 3},
        animation = {},
        adjective = "asleep"
        -- particle animation
    },


    slow = {
        alter = {
            customMovePattern = function(pattern)
                --change the pattern
            end
        },
        interuptsCasting = false,
        duration = 1,
        animation = {},
        adjective = "slowed"
    },


    ground = {
        affects = {
            canDash = false
        },
        interuptsCasting = true,
        duration = 1,
        animation = {},
        adjective = "grounded"
    },

    
    wound = {
        affects = {
            canMove = true,
            canAttack = true,
            canUseAbilities = false,
            displacable = true,
            takesExtraDamage = true
        },
        alter = {
            decreaseP = {
                def = 0.4
            }
        },
        interuptsCasting = true,
        duration = {1, 2},
        animation = {},
        adjective = "wounded"
    },


    confusion = {
        affects = {
            canMove = true,
            canAttack = true,
            canUseAbilities = false,
            displacable = true,
            forcedRandomAbilityUse = true
        },
        interuptsCasting = true,
        duration = {1, 2},
        animation = {},
        adjective = "confused"
    },


    jam = {
        affects = {
            canMove = true,
            canAttack = true,
            canUseAbilities = false,
            displacable = true
        },
        interuptsCasting = true,
        duration = 1,
        animation = {},
        adjective = "jammed"
    },


    exhaust = {
        affects = {
            canMove = true,
            canAttack = true,
            canUseAbilities = false,
            displacable = true,
            reducedAttackSpeed = true
        },
        interuptsCasting = true,
        duration = 1,
        animation = {},
        adjective = "exhausted"
    },


    invisibility = {
        affects = {
            canMove = true,
            canAttack = true,
            canUseAbilities = true,
            displacable = true,
            invisibility = true
        },
        interuptsCasting = true,
        duration = 1,
        animation = {},
        adjective = "invisible"
    }
}

return data