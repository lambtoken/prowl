local soundManager = require("src.sound.SoundManager"):getInstance()
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
        passive = {
            onStepped = function(matchState, entity, object)
                matchState.combatSystem:heal(entity, 2)
                matchState.stateSystem:changeState(object, "dead")
                soundManager:playSound("bite")
            end
        },
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
        passive = {
            onStepped = function(matchState, entity, object)
                matchState.combatSystem:heal(entity, 1)
                matchState.stateSystem:changeState(object, "dead")
                soundManager:playSound("bite")
            end
        },
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
        passive = {
            onStepped = function(matchState, entity, object)
                matchState.combatSystem:heal(entity, 3)
                matchState.stateSystem:changeState(object, "dead")
                soundManager:playSound("bite")
            end
        },
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
        passive = {
            -- onAttacked = function(matchState, object, entity)
            --     matchState.animationSystem:playAnimation(object, "hit")
            --     matchState.stateSystem:changeState(object, "dying")
            --     matchState.animationSystem:playAnimation(object, "death")                
            --     soundManager:playSound("breaking")
            -- end,
            onHovered = function(matchState, object, entity)
                matchState.animationSystem:playAnimation(object, "hit")
                matchState.stateSystem:changeState(object, "dying")
                matchState.animationSystem:playAnimation(object, "death")
                soundManager:playSound("breaking")
            end
        },
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
        passive = {
            onStepped = function(matchState, entity, object)
                matchState.combatSystem:hit(entity, 2)
                soundManager:playSound("bear_trap")
                matchState.stateSystem:changeState(object, "dead")
            end
        },
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
        passive = {
            onStepped = function(matchState, entity, object)
                matchState.combatSystem:hit(entity, 1)
                matchState.animationSystem:playAnimation(object, "trigger_death")
                soundManager:playSound("mouse_trap")
            end
        },
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
        passive = {
            onStepped = function(matchState, entity, object)
                matchState.combatSystem:hit(entity, 1)
            end
        },
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
        passive = {
            onAttacked = function(matchState, object, entity)
                local knockback = matchState.crowdControlSystem:applyCC(object, "knockback", entity)
                if knockback then 
                    matchState.animationSystem:playAnimation(object, "tumble")
                    return true
                else
                    local touching = matchState.moveSystem:getTouching(object.position.x, object.position.y)
                    if #touching > 0 then
                        matchState.animationSystem:playAnimation(object, "trigger")
                        for index, animal in ipairs(touching) do
                            if animal ~= entity then
                                matchState.combatSystem:hit(animal, 1)
                            end
                        end
                        return true
                    end
                end
                return false
            end,
            onTouched = function(matchState, object, entity)
                if entity.state.current == "alive" then
                    matchState.combatSystem:hit(entity, 1)
                end
            end
        },
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
        passive = {
            onTouched = function(matchState, object, entity)
                if entity.state.current == "alive" then
                    matchState.combatSystem:hit(entity, 1)
                end
            end
        },
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
        passive = {
            onStepped = function(matchState, entity, object)
                matchState.combatSystem:hit(entity, 1)
            end
        },
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
        passive = {
            onAttacked = function(matchState, object, entity)
                matchState.eventManager:emit("registerTimer", object, 1, "explosion", {entity = object, amount = 3})
                soundManager:playSound("hiss")
            end
        },
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
        passive = {
            onStepped = function(matchState, entity, object)
                matchState.buffDebuffSystem:applyEffect(entity, "lucky_clover", object)
                matchState.stateSystem:changeState(object, "dead")
                matchState.statsSystem:calculateStats()
            end
        },
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
        passive = {
            onStepped = function(matchState, entity, object)
                matchState.buffDebuffSystem:applyEffect(entity, "coffee", object)
                matchState.stateSystem:changeState(object, "dead")
                matchState.statsSystem:calculateStats()
            end
        },
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
        passive = {
            onAttacked = function(matchState, object, entity)
                local knockback = matchState.crowdControlSystem:applyCC(object, "knockback", entity)
                if knockback then 
                    matchState.animationSystem:playAnimation(object, "tumble")
                    return true
                end
                return false
            end,
            onStep = function(matchState, object)
                print("WEE HIT THIS BOI")
                if object.state.current == "alive" then
                    local targets = matchState.moveSystem:getTouching(object.position.x, object.position.y, "animal")
                    for index, target in ipairs(targets) do
                        matchState.combatSystem:hit(target, 1)
                    end
                end
            end
        },
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