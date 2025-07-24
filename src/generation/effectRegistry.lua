local soundManager = require("src.sound.SoundManager"):getInstance()
local ccFunctions = require("src.run.combat.crowdControlFunctions")

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
        onHover = function(matchState, source, target)
            if not target.status or not target.status.current.isDisplaceable then
                return false
            end

            local destX, destY = matchState.moveSystem:getDestination(target)

            local dx = target.position.x - source.position.lastStepX
            local dy = target.position.y - source.position.lastStepY
                        
            local ldx, ldy = dy, -dx
            local rdx, rdy = -dy, dx
            
            ldx = ldx ~= 0 and (ldx / math.abs(ldx)) or 0
            ldy = ldy ~= 0 and (ldy / math.abs(ldy)) or 0
            rdx = rdx ~= 0 and (rdx / math.abs(rdx)) or 0
            rdy = rdy ~= 0 and (rdy / math.abs(rdy)) or 0
            
            local lSteppable = matchState:isSteppable(destX + ldx, destY + ldy, target)
            local rSteppable = matchState:isSteppable(destX + rdx, destY + rdy, target)
            
            if lSteppable and rSteppable then
                if math.random() > 0.5 then
                    dx, dy = ldx, ldy
                else
                    dx, dy = rdx, rdy
                end
            elseif lSteppable and not rSteppable then
                dx, dy = ldx, ldy
            elseif not lSteppable and rSteppable then
                dx, dy = rdx, rdy
            else
                return false
            end
            
            local displaceX, displaceY = ccFunctions.checkPath(matchState, destX, destY, dx, dy, 1)
            
            if target.position.x == displaceX and target.position.y == displaceY then
                return false
            else
                soundManager:playSound("displace")
                matchState.moveSystem:move(target, 'displace', displaceX, displaceY)
                return true
            end
        end
    },

    dont_touch_this = {
        name = 'dont_touch_this',
        description = 'Touching enemies makes them take 1 damage.',
        onTouched = function(matchState, entity, source)
            if entity.team.teamId ~= source.team.teamId then
                matchState.combatSystem:hit(source, 1)
            end
        end
    },

    shed_and_heal = {
        name = 'shed_and_heal',
        description = '50% chance to heal by 1 at the start of the turn.',
        onStandBy = function(matchState, entity) 
            if math.random() > 0.25 then
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

    -- TRAITS

    angry_tree = {
        data = {targetId = nil},
        onHit = function(gameState, attacker, target)
            if attacker.team.teamId == 0 then
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

    -- OBJECTS

    green_apple = {
        name = "green_apple",
        onStepped = function(matchState, entity, object)
            matchState.combatSystem:heal(entity, 1)
            matchState.stateSystem:changeState(object, "dead")
            soundManager:playSound("bite")
        end
    },

    red_apple = {
        name = "red_apple",
        onStepped = function(matchState, entity, object)
            matchState.combatSystem:heal(entity, 2)
            matchState.stateSystem:changeState(object, "dead")
            soundManager:playSound("bite")
        end
    },

    golden_apple = {
        name = "golden_apple",
        onStepped = function(matchState, entity, object)
            matchState.combatSystem:heal(entity, 3)
            matchState.stateSystem:changeState(object, "dead")
            soundManager:playSound("bite")
        end
    },

    trample = {
        onHovered = function(matchState, object, entity)
            matchState.animationSystem:playAnimation(object, "hit")
            matchState.stateSystem:changeState(object, "dying")
            matchState.animationSystem:playAnimation(object, "death")
            soundManager:playSound("breaking")
        end
    },

    paw_catcher = {
        onStepped = function(matchState, entity, object)
            matchState.combatSystem:hit(entity, 2)
            soundManager:playSound("bear_trap")
            matchState.stateSystem:changeState(object, "dead")
        end
    },

    tiny_snare = {
        onStepped = function(matchState, entity, object)
            matchState.combatSystem:hit(entity, 1)
            matchState.animationSystem:playAnimation(object, "trigger_death")
            soundManager:playSound("mouse_trap")
        end
    },

    frostfang = {
        onStepped = function(matchState, entity, object)
            matchState.combatSystem:hit(entity, 1)
        end
    },

    tumble = {
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
            if entity.state.alive then
                matchState.combatSystem:hit(entity, 1)
            end
        end
    },

    dont_touch_me = {
        onTouched = function(matchState, object, entity)
            if entity.state.alive then
                matchState.combatSystem:hit(entity, 1)
            end
        end
    },

    impale = {
        onStepped = function(matchState, entity, object)
            matchState.combatSystem:hit(entity, 1)
        end
    },

    boom = {
        onAttacked = function(matchState, object, entity)
            matchState.eventManager:emit("registerTimer", object, 1, "explosion", {entity = object, amount = 3})
            soundManager:playSound("hiss")
        end
    },

    get_lucky = {
        onStepped = function(matchState, entity, object)
            matchState.buffDebuffSystem:applyEffect(entity, "lucky_clover", object)
            matchState.stateSystem:changeState(object, "dead")
            matchState.statsSystem:calculateStats()
        end
    },

    jitter = {
        onStepped = function(matchState, entity, object)
            matchState.buffDebuffSystem:applyEffect(entity, "coffee", object)
            matchState.stateSystem:changeState(object, "dead")
            matchState.statsSystem:calculateStats()
        end
    },

    beach_bounce = {
        onAttacked = function(matchState, object, entity)
            local knockback = matchState.crowdControlSystem:applyCC(object, "knockback", entity)
            if knockback then 
                matchState.animationSystem:playAnimation(object, "tumble")
                return true
            end
            return false
        end,
        onStep = function(matchState, object)
            if object.state.alive then
                local targets = matchState.moveSystem:getTouching(object.position.x, object.position.y, "animal")
                for index, target in ipairs(targets) do
                    matchState.combatSystem:hit(target, 1)
                end
            end
        end
    },

    poisonous_on_touch = {
        description = "Enemies touching this entity get poisoned for 1-2 turns.",
        onTouched = function(matchState, frog, entity)
            if frog.team and entity.team and frog.team.teamId == entity.team.teamId then
                return false
            end
            
            if entity.state.alive then
                matchState.damageOverTimeSystem:giveDotEffect(entity, frog, "poison", math.random(1, 2), true)
            end
        end
    },

    -- banananana = {
    --     onStep = function(matchState, source)
    --         local nearbyEnemy = matchState.moveSystem:getNearestEntity(source, 'animal', source.team.teamId)

    --         if nearbyEnemy then
    --             local offsets = {
    --                 {1, 0}, {-1, 0}, {0, 1}, {0, -1}
    --             }

    --             local freeTiles = {}

    --             for _, offset in ipairs(offsets) do
    --                 local ox, oy = offset[1], offset[2]
    --                 local tx = nearbyEnemy.position.x + ox
    --                 local ty = nearbyEnemy.position.y + oy

    --                 local occupied = matchState.moveSystem:findByCoordinates(tx, ty)
    --                 if #occupied == 0 then
    --                     table.insert(freeTiles, { tx, ty })
    --                 end
    --             end

    --             if #freeTiles > 0 then
    --                 local targetTile = freeTiles[math.random(#freeTiles)]
    --                 local tx, ty = targetTile[1], targetTile[2]

    --                 soundManager:playSound("arrow")
    --                 matchState:newProjectile('banana',
    --                     source.position.x, source.position.y,
    --                     tx, ty,
    --                     source.metadata.id
    --                 )
    --             end
    --         end
    --     end
    -- }

    -- this is just for now until we rework the projectile system

    banananana = {
        description = "Moving has 20% chance to throw a banana at a random enemy.",
        onStep = function(matchState, source)
            if math.random() < 0.2 then
                local nearestEntity = matchState.moveSystem:getNearestEntity(source, 'animal', source.team.teamId)
                if nearestEntity then
                    soundManager:playSound("arrow")
                    matchState:newProjectile('banana', source.position.x, source.position.y, nearestEntity.position.x, nearestEntity.position.y, source.metadata.id)
                end
            end
        end
    }
}

return effects