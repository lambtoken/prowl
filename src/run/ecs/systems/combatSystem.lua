local Concord = require("libs.concord")
local gs = require('src.state.GameState'):getInstance()
local sceneManager = require('src.scene.SceneManager'):getInstance()
local soundManager = require('src.sound.SoundManager'):getInstance()
local EventManager = require('src.state.events'):getInstance()
local pretty       = require('libs.batteries.pretty')
local mobData = require "src.generation.mobs"
local itemData = require "src.generation.items"
local objectData = require "src.generation.objects"
local SoundManager = require("src.sound.SoundManager"):getInstance()
local on = require "src.run.ecs.on"

local combatSystem = Concord.system({pool = {"position"}})

-- helper function for calculating miss chance based on def value
local function defMissChance(attacker, target)
    local atk = attacker.stats.current.atk
    local def = target.stats.current.def

    if atk >= def then
        return 0
    end

    local diff = def - atk
    local max_miss = 0.9  -- upper limit
    local scale = 0.1     -- growth rate (smaller = slower growth)

    return max_miss * (1 - math.exp(-scale * diff))
end

function combatSystem:init()
    -- EVENTS
    -- EventManager:on("onStep", function() 
    --     on("onStep", matchState, entity)
    -- end)
    EventManager:on("onStep", function(entity, attack)
        local matchState = gs.match

        EventManager:emit("onStepAny", entity)

        -- print(entity.metadata.species)

        on("onStep", matchState, entity)
        
        if not attack then
            return
        end

        local entitiesToHit = self:insideAttackPattern(entity)
        
        if #entitiesToHit > 0 then

            local missed = false
            local succesfulAttack = false
            local succesfulAttackPassive = false
            local targetsKilled = {}            

            for _, target in ipairs(entitiesToHit) do
                missed = false
            
                local isEnemy = entity.metadata.teamId ~= target.metadata.teamId
                local isTargetable = target.status and target.status.current.isTargetable
                local isAlive = not (target.state and not target.state.alive)
            
                if isEnemy and isTargetable and isAlive then
                    if target.stats then
                        local missChance = gs.match.rng:get('combat')
                        local luckDiff = target.stats.current.luck - entity.stats.current.luck
            
                        if luckDiff > missChance then
                            missed = true
                            EventManager:emit("onMiss", entity, target)
                            EventManager:emit("onDodge", target, entity)
                        end

                        local m = defMissChance(entity, target)

                        print("def miss ", m)

                        missed = missed or math.random() <= m
            
                        if not missed then
                            succesfulAttack = true
                            if self:attack(entity, target) then
                                table.insert(targetsKilled, target)
                            end
                        else
                            SoundManager:playSound("miss")
                            EventManager:emit("shortCCBubble", target, "Missed")
                        end
                    else
                        succesfulAttackPassive = true
                    end
            
                    succesfulAttackPassive = EventManager:emit("onAttack", entity, target)
                    EventManager:emit("onAttacked", target, entity)
                end
            end

            if succesfulAttack or succesfulAttackPassive or missed then
                EventManager:emit("playAnimation", entity, "attack")
            end

            if #targetsKilled > 0 then
                for index, target in ipairs(targetsKilled) do
                    EventManager:emit("setState", target, "dying") 
                end
            end

        end
    end)

    EventManager:on("onStepAny", function(entity)
        local matchState = sceneManager.currentScene.match
        on("onStepAny", matchState, entity )
    end)

    EventManager:on("onHover", function(entity) 
        local matchState = sceneManager.currentScene.match

        local targets = matchState.moveSystem:findByCoordinates(entity.position.x, entity.position.y)
        
        EventManager:emit("onHoverAny", entity)
        
        if entity.metadata.type == 'animal' then
            for _, target in ipairs(targets) do
                if target == entity or not target.state.alive then 
                    goto continue  -- Skip this target instead of returning
                end
                    
                local mob = mobData[entity.metadata.species]
                
                if mob.passive and mob.passive.onHover then
                    mob.passive.onHover(matchState, target, entity)
                end

                for _, item in ipairs(entity.inventory.items) do
                    if item.passive and item.passive.onHover then
                        item.passive.onHover(matchState, target, entity)
                    end
                end
                
                ::continue::
            end
        end

        if entity.metadata.type == 'object' then
            local object = objectData[entity.metadata.objectName]
            if object.passive and object.passive.onHover then
                object.passive.onHover(matchState, entity)
            end
        end
    end)


    EventManager:on("onHovered", function(entity, x, y) 
        local matchState = sceneManager.currentScene.match

        local targets = matchState.moveSystem:findByCoordinates(x, y)
        
        for _, target in ipairs(targets) do
            EventManager:emit("onHoveredAny", target)

            if target.metadata.type == 'object' then
                if target == entity or not target.state.alive then
                    goto continue
                end
                local object = objectData[target.metadata.objectName]
                if object.passive and object.passive.onHovered then
                    object.passive.onHovered(matchState, target, entity)
                end                
            end

            if target.metadata.type == 'animal' then
                if target == entity and not target.state.alive then
                    goto continue
                end
                
                local animal = mobData[target.metadata.species]
                if animal.passive and animal.passive.onHovered then
                    animal.passive.onHovered(matchState, target, entity)
                end

                for _, item in ipairs(target.inventory.items) do
                    if item.passive and item.passive.onHovered then
                        item.passive.onHovered(matchState, target, entity)
                    end
                end
            end

            ::continue::
        end
    end)

    EventManager:on("onHoveredAny", function(entity)
        on("onHoveredAny", gs.match, entity)
    end)

    EventManager:on("onHoverAny", function(entity)
        on("onHoverAny", gs.match, entity)
    end)

    EventManager:on("onMiss", function(entity, target)
        on("onMiss", gs.match, entity, target)
    end)

    EventManager:on("onDodge", function(entity, target)
        on("onDodge", gs.match, entity, target)
    end)

    EventManager:on("onKill", function(entity)
        on("onKill", gs.match, entity)
        on("onKillAny", gs.match, entity)
    end)

    EventManager:on("onCrit", function(entity, target)
        on("onCrit", gs.match, entity, target)
    end)

    EventManager:on("onCrited", function(entity, attacker)
        on("onCrited", gs.match, entity, attacker)
    end)

    EventManager:on("onAttack", function(entity, target)
        on("onAttack", gs.match, entity, target)
    end)

    EventManager:on("onAttacked", function(target, entity)
        on("onAttacked", gs.match, target, entity)
    end)


