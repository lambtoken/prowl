local effects = {

    -- MOBS

    staggering = {
        name = 'staggering',
        description = 'Auto attacks knockback enemies.',
        onAttack = function(matchState, source, target) 
            matchState.crowdControlSystem:applyCC(target, "knockback", source)
        end
    },

    toro = {
        name = 'toro',
        description = 'Passing through the enemy pushes them aside.',
        onHover = function(matchState, target, source)
            matchState.crowdControlSystem:applyCC(target, "displace", source)
        end
    },

    dont_touch_this = {
        name = 'dont_touch_this',
        description = 'Touching enemies makes them take 1 damage.',
        onTouched = function(matchState, entity, source)
            if entity.metadata.teamId ~= source.metadata.teamId then
                matchState.combatSystem:hit(source, 1)
            end
        end
    },

    shed_and_heal = {
        name = 'shed_and_heal',
        description = '50% chance to heal by 1 at the start of the turn.',
        onStandBy = function(matchState, entity) 
            if math.random() > 0.5 then
                matchState.combatSystem:heal(entity, 1)
            end
        end
    },

    heavy_paw = {
        name = 'heavy_paw',
        description = 'Attacks have 20% chance to stun.',
        onAttack = function(matchState, source, target)
            if math.random < 0.2 then
                matchState.statusEffectSystem:giveStatusEffect(target, source, 'stun', 1)
            end 
        end
    },

    frostblood = {
        name = 'frostblood',
        description = 'Attacks have 20% chance to bleed the enemy.',
        onAttack = function(matchState, source, target)
            if math.random < 0.2 then
                matchState.statusEffectSystem:giveStatusEffect(target, source, 'bleed', 1)
            end 
        end
    },

    angry_tree = {
        data = {targetId = nil},
        onHit = function(gameState, attacker, target)
            if attacker.metadata.teamId == 0 then
                target.effects.angry_tree.targetId = attacker.metadata.id
            end

        end,
        onStandBy = function(gameState, entity)
            -- if the entity is a tree, set its onHit function
            if entity.effects.angry_tree and entity.effects.angry_tree.targetId then
                gameState.aiManager:setAggroAndAttack(entity, entity.effects.angry_tree.targetId)
            end
        end
    },
}

return effects