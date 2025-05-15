local Concord = require("libs.concord")
local gs = require('src.state.GameState'):getInstance()
local EventManager = require("src.state.events"):getInstance()
local SceneManager = require("src.scene.SceneManager"):getInstance()
local dotEffectData = require("src.run.combat.dotEffectData")
local soundManager = require("src.sound.SoundManager"):getInstance()
local damageOverTimeSystem = Concord.system({pool = {dot}})


function damageOverTimeSystem:giveDotEffect(entity, source, name, duration, stackable)
    assert(dotEffectData[name], "DoT effect: " .. name .. " does not exist.")
    
    if not entity.dot then
        return false
    end

    local dot = dotEffectData[name]

    stackable = stackable or dot.stackable or false

    if not stackable then
        for _, effect in ipairs(entity.dot.effects) do
            if effect.name == name and effect.source == source then
                effect.duration = effect.duration + duration
                return true
            end
        end
    end

    local damage = dot.baseDamage
    
    local effect = {
        name = name,
        source = source,
        damage = damage,
        duration = duration,
        turn = 1,
        bubbleId = nil
    }
    
    effect.bubbleId = SceneManager.currentScene.TextBubbleManager:newBubble("statusEffect", entity, dotEffectData[name].adjective)
    
    table.insert(entity.dot.effects, effect)

    return effect
end

function damageOverTimeSystem:update(dt)
    for _, entity in ipairs(self.pool) do
    end
end

function damageOverTimeSystem:onStandBy(teamId)
    for _, entity in ipairs(self.pool) do
        if not entity.stats then goto continue end

        if entity.state.current == "dead" or entity.state.current == "dying" then goto continue end

        if entity.metadata.teamId ~= teamId then goto continue end

        local effects = entity.dot.effects

        for i = #effects, 1, -1  do
            local effect = effects[i]

            if not effect.duration then
                goto continue_effect
            end
            
            if effect.damage and effect.damage > 0 then

                gs.match.combatSystem:dealDamage(entity, effect.damage)

                if SceneManager.currentScene.DamageNumbers then
                    SceneManager.currentScene.DamageNumbers:showNumber(
                        entity.position.screenX + 40,
                        entity.position.screenY + 20,
                        effect.damage,
                        {1, 0, 0}
                    )
                end
                
                EventManager:emit("playAnimation", entity, "hit")
                soundManager:playSound("hit2")
                -- soundManager:playSound(dotEffectData[effect.name].sound)
                
            end
            
            if effect.turn >= effect.duration then
                SceneManager.currentScene.TextBubbleManager:endStatusEffect(effect.bubbleId)
                table.remove(effects, i)
            else
                effect.turn = effect.turn + 1
            end
            
            ::continue_effect::
        end
        
        ::continue::
    end
end

function damageOverTimeSystem:removeAll(animal)
    animal.dot.effects = {}
end

return damageOverTimeSystem