local DURATION_UNIT = require "src.run.combat.DURATION_UNIT"
local ccFunctions = require "src.run.combat.crowdControlFunctions"
local soundManager = require("src.sound.SoundManager"):getInstance()

local data = {

    stun = {
        affects = {
            canMove = false,
            canAttack = false,
            canUseAbilities = false,
        },
        interuptsCasting = true,
        duration = 1,
        animation = {},
        adjective = "stunned",
        particle = "stun"
    },


    snare = {
        affects = {
            canMove = false,
            canUseAbilities = false,
        },
        interuptsCasting = true,
        duration = 1,
        animation = {},
        adjective = "snared"
    },


    disarm = {
        affects = {
            canAttack = false,
        },
        interuptsCasting = true,
        duration = 1,
        animation = {},
        adjective = "disarmed"
    },


    suppression = {
        affects = {
            canMove = false,
            canAttack = false,
            canUseAbilities = false,
            displacable = false
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


    -- slow = {
    --     alter = {
    --         customMovePattern = function(pattern)
    --             --change the pattern
    --         end
    --     },
    --     interuptsCasting = false,
    --     duration = 1,
    --     animation = {},
    --     adjective = "slowed"
    -- },


    ground = {
        affects = {
            canDash = false
        },
        interuptsCasting = false,
        duration = 1,
        animation = {},
        adjective = "grounded"
    },

    
    wound = {
        affects = {
            canMove = true,
            canAttack = true,
            canUseAbilities = true,
            displacable = true,
            takesExtraDamage = true
        },
        alter = {
            decreaseP = {
                healingReduction = 0.3,
                def = 0.4
            }
        },
        interuptsCasting = false,
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
        },
        alter = {
            customMovePattern = function(pattern)
                -- scramble the pattern a bit
            end
        },
        interuptsCasting = false,
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
        interuptsCasting = false,
        duration = 1,
        animation = {},
        adjective = "jammed"
    },


    exhaust = {
        affects = {
            canUseAbilities = false,
        },
        interuptsCasting = false,
        duration = 1,
        animation = {},
        adjective = "exhausted"
    },


    invisibility = {
        affects = {
            visible = false
        },
        interuptsCasting = false,
        duration = 1,
        animation = {},
        adjective = "invisible"
    },


    invulnerability = {
        affects = {
            isInvulnerable = true
        },
        interuptsCasting = false,
        duration = 1,
        adjective = "invulnerable"
    },


    playingDead = {
        affects = {
            isTargetable = true
        },
        interuptsCasting = false,
        duration = 1,
        adjective = "playing dead",
        animation = "playing_dead"
    }
}

return data