end


function combatSystem:attack(entity1, entity2)
    if not entity1.status.canAttack then
        return false
    end

    local damage = entity1.stats.current.atk
    local crit = false

    --crit
    if entity1.stats.current.crit >= gs.match.rng:get('combat') then
        damage = damage * entity1.stats.current.critDamage
        EventManager:emit("screenShake")
        EventManager:emit("onCrit", entity1, entity2)
        EventManager:emit("onCrited", entity2, entity1)
        crit = true
    end

    if entity1.stats.current.lifeSteal > 0 then
        local lifeStealAmount = math.ceil(entity1.stats.current.lifeSteal * damage)
        EventManager:emit("registerTimer", entity1, 0.5, "lifeSteal", {entity = entity1, amount = lifeStealAmount})
    end

    -- account for def
    -- ensure minimum damage is always 1
    damage = math.floor(math.max(1, damage - entity2.stats.current.def))
    EventManager:emit("damageBubble", entity2, damage, crit)
    
    soundManager:playSound("hit3")
    EventManager:emit("playAnimation", entity2, "hit")

    EventManager:emit(
        "createParticle", 
        "hit", 
        entity2.position.screenX, 
        entity2.position.screenY, 
        math.max(3, math.floor(damage / 2))
    )
    
    entity2.stats.current.hp = math.max(0, entity2.stats.current.hp - damage)

    if entity2.stats.current.hp <= 0 then
        EventManager:emit("onKill", entity1)
        return true
    end

    return false
end

function combatSystem:taunt(attacker, target, atkReduction)
    EventManager:emit("playAnimation", attacker, "attack")
    local damage = attacker.stats.current.atk * (1 - atkReduction)
    self:hit(target, damage)
end

function combatSystem:dealDamage(entity, amount)
    if entity.stats then
        amount = math.max(1, math.floor(amount))
        entity.stats.current.hp = math.max(0, entity.stats.current.hp - amount)
        if entity.stats.current.hp <= 0 then
            EventManager:emit("setState", entity, "dying")
        end
    end
end

function combatSystem:hit(entity, amount)
    if entity.stats then
        amount = math.max(1, math.floor(amount))
        self:dealDamage(entity, amount)
        EventManager:emit("playAnimation", entity, "hit")
        EventManager:emit("damageBubble", entity, amount)
        soundManager:playSound("hit3")
        EventManager:emit(
            "createParticle", 
            "hit", 
            entity.position.screenX, 
            entity.position.screenY, 
            math.max(3, math.floor(amount / 2))
        )
    end
end


function combatSystem:isAlive(entity)
    if entity.stats.current.hp > 0 then
        return true
    end
    return false
end


function combatSystem:heal(entity, amount)
    if not entity.state.alive then
        return
    end

    if entity.stats.current.hp < entity.stats.current.maxHp then
        entity.stats.current.hp = math.min(entity.stats.current.hp + amount, entity.stats.current.maxHp)
        EventManager:emit("createParticle", "heal", entity.position.screenX, entity.position.screenY, amount * 4, "burst")
        soundManager:playSound("heal")
    end
end


function combatSystem:explode(entity, damage)
    EventManager:emit("playAnimation", entity, "trigger_death")
    SoundManager:playSound("explosion")
    local targets = gs.match.moveSystem:findInSquare(entity.position.x, entity.position.y, 3)

    for _, t in ipairs(targets) do
        self:hit(t, damage)
    end
end


function combatSystem:insideAttackPattern(attacker)
    
    local entities = {}
    for _, entity in ipairs(self.pool) do
        if entity.state.alive then
            local position = entity.position
            local pattern = attacker.stats.currentPatterns.atkPattern
            
            for y, row in ipairs(pattern) do
                for x, tile in ipairs(row) do
                    if tile == 1 then
                        local tileX = attacker.position.x - math.ceil(#pattern[1] / 2) + x
                        local tileY = attacker.position.y - math.ceil(#pattern / 2) + y
                        if position.x == tileX and position.y == tileY then
                            table.insert(entities, entity)
                        end
                    end
                end
            end
        end
    end
    
    return entities
end


function combatSystem:update(dt)
    for _, entity in ipairs(self.pool) do
    end
end


return combatSystem