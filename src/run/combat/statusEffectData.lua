local ccFunctions = require "src.run.combat.crowdControlFunctions"
local soundManager = require("src.sound.SoundManager"):getInstance()

local data = {

    stun = {
        mod = {
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
        mod = {
            canMove = false,
            canUseAbilities = false,
        },
        interuptsCasting = true,
        duration = 1,
        animation = {},
        adjective = "snared"
    },


    disarm = {
        mod = {
            canAttack = false,
        },
        interuptsCasting = true,
        duration = 1,
        animation = {},
        adjective = "disarmed"
    },


    suppression = {
        mod = {
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
        mod = {
            canMove = false,
            canAttack = false,
            canUseAbilities = false,
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
        mod = {
            canDash = false
        },
        interuptsCasting = false,
        duration = 1,
        animation = {},
        adjective = "grounded"
    },

    
    -- wound = {
    --     mod = {
    --         canMove = true,
    --         canAttack = true,
    --         canUseAbilities = true,
    --         displacable = true,
    --         takesExtraDamage = true
    --     },
    --     alter = {
    --         decreaseP = {
    --             healingReduction = 0.3,
    --             def = 0.4
    --         }
    --     },
    --     interuptsCasting = false,
    --     duration = {1, 2},
    --     animation = {},
    --     adjective = "wounded"
    -- },


    -- confusion = {
    --     mod = {
    --         canMove = true,
    --         canAttack = true,
    --         canUseAbilities = false,
    --         displacable = true,
    --     },
    --     alter = {
    --         customMovePattern = function(pattern)
    --             -- scramble the pattern a bit
    --         end
    --     },
    --     interuptsCasting = false,
    --     duration = {1, 2},
    --     animation = {},
    --     adjective = "confused"
    -- },


    jam = {
        mod = {
            canUseAbilities = false,
            isJammed = false
        },
        interuptsCasting = false,
        duration = 1,
        animation = {},
        adjective = "jammed"
    },


    exhaust = {
        mod = {
            canUseAbilities = false,
        },
        interuptsCasting = false,
        duration = 1,
        animation = {},
        adjective = "exhausted"
    },


    invisibility = {
        mod = {
            visible = false
        },
        interuptsCasting = false,
        duration = 1,
        animation = {},
        adjective = "invisible"
    },


    invulnerability = {
        mod = {
            isInvulnerable = true
        },
        interuptsCasting = false,
        duration = 1,
        adjective = "invulnerable"
    },


    playingDead = {
        mod = {
            isTargetable = true
        },
        interuptsCasting = false,
        duration = 1,
        adjective = "playing dead",
        animation = "playing_dead"
    },
}

return data