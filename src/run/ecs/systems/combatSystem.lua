local Concord = require("libs.concord")
local gs = require('src.state.GameState'):getInstance()
local sceneManager = require('src.scene.SceneManager'):getInstance()
local soundManager = require('src.sound.SoundManager'):getInstance()
local EventManager = require('src.state.events'):getInstance()
local pretty       = require('libs.batteries.pretty')
local mobData = require "src.generation.mobs"
local objectData = require "src.generation.objects"
local SoundManager = require("src.sound.SoundManager"):getInstance()

local combatSystem = Concord.system({pool = {position}})

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
        local matchState = sceneManager.currentScene.currentMatch

        if not attack then
            return
        end

        local entitiesToHit = self:insideAttackPattern(entity)
        
        if #entitiesToHit > 0 then

            local missed = false
            local succesfulAttack = false
            local succesfulAttackPassive = false
            local attemptedAttack = false
            
            for _, target in ipairs(entitiesToHit) do
                
                missed = false
                attemptedAttack = false

                if entity.metadata.teamID ~= target.metadata.teamID and target.status.current.isTargetable then

                    if target.stats and target.state.current == "alive" then
                        
                        local missChance = gs.run.rng:get('combat')

                        if (target.stats.current.luck - entity.stats.current.luck) > missChance then
                            print("target luck: ", target.stats.current.luck)
                            print("atker luck: ", entity.stats.current.luck)
                            missed = true
                        end
                        
                        -- if defMissChance(entity, target) >= gs.run.rng:get('combat') then
                        --     missed = true
                        -- end

                        if not missed then
                            succesfulAttack = true
                            attemptedAttack = true
                            self:attack(entity, target)
                        else
                            SoundManager:playSound("miss")
                            EventManager:emit("shortCCBubble", target, "Missed")            
                        end

                    end 
                end
                
                
                if entity.metadata.teamID ~= target.metadata.teamID then
                    
                    local entity1OnAttack
                    local entity2OnAttacked
                    
                    if entity.metadata.type == 'animal' then
                        entity1OnAttack = mobData[entity.metadata.species]

                        for _, item in ipairs(entity.inventory.items) do
                            if item.passive and item.passive.onAttack then
                                print("item registered")
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
                        print("attack registered")
                        succesfulAttackPassive = entity1OnAttack.passive.onAttack(matchState, entity, target) or succesfulAttackPassive
                    end

                    if entity2OnAttacked and entity2OnAttacked.passive and entity2OnAttacked.passive.onAttacked then
                        succesfulAttackPassive = entity2OnAttacked.passive.onAttacked(matchState, target, entity) or succesfulAttackPassive
                    end
                    
                end
            end

            if succesfulAttack or succesfulAttackPassive or missed then
                EventManager:emit("playAnimation", entity, "attack")
            end
        end
         
    end)


    EventManager:on("onHover", function(entity) 
        local matchState = sceneManager.currentScene.currentMatch

        local targets = matchState.moveSystem:findByCoordinates(entity.position.x, entity.position.y)
        
        if entity.metadata.type == 'animal' then
            for _, target in ipairs(targets) do
                if target ~= entity and target.state.current == "alive" then
                    local mob = mobData[entity.metadata.species]
                    if mob.passive and mob.passive.onHover then
                        mob.passive.onHover(matchState, target, entity)
                    end

                    for _, item in ipairs(entity.inventory.items) do
                        if item.passive and item.passive.onHover then
                            item.passive.onHover(matchState, target, entity)
                        end
                    end
                end
            end
        end
    end)


    EventManager:on("onHovered", function(entity, x, y) 
        local matchState = sceneManager.currentScene.currentMatch

        local targets = matchState.moveSystem:findByCoordinates(x, y)
        
        for _, target in ipairs(targets) do
            if target.metadata.type == 'object' then
                if target ~= entity and target.state.current == "alive" then
                    local object = objectData[target.metadata.objectName]
                    if object.passive and object.passive.onHovered then
                        object.passive.onHovered(matchState, target, entity)
                    end

                    -- iteam idea. heal on hovered
                    -- for _, item in ipairs(entity.inventory.items) do
                    --     if item.passive and item.passive.onHover then
                    --         item.passive.onHover(matchState, target, entity)
                    --     end
                    -- end
                end
            end
        end
    end)

end


function combatSystem:attack(entity1, entity2)    
    local damage = entity1.stats.current.atk
    local crit = false

    --crit
    if entity1.stats.current.crit >= gs.run.rng:get('combat') then
        damage = damage * entity1.stats.current.critDamage
        EventManager:emit("screenShake")
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
        EventManager:emit("setState", entity2, "dying")
    end

end

function combatSystem:dealDamage(entity, amount)
    if entity.stats then
        entity.stats.current.hp = math.max(0, entity.stats.current.hp - amount)
        if entity.stats.current.hp <= 0 then
            EventManager:emit("setState", entity, "dying")
        end
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
        self:dealDamage(t, damage)
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