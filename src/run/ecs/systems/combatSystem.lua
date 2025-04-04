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

local combatSystem = Concord.system({pool = {"position", "stats"}})

local function on(callback, matchState, entity, ...)
    if entity.metadata.type == 'animal' then
        local animal = mobData[entity.metadata.species]
        if animal.passive and animal.passive[callback] then
            animal.passive[callback](matchState, entity, ...)
        end
        if entity.inventory and entity.inventory.items then
            for _, item in ipairs(entity.inventory.items) do
                if item.passive and item.passive[callback] then
                    item.passive[callback](matchState, entity, ...)
                end
            end
        end
    end

    if entity.metadata.type == 'object' then
        local object = objectData[entity.metadata.objectName]
        if object.passive and object.passive[callback] then
            object.passive[callback](matchState, entity, ...)
        end
    end
end

-- helper function for calculating miss chance based on def value
local function defMissChance(attacker, target)
    local base = 0.1
    local atk = attacker.stats.current.atk
    local def = target.stats.current.def

    if atk == def then
        return base
    elseif atk < def then
        return base + ((def - atk) / 5 / (1 + math.abs(def - atk)) / 2)
    else
        return 0
    end
end

function combatSystem:init()
    -- EVENTS
    EventManager:on("onStep", function(entity, attack)
        local matchState = gs.currentMatch

        EventManager:emit("onStepAny", entity)

        if not attack then
            return
        end

        local entitiesToHit = self:insideAttackPattern(entity)
        
        if #entitiesToHit > 0 then

            local missed = false
            local succesfulAttack = false
            local succesfulAttackPassive = false
            local attemptedAttack = false
            local targetsKilled = {}            

            for _, target in ipairs(entitiesToHit) do
                
                missed = false
                attemptedAttack = false

                if entity.metadata.teamID ~= target.metadata.teamID and target.status.current.isTargetable then

                    if target.stats and target.state.current ~= "alive" then
                        goto continue
                    end
                        
                    local missChance = gs.run.rng:get('combat')
                    local luckDiff = target.stats.current.luck - entity.stats.current.luck

                    if luckDiff > missChance then
                        missed = true
                        EventManager:emit("onMiss", entity, target)
                        EventManager:emit("onDodge", target, entity)
                    end
                    
                    -- if defMissChance(entity, target) >= gs.run.rng:get('combat') then
                    --     missed = true
                    -- end

                    if not missed then
                        succesfulAttack = true
                        attemptedAttack = true
                        if self:attack(entity, target) then
                            table.insert(targetsKilled, target)
                        end
                    else
                        SoundManager:playSound("miss")
                        EventManager:emit("shortCCBubble", target, "Missed")            
                    end

                    ::continue::
                end
                
                -- onAttackAny
                -- onAttackedAny

                if entity.metadata.teamID == target.metadata.teamID then
                    return
                end
                    
                local entity1OnAttack
                local entity2OnAttacked
                
                if entity.metadata.type == 'animal' then
                    entity1OnAttack = mobData[entity.metadata.species]

                    for _, item in ipairs(entity.inventory.items) do
                        if item.passive and item.passive.onAttack then
                            item.passive.onAttack(matchState, entity, target)
                        end
                    end
                end

                if target.metadata.type == 'animal' then
                    entity2OnAttacked = mobData[target.metadata.species]
                elseif target.metadata.type == 'object' then
                    entity2OnAttacked = objectData[target.metadata.objectName]
                end

                if entity1OnAttack and entity1OnAttack.passive and entity1OnAttack.passive.onAttack then
                    succesfulAttackPassive = entity1OnAttack.passive.onAttack(matchState, entity, target) or succesfulAttackPassive
                end

                if entity2OnAttacked and entity2OnAttacked.passive and entity2OnAttacked.passive.onAttacked then
                    succesfulAttackPassive = entity2OnAttacked.passive.onAttacked(matchState, target, entity) or succesfulAttackPassive
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

        -- on step items
        for _, item in ipairs(entity.inventory.items) do
            if item.passive and item.passive.onStep then
                if itemData[item.name].passive and itemData[item.name].passive.onStep then
                    itemData[item.name].passive.onStep(matchState, entity)
                end
            end
        end
        
    end)

    EventManager:on("onStepAny", function(entity)
        local matchState = sceneManager.currentScene.currentMatch

        if entity.metadata.type == 'animal' then
            if entity.passive and entity.passive.onStepAny then
                entity.passive.onStepAny(matchState, entity)
            end
        end

        for _, item in ipairs(entity.inventory.items) do
            if item.passive and item.passive.onStepAny then
                item.passive.onStepAny(matchState, entity)
            end
        end
    end)

    EventManager:on("onHover", function(entity) 
        local matchState = sceneManager.currentScene.currentMatch

        local targets = matchState.moveSystem:findByCoordinates(entity.position.x, entity.position.y)
        
        EventManager:emit("onHoverAny", entity)
        
        if entity.metadata.type == 'animal' then
            for _, target in ipairs(targets) do
                if target == entity or target.state.current ~= "alive" then 
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
        local matchState = sceneManager.currentScene.currentMatch

        local targets = matchState.moveSystem:findByCoordinates(x, y)
        
        for _, target in ipairs(targets) do
            EventManager:emit("onHoveredAny", target)

            if target.metadata.type == 'object' then
                if target == entity or target.state.current ~= "alive" then
                    goto continue
                end
                local object = objectData[target.metadata.objectName]
                if object.passive and object.passive.onHovered then
                    object.passive.onHovered(matchState, target, entity)
                end                
            end

            if target.metadata.type == 'animal' then
                if target == entity and target.state.current ~= "alive" then
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
        on("onHoveredAny", gs.currentMatch, entity)
    end)

    EventManager:on("onHoverAny", function(entity)
        on("onHoverAny", gs.currentMatch, entity)
    end)

    EventManager:on("onMiss", function(entity, target)
        on("onMiss", gs.currentMatch, entity, target)
    end)

    EventManager:on("onDodge", function(entity, target)
        on("onDodge", gs.currentMatch, entity, target)
    end)

    EventManager:on("onKill", function(entity)
        on("onKill", gs.currentMatch, entity)
        on("onKillAny", gs.currentMatch, entity)
    end)

    EventManager:on("onCrit", function(entity)
        on("onCrit", gs.currentMatch, entity)
    end)

    EventManager:on("onCrited", function(entity)
        on("onCrited", gs.currentMatch, entity)
    end)
