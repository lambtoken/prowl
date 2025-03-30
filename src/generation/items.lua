local RM = require ('src.render.RenderManager'):getInstance()
-- rarities: common, uncommon, rare, epic, legendary

--                     ▓▓▓▓▓▓      
--               ▓▓▓▓▓▓▓▓  ▓▓▓▓▒▒  
--             ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▒▒▒▒▒▒
--         ▓▓▓▓▓▓▓▓▓▓▒▒▓▓▓▓▓▓▒▒▒▒▒▒
--       ▓▓▓▓▓▓▓▓▓▓▒▒▓▓▓▓▓▓        
--   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓          
-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓            
-- ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓            
--           ▓▓  ██                
--           ▒▒  ██                
--           ▒▒▒▒████              

local items = {
    stick = {
        name = 'stick',
        type = 'weapon',
        rarity = 'common',
        stats = {{'increase', 'atk', 1}},
        movPattern = {},
        atkPattern = {},
        passive = {},
        active = {},
    },
    knife = {
        name = 'knife',
        type = 'weapon',
        rarity = 'common',
        stats = {
            {'increase', 'atk', 1},
        },
        movePattern = {},
        pattern = {
            {'add', 'atkPattern', {
                {0, 1, 0},
                {1, 0, 1},
                {0, 1, 0}
            }}
        },
        passive = {},
        active = {},
    },
    cleaver = {
        name = 'cleaver',
        type = 'weapon',
        rarity = 'rare',
        stats = {{'increase', 'atk', 3}},
        pattern = {},
        passive = {},
        active = {},
    },
    whip = {
        name = 'whip',
        type = 'weapon',
        rarity = 'uncommon',
        stats = {
            {'increase', 'atk', 1},
        },
        pattern = {
            {'extend', 'atkPattern', {
                {1, 1, 1},
                {1, 0, 1},
                {1, 1, 1}
            }},
            {'remove', 'atkPattern', {
                {1, 1, 1},
                {1, 0, 1},
                {1, 1, 1}
            }}
        },
        passive = {},
        active = {},
    },
    hardhat = {
        name = 'hardhat',
        type = 'protection',
        rarity = 'uncommon',
        stats = {{'increase', 'def', 2}},
        pattern = {},
        passive = {},
        active = {},
    },
    dart = {
        name = 'dart',
        type = 'weapon',
        rarity = 'common',
        stats = {
            {'increase', 'atk', 1},
        },
        pattern = {
            {'add', 'atkPattern', {
                {0, 0, 0, 1, 0, 0, 0},
                {0, 0, 0, 0, 0, 0, 0},
                {0, 0, 0, 0, 0, 0, 0},
                {1, 0, 0, 0, 0, 0, 1},
                {0, 0, 0, 0, 0, 0, 0},
                {0, 0, 0, 0, 0, 0, 0},
                {0, 0, 0, 1, 0, 0, 0}
            }}
        },
        passive = {},
        -- chould have active projectile
        active = {},
    },
    lucky_clover = {
        name = 'lucky clover',
        type = 'misc',
        rarity = 'rare',
        stats = {{'increase', 'luck', 0.1}},
        pattern = {},
        passive = {},
        active = {},
    },
    saddle = {
        name = 'saddle', --horse techno!!!
        type = 'protection',
        rarity = 'epic',
        stats = {},
        pattern = {
            {'add', 'movePattern', {
                {0, 1, 0, 1, 0},
                {1, 0, 0, 0, 1},
                {0, 0, 0, 0, 0},
                {1, 0, 0, 0, 1},
                {0, 1, 0, 1, 0}
            }}
        },
        passive = {},
        active = {},
    },
    -- ethereal_blade = {
    --     name = 'ethereal blade',
    --     type = 'weapon',
    --     rarity = 'legendary',
    --     stats = {
    --         {'decreaseP', 'maxHp', 50},
    --     },
    --     pattern = {
    --         {'add', 'atkPattern', {
    --             {0, 0, 1, 0, 0},
    --             {0, 0, 1, 0, 0},
    --             {1, 1, 0, 1, 1},
    --             {0, 0, 1, 0, 0},
    --             {0, 0, 1, 0, 0}
    --         }}
    --     },
    --     passive = {},
    --     active = {},
    -- },
    poison_dart = {
        name = 'poison dart',
        type = 'weapon',
        rarity = 'rare',
        stats = {
            {'increase', 'atk', 1},
            -- {'onHit', 'poison', 1, 20}
        },
        pattern = {},
        passive = {},
        active = {},
    },
    mace = {
        name = 'mace',
        type = 'weapon',
        rarity = 'rare',
        stats = {
            {'increase', 'atk', 1}
        },
        pattern = {},
        passive = {
            description = "Attacking displaces targets.",
            onAttack = function(matchState, entity, target)
                matchState.crowdControlSystem:applyCC(target, 'displace', entity)
            end
        },
        active = {},
    },
    saw = {
        name = 'saw',
        type = 'weapon',
        rarity = 'rare',
        stats = {
            {'increase', 'crit', 0.2}
        },
        pattern = {},
        passive = {},
        active = {},
    },
    -- matches = {
    --     name = 'matches',
    --     type = 'weapon',
    --     rarity = 'rare',
    --     stats = {
    --         {'increaseEffect', 'burnDamage', 5}
    --     },
    --     pattern = {},
    --     passive = {},
    --     active = {},
    -- },
    -- mushroom = {
    --     name = 'mushroom',
    --     type = 'misc',
    --     rarity = 'rare',
    --     stats = {
    --         {'increaseEffect', 'poisonDamage', 5}
    --     },
    --     pattern = {},
    --     passive = {},
    --     active = {},
    -- },
    -- torch = {
    --     name = 'torch',
    --     type = 'weapon',
    --     rarity = 'uncommon',
    --     stats = {
    --         {'onHit', 'burn', 1, 30}
    --     },
    --     pattern = {},
    --     passive = {},
    --     active = {},
    -- },
    scarf = {
        name = 'scarf',
        type = 'protection',
        rarity = 'common',
        stats = {
            {'increase', 'def', 2},
            {'increase', 'maxHp', 1}
        },
        pattern = {},
        passive = {},
        active = {},
    },
    umbrella = {
        name = 'umbrella',
        type = 'weapon',
        rarity = 'uncommon',
        stats = {
            {'increase', 'atk', 1},
            {'increase', 'def', 2}
        },
        pattern = {},
        passive = {},
        active = {},
    },
    flip_flops = {
        name = 'flip flops',
        type = 'weapon',
        rarity = 'uncommon',
        stats = {
            
        },
        pattern = {
            {'add', 'movePattern', {
                {0, 0, 0},
                {0, 1, 0},
                {0, 0, 0}
            }} 
        },
        passive = {},
        active = {},
    },
    garden_scissors = {
        name = 'garden scissors',
        type = 'weapon',
        rarity = 'rare',
        stats = {
            {'increase', 'atk', 2}, 
        },
        pattern = {
            {'extend', 'atkPattern', {
                {1, 0, 1},
                {0, 0, 0},
                {1, 0, 1}
            }},
            -- {'remove', 'atkPattern', {
            --     {0, 1, 0},
            --     {0, 1, 0},
            --     {0, 1, 0}
            -- }} 
        },
        passive = {},
        active = {},
    },
    portal_gun = {
        name = 'portal gun',
        type = 'weapon',
        rarity = 'epic',
        stats = {
            {'increase', 'atk', 1},        
        },
        pattern = {},
        passive = {},
        active = {
            {
                type = "pointAndClick", -- other types: self
                target = "terrain", -- other types: all, animals, objects,..
                effect = function(matchState, entity, tile)
                    matchState.moveSystem:move(entity, "teleport", tile.x, tile.y)
                end,
                cooldown = 5
            }
        },
    },
    laser_pointer = {
        name = 'laser pointer',
        type = 'weapon',
        rarity = 'rare',
        stats = {},
        pattern = {
            {'extend', 'atkPattern', {
                {0, 1, 0},
                {1, 0, 1},
                {0, 1, 0},
            }},
            {'remove', 'atkPattern', {
                {1, 0, 1},
                {0, 0, 0},
                {1, 0, 1},
            }}
        },
        passive = {},
        active = {},
    },
    mixer = {
        name = 'mixer',
        type = 'weapon',
        rarity = 'rare',
        stats = {
            {'swap', 'movePattern', 'atkPattern'}   
        },
        pattern = {},
        passive = {},
        active = {},
    },
    pirate_hook = {
        name = 'pirate hook',
        type = 'weapon',
        rarity = 'common',
        stats = {
            {'increase', 'crit', 0.1},
        },
        pattern = {},
        passive = {},
        active = {},
    },
    sledgehammer = {
        name = 'sledgehammer',
        type = 'weapon',
        rarity = 'rare',
        stats = {
            {'increase', 'atk', 3},
            {'swap', 'atk', 'maxHp'},      
        },
        pattern = {
        },
        passive = {},
        active = {},
    },
    damascus_knife = {
        name = 'damascus knife',
        type = 'weapon',
        rarity = 'common',
        stats = {
            {'increase', 'atk', 1},
        },
        pattern = {
            {'add', 'atkPattern', {
                {1, 0, 1},
                {0, 0, 0},
                {1, 0, 1}
            }}
        },
        passive = {},
        active = {},
    },
    queens_crown = {
        name = 'queen\' s crown',
        type = 'protection',
        rarity = 'legendary',
        stats = {},
        pattern = {
            {'add', 'movePattern', {
            }}
        },
        passive = {},
        active = {},
    },
    scope = {
        name = 'scope',
        type = 'weapon',
        rarity = 'epic',
        stats = {},
        pattern = {
            {'extend', 'atkPattern', {
                {0, 1, 0},
                {1, 0, 1},
                {0, 1, 0}
            }}
        },
        passive = {},
        active = {},
    },
    trident = {
        name = 'trident',
        type = 'weapon',
        rarity = 'epic',
        stats = {{'increase', 'atk', 1},},
        pattern = {
            {'extend', 'atkPattern', {
                {1, 1, 1},
                {0, 0, 0},
                {0, 1, 0}
            }}
        },
        passive = {
            desc = "Deal bonus 1 dmg in water."
        },
        active = {},
    },
    knuckle_duster = {
        name = 'knuckle duster',
        type = 'weapon',
        rarity = 'common',
        stats = {},
        pattern = {},
        passive = {
            description = "Moving over enemies causes them to take 1 damage.",
            onHover = function(matchState, target, source)
                matchState.combatSystem:dealDamage(target, 1)
            end
        },
        active = {},
    },
    baseball_bat = {
        name = 'baseball bat',
        type = 'weapon',
        rarity = 'common',
        stats = {
            {'increase', 'atk', '1'}
        },
        pattern = {},
        passive = {
            description = "Attacks knockback enemies.",
            onAttack = function(matchState, source, target) 
                matchState.crowdControlSystem:applyCC(target, "knockback", source)
            end
        },
        active = {},
    },
    revolver = {
        name = 'revolver',
        type = 'weapon',
        rarity = 'common',
        stats = {{'increase', 'atk', 2}},
        pattern = {},
        passive = {
            description = "Careful, recoil..",
            onAttack = function(matchState, source, target)
                if target.metadata.type == 'animal' then
                    matchState.crowdControlSystem:applyCC(source, "knockback", target)
                end
            end
        },
        active = {},
    },
    first_aid = {
        name = 'first aid',
        type = 'weapon',
        rarity = 'common',
        stats = {{'increase', 'lifeSteal', 0.1}},
        pattern = {},
        passive = {},
        active = {},
    },
    stappler = {
        name = 'stappler',
        type = 'weapon',
        rarity = 'common',
        stats = {},
        patern = {},
        passive = {
            onAttack = function(matchState, source, target)
                if target.metadata.type == 'animal' then
                    matchState.statusEffectSystem:giveStatusEffect(target, source, 'stun', 3)
                end
            end,
            cooldown = 2
        }
    },
}

local crownWidth = RM.renderDistanceX + 1

for j = 1, crownWidth do
    items.queens_crown.pattern[1][3][j] = {}
    for i = 1, crownWidth do
        if i == j or crownWidth - i == j - 1 or i == math.ceil(crownWidth / 2) or j == math.ceil(crownWidth / 2) then
            items.queens_crown.pattern[1][3][j][i] = 1
        else
            items.queens_crown.pattern[1][3][j][i] = 0
        end
    end
end

-- for j = 1, RM.renderDistanceX do
--     items.scope.stats[1][2][j] = {}
--     for i = 1, RM.renderDistanceX do
--         if i == math.ceil(RM.renderDistanceX / 2) or j == math.ceil(RM.renderDistanceX / 2) then
--             items.scope.stats[1][2][j][i] = 1
--         else
--             items.scope.stats[1][2][j][i] = 0
--         end
--     end
-- end


return items

