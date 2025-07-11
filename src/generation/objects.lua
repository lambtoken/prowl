local ER = require "src.generation.effectRegistry"
local tablex = require "libs.batteries.tablex"

local DEFAULT = {
    stepsOn = { "ground" }
}

local DEFAULT_STATUS = {
    canTeleport = true,
    isDisplaceable = false,
    isTargetable = false,
}

local objects = {

    apple = {
        name = 'apple',
        sprite = 'apple',
        steppable = true,
        passive = ER.red_apple,
        status = {
            canTeleport = DEFAULT_STATUS.canTeleport,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,
    },

    green_apple = {
        name = 'green_apple',
        sprite = 'green_apple',
        type = 'heal',
        steppable = true,
        passive = ER.green_apple,
        status = {
            canTeleport = DEFAULT_STATUS.canTeleport,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,

    },


    gold_apple = {
        name = 'gold_apple',
        sprite = 'gold_apple',
        type = 'heal',
        steppable = true,
        passive = ER.golden_apple,
        status = {
            canTeleport = DEFAULT_STATUS.canTeleport,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,

    },
    barrel = {
        name = 'barrel',
        sprite = 'barrel',
        type = 'dumb',
        steppable = false,
        status = {
            canTeleport = DEFAULT_STATUS.canTeleport,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,

    },

    crate = {
        name = 'crate',
        sprite = 'crate',
        type = 'dumb',
        steppable = false,
        status = {
            canTeleport = DEFAULT_STATUS.canTeleport,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,

    },

    table = {
        name = 'table',
        sprite = 'table',
        type = 'dumb',
        steppable = false,
        status = {
            canTeleport = DEFAULT_STATUS.canTeleport,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,

    },

    vase = {
        name = 'vase',
        sprite = 'vase',
        type = 'dumb',
        steppable = false,
        passive = ER.trample,
        status = {
            canTeleport = DEFAULT_STATUS.canTeleport,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = true,
        },
        stepsOn = DEFAULT.stepsOn,

    },

    -- small_pillar = {
    --     name = 'small_pillar',
    --     type = 'dumb'
    -- },

    spruce_tree = {
        name = 'spruce_tree',
        sprite = 'spruce_tree',
        type = 'tree',
        steppable = false,
        status = {
            canTeleport = DEFAULT_STATUS.canTeleport,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,
    },

    spruce_tree_snowy = {
        name = 'spruce_tree_snowy',
        sprite = 'spruce_tree_snowy',
        type = 'tree',
        steppable = false,
        status = {
            canTeleport = DEFAULT_STATUS.canTeleport,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,
    },

    spruce_tree_snowy_partial = {
        name = 'spruce_tree_snowy_partial',
        sprite = 'spruce_tree_snowy_partial',
        type = 'tree',
        steppable = false,
        status = {
            canTeleport = DEFAULT_STATUS.canTeleport,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,
    },

    oak_tree = {
        name = 'oak_tree',
        sprite = 'oak_tree',
        type = 'tree',
        steppable = false,
        status = {
            canTeleport = DEFAULT_STATUS.canTeleport,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,

    },

    rock = {
        name = 'rock',
        sprite = 'rock',
        type = 'dumb',
        steppable = false,
        passive = {
            crossfireAttackModifier = {
                {'decreaseP', 'atk', '25'}
            }
        },
        status = {
            canTeleport = DEFAULT_STATUS.canTeleport,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,

    },


    mushroom = {
        name = 'mushroom',
        sprite = 'mushroom',
        type = 'dumb',
        steppable = false,
        status = {
            canTeleport = DEFAULT_STATUS.canTeleport,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,

    },

    bear_trap = {
        name = 'bear_trap',
        sprite = 'bear_trap',
        type = 'trap',
        steppable = true,
        passive = ER.paw_catcher,
        status = {
            canTeleport = false,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,
    },

    mouse_trap = {
        name = 'mouse_trap',
        sprite = 'mouse_trap',
        type = 'trap',
        steppable = true,
        passive = ER.tiny_snare,
        status = {
            canTeleport = false,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,

    },

    ice_rock = {
        name = 'ice_rock',
        sprite = 'ice_rock',
        type = 'dumb',
        steppable = false,
        status = {
            canTeleport = DEFAULT_STATUS.canTeleport,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,

    },

    ice_spike = {
        name = 'ice_spike',
        sprite = 'ice_spike',
        type = 'trap',
        steppable = true,
        passive = ER.frostfang,
        status = {
            canTeleport = false,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,
        
    },

    shrub = {
        name = 'shrub',
        sprite = 'shrub',
        type = 'plant',
        steppable = false,
        passive = {},
        status = {
            canTeleport = false,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,

    },

    tumbleweed = {
        name = 'tumbleweed',
        sprite = 'tumbleweed',
        type = 'idk',
        steppable = false,
        passive = ER.tumble,
        status = {
            canTeleport = false,
            isDisplaceable = true,
            isTargetable = true,
        },
        stepsOn = DEFAULT.stepsOn,

    },

    cactus = {
        name = 'shrub',
        sprite = 'desert_node',
        type = 'plant',
        steppable = false,
        passive = ER.dont_touch_me,
        status = {
            canTeleport = false,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,

    },

    small_pillar = {
        name = 'small_pillar',
        sprite = 'small_pillar',
        type = 'dumb',
        steppable = false,
        passive = {},
        status = {
            canTeleport = false,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,

    },

    flower = {
        name = 'flower',
        sprite = 'apple',
        type = 'flower',
        steppable = true,
        passive = {},
        status = {
            canTeleport = false,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,
    },

    spikes = {
        name = 'spikes',
        sprite = 'spikes',
        type = 'trap',
        steppable = true,
        passive = ER.impale,
        status = {
            canTeleport = false,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,
    },

    crack = {
        name = 'crack',
        sprite = 'crack',
        type = 'trap',
        steppable = true,
        passive = {
            -- onStepped = function(matchState, entity, object)
            --     matchState.combatSystem:hit(entity, 1)
            -- end
        },
        status = {
            canTeleport = false,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,
    },

    bomb = {
        name = 'bomb',
        sprite = 'bomb',
        type = 'trap',
        steppable = false,
        passive = ER.boom,
        status = {
            canTeleport = false,
            isDisplaceable = true,
            isTargetable = true,
        },
        stepsOn = DEFAULT.stepsOn,
    },

    lilypad = {
        name = 'lilypad',
        sprite = 'lilypad',
        type = 'dumb',
        steppable = true,
        passive = {},
        status = {
            canTeleport = false,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn, -- change to water later on
    },

    lucky_clover = {
        name = 'lucky_clover',
        sprite = 'lucky_clover',
        type = 'consumable',
        steppable = true,
        passive = ER.get_lucky,
        status = {
            canTeleport = false,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,
    },

    coffee = {
        name = 'coffee',
        sprite = 'coffee',
        type = 'consumable',
        steppable = true,
        passive = ER.jitter,
        status = {
            canTeleport = false,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,
    },

    beach_ball = {
        name = 'beach_ball',
        sprite = 'beach_ball',
        type = 'dumb',
        steppable = false,
        passive = ER.beach_bounce,
        status = {
            canTeleport = false,
            isDisplaceable = true,
            isTargetable = true,
        },
        stepsOn = DEFAULT.stepsOn,
    },

    beach_umbrella = {
        name = 'beach_umbrella',
        sprite = 'beach_umbrella',
        type = 'dumb',
        steppable = false,
        passive = {},
        status = {
            canTeleport = DEFAULT_STATUS.canTeleport,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,
    },

    meadow_rock = {
        name = 'meadow_rock',
        sprite = 'meadow_rock',
        type = 'dumb',
        steppable = false,
        passive = {},
        status = {
            canTeleport = DEFAULT_STATUS.canTeleport,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,
    },

    meadow_rock_2 = {
        name = 'meadow_rock_2',
        sprite = 'meadow_rock_2',
        type = 'dumb',
        steppable = false,
        passive = {},
        status = {
            canTeleport = DEFAULT_STATUS.canTeleport,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,
    },

    meadow_rock_3 = {
        name = 'meadow_rock_3',
        sprite = 'meadow_rock_3',
        type = 'dumb',
        steppable = false,
        passive = {},
        status = {
            canTeleport = DEFAULT_STATUS.canTeleport,
            isDisplaceable = DEFAULT_STATUS.isDisplaceable,
            isTargetable = DEFAULT_STATUS.isTargetable,
        },
        stepsOn = DEFAULT.stepsOn,
    },

}

return objects