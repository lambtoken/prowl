local DEFAULT = {
    moves = 1,
    crit = 0,
    critDamage = 1.75,
    lifeSteal = 0,
    luck = 0,
    stepsOn = { "ground" },
}

local mobs = {
    chicken = 
    {
        name = 'chicken',
        sprite = 'chicken',
        stats = {
            atk = 1,
            def = 0,
            maxHp = 4,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 1, 0},
            {1, 0, 1},
            {0, 1, 0},
        },
        atkPattern = {
            {0, 1, 0},
            {1, 0, 1},
            {0, 1, 0},
        },
        passive = {
            {
                trigger = "onStep",
                effect = function(matchState) end
            }
        }
    },
    axolotl = 
    {
        name = 'axolotl',
        sprite = 'axolotl',
        stats = {
            atk = 2,
            def = 0,
            maxHp = 4,
            moves = 2,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = { "ground", "water" },

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
    },
    rat = 
    {
        name = 'rat',
        sprite = 'rat',
        stats = {
            atk = 1,
            def = 0,
            maxHp = 3,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {1, 1, 1},
            {1, 0, 1},
            {1, 1, 1},
        },
        atkPattern = {
            {1, 0, 1},
            {0, 0, 0},
            {1, 0, 1},
        }
    },
    cat = 
    {
        name = 'cat',
        sprite = 'cat',
        stats = {
            atk = 2,
            def = 0,
            maxHp = 6,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = { "ground", "tree" },

        movePattern = {
            {1, 1, 1},
            {1, 0, 1},
            {1, 1, 1},
        },
        atkPattern = {
            {0, 1, 0},
            {1, 0, 1},
            {0, 1, 0},
        }
    },
    -- squid = 
    -- {
    --     name = 'squid',
    --     sprite = 'squid',
    --     stats = {
    --         atk = 2,
    --         def = 0,
    --         maxHp = 4,
    --         moves = DEFAULT.moves,
    --         crit = DEFAULT.crit,
    --         critDamage = DEFAULT.critDamage,
    --         lifeSteal = DEFAULT.lifeSteal,
    --         luck = DEFAULT.luck
    --     },
    --     stepsOn = { "water" },

    --     movePattern = {
    --         {0, 0, 1, 0, 0},
    --         {0, 0, 1, 0, 0},
    --         {1, 1, 0, 1, 1},
    --         {0, 0, 1, 0, 0},
    --         {0, 0, 1, 0, 0}
    --     },
    --     atkPattern = {
    --         {0, 0, 0, 0, 0},
    --         {1, 0, 1, 0, 1},
    --         {1, 0, 0, 0, 1},
    --         {1, 0, 1, 0, 1},
    --         {0, 0, 0, 0, 0}
    --     }
    -- },
    snake = 
    {
        name = 'snake',
        sprite = 'snake',
        stats = {
            atk = 1,
            def = 1,
            maxHp = 4,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        }
    },
    deer = 
    {
        name = 'deer',
        sprite = 'deer',
        stats = {
            atk = 2, -- 4,
            def = 1,
            maxHp = 5,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 1, 0},
            {1, 0, 1},
            {0, 1, 0}
        },
        atkPattern = {
            {0, 1, 0},
            {1, 0, 1},
            {0, 1, 0}
        },
        passive = {
            onAttack = function(matchState, source, target) 
                matchState.crowdControlSystem:applyCC(target, "knockback", source)
            end

            -- do i need to register these "register this!"
            -- or do i check for each animal passives effects and s#!t 
        }
    },
    bat = 
    {
        name = 'bat',
        sprite = 'bat',
        stats = {
            atk = 3,
            def = 2,
            maxHp = 4,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = 0.1,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        }
    },
    duck = 
    {
        name = 'duck',
        sprite = 'duck',
        stats = {
            atk = 2,
            def = 1,
            maxHp = 5,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = 0.2
        },
        stepsOn = { "ground", "water" },

        movePattern = {
            {0, 1, 0},
            {1, 0, 1},
            {0, 1, 0},
        },
        atkPattern = {
            {0, 1, 0},
            {1, 0, 1},
            {0, 1, 0},
        }
    },
    spider = 
    {
        name = 'spider',
        sprite = 'spider',
        stats = {
            atk = 1,
            def = 1,
            maxHp = 5,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = { "ground", "wall" },

        -- maybe have it so it flips its pattern every other move
        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 1, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 1, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 0, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 0, 0, 0}
        }
    },
    bull = 
    {
        name = 'bull',
        sprite = 'bull',
        stats = {
            atk = 2,
            def = 1,
            maxHp = 6,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 0, 0, 1, 0, 0, 0},
            {0, 0, 0, 1, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0},
            {1, 1, 0, 0, 0, 1, 1},
            {0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 1, 0, 0, 0},
            {0, 0, 0, 1, 0, 0, 0},
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        passive = {
            onHover = function(matchState, target, source)
                matchState.crowdControlSystem:applyCC(target, "displace", source)
            end
        }
    },
    rabbit = 
    {
        name = 'rabbit',
        sprite = 'rabbit',
        stats = {
            atk = 2,
            def = 2,
            maxHp = 4,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {1, 0, 1, 0, 1},
            {0, 0, 0, 0, 0},
            {1, 0, 0, 0, 1},
            {0, 0, 0, 0, 0},
            {1, 0, 1, 0, 1}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        }
    },
    fox = 
    {
        name = 'fox',
        sprite = 'fox',
        stats = {
            atk = 2,
            def = 0,
            maxHp = 4,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 1, 1, 1, 0},
            {0, 1, 0, 1, 0},
            {0, 1, 1, 1, 0},
            {0, 0, 0, 0, 0}
        }
    },
    crow = 
    {
        name = 'crow',
        sprite = 'crow',
        stats = {
            atk = 2,
            def = 1,
            maxHp = 6,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = { "ground", "fence" },

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {1, 1, 0, 1, 1},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        }
    },
    bear = 
    {
        name = 'bear',
        sprite = 'bear',
        stats = {
            atk = 2,
            def = 2,
            maxHp = 6,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        }
    },
    polar_bear = 
    {
        name = 'polar bear',
        sprite = 'polar_bear',
        stats = {
            atk = 3,
            def = 1,
            maxHp = 6,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        }
    },
    black_bear = 
    {
        name = 'black bear',
        sprite = 'black_bear',
        stats = {
            atk = 3,
            def = 1,
            maxHp = 5,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        }
    },
    turtle = 
    {
        name = 'turtle',
        sprite = 'turtle',
        stats = {
            atk = 1,
            def = 4,
            maxHp = 7,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        }
    },
    seal = 
    {
        name = 'seal',
        sprite = 'seal',
        stats = {
            atk = 3,
            def = 1,
            maxHp = 4,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = { "ground", "water" },

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        }
    },
    penguin = 
    {
        name = 'penguin',
        sprite = 'penguin',
        stats = {
            atk = 2,
            def = 1,
            maxHp = 4,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = { "ground", "water" },

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        }
    },
    wolf = 
    {
        name = 'wolf',
        sprite = 'wolf',
        stats = {
            atk = 3,
            def = 1,
            maxHp = 5,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        }
    },
    camel = 
    {
        name = 'camel',
        sprite = 'camel',
        stats = {
            atk = 1,
            def = 2,
            maxHp = 6,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },

        passive = {
        }
    },
    crab = 
    {
        name = 'crab',
        sprite = 'crab',
        stats = {
            atk = 3,
            def = 3,
            maxHp = 5,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = { "ground", "water" },

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0}
        }
    },
    giraffe = 
    {
        name = 'giraffe',
        sprite = 'giraffe',
        stats = {
            atk = 3,
            def = 1,
            maxHp = 6,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        }
    },
    elephant = 
    {
        name = 'elephant',
        sprite = 'elephant',
        stats = {
            atk = 2,
            def = 2,
            maxHp = 7,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        }
    },
    crocodile = 
    {
        name = 'crocodile',
        sprite = 'crocodile',
        stats = {
            atk = 2,
            def = 2,
            maxHp = 5,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 1, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        }
    },
    lion = 
    {
        name = 'lion',
        sprite = 'lion',
        stats = {
            atk = 5,
            def = 1,
            maxHp = 4,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage + 0.1,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        }
    },
    tiger = 
    {
        name = 'tiger',
        sprite = 'tiger',
        stats = {
            atk = 5,
            def = 1,
            maxHp = 4,
            moves = DEFAULT.moves,
            crit = 0.05,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        }
    },
    owl = 
    {
        name = 'owl',
        sprite = 'owl',
        stats = {
            atk = 2,
            def = 1,
            maxHp = 3,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = { "ground", "tree" },

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {1, 1, 0, 1, 1},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        }
    },
    bee = 
    {
        name = 'bee',
        sprite = 'bee',
        stats = {
            atk = 1,
            def = 0,
            maxHp = 1,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {1, 1, 1, 1, 1},
            {1, 1, 0, 1, 1},
            {1, 1, 1, 1, 1},
            {0, 0, 0, 0, 0}
        }
    },
    butterfly = 
    {
        name = 'butterfly',
        sprite = 'butterfly',
        stats = {
            atk = 1,
            def = 0,
            maxHp = 2,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {1, 1, 1, 1, 1},
            {1, 1, 0, 1, 1},
            {1, 1, 1, 1, 1},
            {0, 0, 0, 0, 0}
        }
    },
    pig = 
    {
        name = 'pig',
        sprite = 'pig',
        stats = {
            atk = 2,
            def = 2,
            maxHp = 3,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        }
    },
    hedgehog = 
    {
        name = 'hedgehog',
        sprite = 'hedgehog',
        stats = {
            atk = 1,
            def = 2,
            maxHp = 4,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0},
            {0, 0, 0, 0, 0}
        },
        passive = {
            onTouched = function(matchState, entity, source)
                if entity.metadata.teamId ~= source.metadata.teamId then
                    matchState.combatSystem:hit(source, 1)
                end
            end
        }
    },
    ram = 
    {
        name = 'ram',
        sprite = 'ram',
        stats = {
            atk = 3,
            def = 2,
            maxHp = 5,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        }
    },
    magpie = 
    {
        name = 'magpie',
        sprite = 'magpie',
        stats = {
            atk = 3,
            def = 2,
            maxHp = 5,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = 0.1
        },
        passive = {        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {1, 1, 0, 1, 1},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        }
    },
    lizard = {
        name = 'lizard',
        sprite = 'lizard',
        stats = {
            atk = 2,
            def = 2,
            maxHp = 3,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },

        passive = {
            onStandBy = function(matchState, entity) 
                if math.random() > 0.5 then
                    matchState.combatSystem:heal(entity, 1)
                end
            end
        }
    },
    snail = {
        name = 'snail',
        sprite = 'snail',
        stats = {
            atk = 2,
            def = 4,
            maxHp = 3,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        }
    },
    zebra = 
    {
        name = 'zebra',
        sprite = 'zebra',
        stats = {
            atk = 3,
            def = 2,
            maxHp = 5,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        }
    },
    seagull = 
    {
        name = 'seagull',
        sprite = 'seagull',
        stats = {
            atk = 2,
            def = 1,
            maxHp = 6,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = { "ground", "fence" },

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {1, 1, 0, 1, 1},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        }
    },
    frog = 
    {
        name = 'frog',
        sprite = 'frog',
        stats = {
            atk = 2,
            def = 2,
            maxHp = 3,
            moves = DEFAULT.moves,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = { "ground" },

        movePattern = {
            {0, 0, 0, 1, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 1, 0, 0, 0},
            {1, 0, 1, 0, 1, 0, 1},
            {0, 0, 0, 1, 0, 0, 0},
            {0, 0, 0, 0, 0, 0, 0},
            {0, 0, 0, 1, 0, 0, 0},
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        }
    },
    dragon = 
    {
        name = 'dragon',
        sprite = 'dragon',
        stats = {
            atk = 3,
            def = 4,
            maxHp = 10,
            moves = 1,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 0, 0, 0, 0},
            {0, 1, 1, 1, 0},
            {0, 1, 0, 1, 0},
            {0, 1, 1, 1, 0},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 1, 1, 1, 0},
            {0, 1, 0, 1, 0},
            {0, 1, 1, 1, 0},
            {0, 0, 0, 0, 0}
        }
    },
    phoenix = 
    {
        name = 'phoenix',
        sprite = 'phoenix',
        stats = {
            atk = 4,
            def = 3,
            maxHp = 8,
            moves = 1,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 0, 0, 0, 0},
            {1, 1, 1, 1, 1},
            {1, 1, 0, 1, 1},
            {1, 1, 1, 1, 1},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 1, 1, 1, 0},
            {0, 1, 0, 1, 0},
            {0, 1, 1, 1, 0},
            {0, 0, 0, 0, 0}
        }
    },
    hydra =
    {
        name = 'hydra',
        sprite = 'hydra',
        stats = {
            atk = 5,
            def = 3,
            maxHp = 8,
            moves = 1,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 0, 0, 0, 0},
            {1, 1, 1, 1, 1},
            {1, 1, 0, 1, 1},
            {1, 1, 1, 1, 1},
            {0, 0, 0, 0, 0}
        },
        atkPattern = {
            {1, 0, 0, 0, 1},
            {0, 1, 1, 1, 0},
            {0, 1, 0, 1, 0},
            {0, 1, 1, 1, 0},
            {1, 0, 0, 0, 1}
        }
    },
    wyvern =
    {
        name = 'wyvern',
        sprite = 'wyvern',
        stats = {
            atk = 4,
            def = 2,
            maxHp = 8,
            moves = 1,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {0, 1, 0, 1, 0},
            {1, 0, 1, 0, 1},
            {0, 1, 0, 1, 0},
            {1, 0, 1, 0, 1},
            {0, 1, 0, 1, 0}
        },
        atkPattern = {
            {0, 0, 0, 0, 0},
            {0, 0, 1, 0, 0},
            {0, 1, 0, 1, 0},
            {0, 0, 1, 0, 0},
            {0, 0, 0, 0, 0}
        }
    },
    apple =
    {
        name = 'apple',
        sprite = 'apple',
        stats = {
            atk = 4,
            def = 2,
            maxHp = 8,
            moves = 1,
            crit = DEFAULT.crit,
            critDamage = DEFAULT.critDamage,
            lifeSteal = DEFAULT.lifeSteal,
            luck = DEFAULT.luck
        },
        stepsOn = DEFAULT.stepsOn,

        movePattern = {
            {1, 1, 1, 1, 1, 1, 1, 1, 1},
            {1, 1, 1, 1, 1, 1, 1, 1, 1},
            {1, 1, 1, 1, 1, 1, 1, 1, 1},
            {1, 1, 1, 1, 1, 1, 1, 1, 1},
            {1, 1, 1, 1, 1, 1, 1, 1, 1},
            {1, 1, 1, 1, 1, 1, 1, 1, 1},
            {1, 1, 1, 1, 1, 1, 1, 1, 1},
            {1, 1, 1, 1, 1, 1, 1, 1, 1},
            {1, 1, 1, 1, 1, 1, 1, 1, 1},
        },
        atkPattern = {
            {1, 1, 1, 1, 1, 1, 1, 1, 1},
            {1, 1, 1, 1, 1, 1, 1, 1, 1},
            {1, 1, 1, 1, 1, 1, 1, 1, 1},
            {1, 1, 1, 1, 1, 1, 1, 1, 1},
            {1, 1, 1, 1, 1, 1, 1, 1, 1},
            {1, 1, 1, 1, 1, 1, 1, 1, 1},
            {1, 1, 1, 1, 1, 1, 1, 1, 1},
            {1, 1, 1, 1, 1, 1, 1, 1, 1},
            {1, 1, 1, 1, 1, 1, 1, 1, 1},
        }
    }
}

-- for key, value in pairs(mobs) do
--     value.stats.maxHp = value.stats.maxHp * 2
-- end

return mobs

-- interesting patterns

-- {0, 0, 1, 0, 0},
-- {0, 1, 0, 1, 0},
-- {1, 0, 0, 0, 1},
-- {0, 1, 0, 1, 0},
-- {0, 0, 1, 0, 0}

-- {0, 1, 1, 1, 0},
-- {1, 0, 0, 0, 1},
-- {1, 0, 0, 0, 1},
-- {1, 0, 0, 0, 1},
-- {0, 1, 1, 1, 0}