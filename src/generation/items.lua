local RM = require ('src.render.RenderManager'):getInstance()
local SoundManager = require('src.sound.SoundManager'):getInstance()

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
        stats = {{'increase', 'atk', 2}},
        passive = {},
        active = {},
    },
    knife = {
        name = 'knife',
        type = 'weapon',
        rarity = 'common',
        stats = {
            {'increase', 'atk', 2},
        },
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
        stats = {{'increase', 'maxHp', 1}},
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
        },
        cooldowns = {
            onAttack = 3
        },
        startCooldowns = {
            onAttack = 0
        },
        pattern = {},
        passive = {
            description = "Attacks have 20% chance to apply poison damage for 3 turns.",
            onAttack = function(matchState, entity, target)
                if math.random() < 0.2 then
                    matchState.damageOverTimeSystem:giveDotEffect(target, entity, "poison", 3)
                end
            end
        },
        active = {},
    },
    mace = {
        name = 'mace',
        type = 'weapon',
        rarity = 'rare',
        stats = {
            {'increase', 'atk', 2}
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
            {'increase', 'atk', 1},
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
            {'increase', 'maxHp', 2}
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
        rarity = 'rare',
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
        stats = {
            {'increase', 'atk', 1},
        },
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
        stats = {},
        pattern = {
            {'swap', 'movePattern', 'atkPattern'}   
        },
        passive = {},
        active = {},
    },
    pirate_hook = {
        name = 'pirate hook',
        type = 'weapon',
        rarity = 'common',
        stats = {
            {'increase', 'atk', 1},
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
    -- queens_crown = {
    --     name = 'queen\' s crown',
    --     type = 'protection',
    --     rarity = 'legendary',
    --     stats = {},
    --     pattern = {
    --         {'add', 'movePattern', {
    --         }}
    --     },
    --     passive = {},
    --     active = {},
    -- },
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
        stats = {{'increase', 'atk', 2}},
        pattern = {
            {'extend', 'atkPattern', {
                {1, 1, 1},
                {0, 0, 0},
                {0, 0, 0}
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
        stats = {{'increase', 'atk', 1}},
        pattern = {},
        passive = {
            description = "Moving over enemies causes them to take 1 damage.",
            onHover = function(matchState, target, source)
                matchState.combatSystem:hit(target, 1)
            end
        },
        active = {},
    },
    baseball_bat = {
        name = 'baseball bat',
        type = 'weapon',
        rarity = 'common',
        stats = {
            {'increase', 'atk', '2'}
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
        cooldowns = {
            onAttack = 3,
        },
        startCooldowns = {
            onAttack = 0
        },
        stats = {},
        patern = {},
        passive = {
            description = "Attacks have 20% chance to stun.",
            onAttack = function(matchState, source, target)
                if target.metadata.type == 'animal' and math.random() > 0.8 then
                    matchState.statusEffectSystem:giveStatusEffect(target, source, 'stun', 2)
                end
            end,
        }
    },
    crossbow = {
        name = 'crossbow',
        type = 'weapon',
        rarity = 'common',
        stats = {{'increase', 'atk', 1}},
        pattern = {},
        passive = {
            onStep = function(matchState, source)
                local nearestEntity = matchState.moveSystem:getNearestEntity(source, 'animal', source.metadata.teamId)
                if nearestEntity then
                    SoundManager:playSound("arrow")
                    matchState:newProjectile('arrow', source.position.x, source.position.y, nearestEntity.position.x, nearestEntity.position.y, source.metadata.id)
                end
            end
        },
        active = {},
    },
    boxing_gloves = {
        name = 'boxing gloves',
        type = 'weapon',
        rarity = 'common',
        stats = {
            {'increase', 'critDamage', 0.25},
            {'increase', 'crit', 0.1},
        },
        pattern = {},
        passive = {
            description = "Critical strikes taunt. Taunted enemy attacks for a small percent of it's ATK.",
            onCrit = function(matchState, attacker, target)
                matchState.combatSystem:taunt(attacker, target, 0.1)
            end
        },
        active = {},
    },
    spike_collar = {
        name = 'spike collar',
        type = 'weapon',
        rarity = 'common',
        stats = {
            {'increase', 'def', 2},
            {'increase', 'maxHp', 2}
        },
        pattern = {},
        passive = {
            description = "When attacked, deal 1 dmg back.",
            onAttacked = function(matchState, target, attacker)
                matchState.combatSystem:hit(attacker, 1)
            end
        },
        active = {},
    },
    -- fan = {
    --     name = 'fan',
    --     type = 'misc',
    --     rarity = 'epic',
    --     stats = {},
    --     pattern = {},
    --     data = {
    --         buffLevel = 0,
    --         maxLevel = 5,
    --     },
    --     cooldowns = {
    --         onStandBy = 3,
    --     },
    --     passive = {
    --         description = "Grants increasing attack each turn.",
            
    --         onStandBy = function(matchState, entity, item)
                
    --             local itemId = item.itemId
                
    --             if item.data.buffLevel < item.data.maxLevel then
    --                 item.data.buffLevel = item.data.buffLevel + 1
    --             end
                
    --             local stats = {{'increase', 'atk', item.data.buffLevel}}
                
    --             local effect = matchState.buffDebuffSystem:updateItemEffect(entity, itemId, stats, 3)
    --         end
    --     },
    --     active = {},
    -- },
    cactus_pot = {
        name = "cactus pot",
        type = "misc",
        rarity = "common",
        stats = {
            {"increase", "maxHp", 1}
        },
        pattern = {},
        passive = {
            description = "Touching enemies deals 1 damage.",
            onTouched = function(matchState, entity, source)
                if entity.metadata.teamId ~= source.metadata.teamId then
                    matchState.combatSystem:hit(source, 1)
                end
            end
            
        },
        active = {},
    },
    rusty_knife = {
        name = "rusty knife",
        type = "weapon",
        rarity = "common",
        stats = {
            {"increase", "atk", 1}
        },
        pattern = {},
        passive = {
            description = "Attaking has a 20% chance to poison the enemy.",
            onAttack = function(matchState, entity, target)
                if entity.metadata.teamId ~= target.metadata.teamId then
                    if math.random() < 0.2 then
                        matchState.damageOverTimeSystem:giveDotEffect(target, entity, "poison", 2)
                    end
                end
            end
        },
        active = {},
    },
    razor = {
        name = "razor",
        type = "weapon",
        rarity = "common",
        stats = {
            {"increase", "atk", 1}
        },
        pattern = {},
        passive = {
            description = "Attaking has a 20% chance to bleed the enemy.",
            onAttack = function(matchState, entity, target)
                if entity.metadata.teamId ~= target.metadata.teamId then
                    if math.random() < 0.2 then
                        matchState.damageOverTimeSystem:giveDotEffect(target, entity, "bleed", 2)
                    end
                end
            end
        },
        active = {},
    },
    racing_flag = {
        name = "racing flag",
        type = "misc",
        rarity = "rare",
        stats = {},
        pattern = {
            { 'add', 'movePattern', {
                { 0, 0, 0, 0, 1, 0, 0, 0, 0 },
                { 0, 0, 0, 0, 1, 0, 0, 0, 0 },
                { 0, 0, 0, 0, 1, 0, 0, 0, 0 },
                { 0, 0, 0, 0, 1, 0, 0, 0, 0 },
                { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
                { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
                { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
                { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
                { 0, 0, 0, 0, 0, 0, 0, 0, 0 }
            }}
        },
        passive = {
            description = "Move pattern for chargin deep into the enemy territory.",
        },
        active = {},
    },
    bulletproof_vest = {
        name = "bulletproof vest",
        type = "armor",
        rarity = "common",
        stats = {
            {"increase", "def", 4}
        },
        pattern = {},
        passive = {},
        active = {},
    },
    gear = {
        name = "gear",
        type = "misc",
        rarity = "common",
        stats = {},
        data = {
            turn = 0
        },
        cooldowns = {
            onStandBy = 0
        },
        pattern = {},
        passive = {
            description = "Gain +1 atk and -1 def or +1 def and - 1 atk alternating every turn.",
            onStandBy = function(matchState, entity, item)
                local even = {{"increase", "atk", 1}, {"decrease", "def", 1}}
                local odd = {{"increase", "def", 1}, {"decrease", "atk", 1}}

                local itemId = item.itemId

                if item.data.turn % 2 == 0 then
                    matchState.buffDebuffSystem:updateItemEffect(entity, itemId, even, 1)
                else
                    matchState.buffDebuffSystem:updateItemEffect(entity, itemId, odd, 1)
                end

                item.data.turn = item.data.turn + 1
            end
        },
        active = {},
    },
    cane = {
        name = "cane",
        type = "weapon",
        rarity = "common",
        stats = {},
        data = {
            moved = false
        },
        cooldowns = {
            onStandBy = 0
        },
        pattern = {},
        passive = {
            description = "Moving by 1 tile increases atk by 3 until the end of the turn.",
            onStandBy = function(matchState, entity, item)
                item.data.moved = false
            end,
            onStep = function(matchState, entity, item)
                local distance = math.sqrt((entity.position.lastStepX - entity.position.x) ^ 2 + (entity.position.lastStepY - entity.position.y) ^ 2)
            
                if not item then
                    return
                end

                local itemId = item.id

                if distance <= 1 then
                    matchState.buffDebuffSystem:updateItemEffect(entity, itemId, {{"increase", "atk", 3}}, 1)
                else
                    matchState.buffDebuffSystem:removeItemEffect(entity, itemId)
                end
            end
        },
        active = {},
    },
    katana = {
        name = "katana",
        type = "weapon",
        rarity = "rare",
        stats = {},
        data = {
            moved = false
        },
        cooldowns = {
            onMove = 2,
            onStandBy = 1
        },
        startCooldowns = {
            onMove = 0
        },
        pattern = {},
        passive = {
            description = "Moving away from enemies damages them for 1. Become disarmed after that until the end of the next turn.",
            onStandBy = function(matchState, entity, item)
                item.data.moved = false
            end,
            onMove = function(matchState, entity, item)
                if item.data.moved then
                    return
                end

                local success = false
                local targets = matchState.moveSystem:getTouching(entity.position.x, entity.position.y, "animal")

                for index, target in ipairs(targets) do
                    if target ~= entity and target.metadata.teamId ~= entity.metadata.teamId then
                        matchState.combatSystem:hit(target, 2)
                        success = true
                    end
                end

                if success then
                    matchState.statusEffectSystem:giveStatusEffect(entity, entity, "disarm", 1)
                    matchState.statusEffectSystem:applyAllStatusEffects()
                    item.data.moved = true
                end
            end
        },
        active = {},
    },
    swiss_knife = {
        name = 'swiss knife',
        type = 'protection',
        rarity = 'rare',
        stats = {
            {'increase', 'atk', 1},
            {'increase', 'def', 1},
            {'increase', 'crit', 0.1},
            {'increase', 'maxHp', 1}
        },
        pattern = {},
        passive = {},
        active = {},
    },
    kite = {
        name = 'kite',
        type = 'weapon',
        rarity = 'common',
        stats = {},
        pattern = {
            {'extend', 'atkPattern', {
                {0, 0, 0},
                {1, 0, 1},
                {0, 0, 0},
            }},
            {'remove', 'atkPattern', {
                {1, 1, 1},
                {0, 0, 0},
                {1, 1, 1},
            }}
        },
        passive = {},
        active = {},
    },
    water_gun = {
        name = 'water_gun',
        type = 'weapon',
        rarity = 'common',
        stats = {
            {'increase', 'atk', 2},
            {'decrease', 'def', 2},
        },
        pattern = {
            {'add', 'movePattern', {
                {1, 0, 0, 0, 1},
                {0, 1, 0, 1, 0},
                {0, 0, 0, 0, 0},
                {0, 1, 0, 1, 0},
                {1, 0, 0, 0, 1},
            }},
            {'remove', 'atkPattern', {
                {0, 1, 1, 1, 0},
                {1, 0, 0, 0, 1},
                {1, 0, 0, 0, 1},
                {1, 0, 0, 0, 1},
                {0, 1, 1, 1, 0},
            }}
        },
        passive = {},
        active = {},
    },
    tire = {
        name = 'tire',
        type = 'protection',
        rarity = 'common',
        stats = {{'increase', 'maxHp', 3}},
        pattern = {},
        passive = {},
        active = {},
    },
    log = {
        name = 'log',
        type = 'protection',
        rarity = 'common',
        stats = {
            {'increase', 'maxHp', 4},
            {'decrease', 'atk', 1},
        },
        pattern = {},
        passive = {},
        active = {},
    },
}

local crownWidth = RM.renderDistanceX + 1

-- for j = 1, crownWidth do
--     items.queens_crown.pattern[1][3][j] = {}
--     for i = 1, crownWidth do
--         if i == j or crownWidth - i == j - 1 or i == math.ceil(crownWidth / 2) or j == math.ceil(crownWidth / 2) then
--             items.queens_crown.pattern[1][3][j][i] = 1
--         else
--             items.queens_crown.pattern[1][3][j][i] = 0
--         end
--     end
-- end

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