end


function combatSystem:attack(entity1, entity2)    
    local damage = entity1.stats.current.atk
    local crit = false

    --crit
    if entity1.stats.current.crit >= gs.run.rng:get('combat') then
        damage = damage * entity1.stats.current.critDamage
        EventManager:emit("screenShake")
        EventManager:emit("onCrit", entity1)
        EventManager:emit("onCrited", entity2)
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

function combatSystem:dealDamage(entity, amount)
    if entity.stats then
        entity.stats.current.hp = math.max(0, entity.stats.current.hp - amount)
        if entity.stats.current.hp <= 0 then
            EventManager:emit("setState", entity, "dying")
        end
    end
end

function combatSystem:hit(entity, amount)
    if entity.stats then
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
    if entity.stats.current.hp < entity.stats.current.maxHp then
        entity.stats.current.hp = math.min(entity.stats.current.hp + amount, entity.stats.current.maxHp)
        EventManager:emit("createParticle", "heal", entity.position.screenX, entity.position.screenY, amount)
        soundManager:playSound("heal")
    end
end


function combatSystem:explode(entity, damage)
    EventManager:emit("playAnimation", entity, "trigger_death")
    SoundManager:playSound("explosion")
    local targets = gs.currentMatch.moveSystem:findInSquare(entity.position.x, entity.position.y, 3)

    for _, t in ipairs(targets) do
        self:hit(t, damage)
    end
end


function combatSystem:insideAttackPattern(attacker)
    
    local entities = {}
    for _, entity in ipairs(self.pool) do
        if entity.state.current == "alive" then
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