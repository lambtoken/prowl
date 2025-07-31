local Concord = require("libs.concord")
local gs = require('src.state.GameState'):getInstance()
local EffectFactory = require "src.run.EffectFactory"
local buffDebuffData = require("src.run.combat.buffDebuffData")

local buffDebuffSystem = Concord.system({pool = {buffDebuff}})

function buffDebuffSystem:update(dt)
    for _, entity in ipairs(self.pool) do
        return gs.match
    end
end

function buffDebuffSystem:applyEffect(entity, name, source)
    if entity.buffDebuff and entity.buffDebuff.effects then
        local data = buffDebuffData[name]
        if data then
            self:applyStatEffect(entity, source, data.stats, data.duration)
        end
    end
end

function buffDebuffSystem:applyStatEffect(entity, source, stats, duration, sourceItemId)
    if not entity.buffDebuff then return end
    
    duration = duration or 1

    local effect = {
        source = source,
        sourceId = source.metadata.id,
        stats = stats,
        duration = duration,
        turn = 0
    }
    
    -- If this effect comes from an item, track its item ID
    if sourceItemId then
        effect.sourceItemId = sourceItemId
    elseif source and source.passive and source.passive.itemId then
        effect.sourceItemId = source.passive.itemId
    end

    table.insert(entity.buffDebuff.effects, effect)
    return effect
end

function buffDebuffSystem:applyPatternEffect(entity, pattern, duration, sourceItemId)
    duration = duration or 1

    local effect = {
        pattern = pattern,
        duration = duration,
        turn = 0
    }
    
    -- If this effect comes from an item, track its item ID
    if sourceItemId then
        effect.sourceItemId = sourceItemId
    end

    table.insert(entity.buffDebuff.effects, effect)
    return effect
end

-- Find and remove effects from a specific item
function buffDebuffSystem:removeEffectsByItemId(entity, itemId)
    if not entity.buffDebuff or not entity.buffDebuff.effects then
        return
    end
    
    local effects = entity.buffDebuff.effects
    for i = #effects, 1, -1 do
        if effects[i].sourceItemId == itemId then
            table.remove(effects, i)
        end
    end
end

-- Update or replace an existing effect from an item
function buffDebuffSystem:updateItemEffect(entity, itemId, stats, duration)
    -- First remove any existing effects from this item
    self:removeEffectsByItemId(entity, itemId)
    
    -- Then apply the new effect
    return self:applyStatEffect(entity, entity, stats, duration, itemId)
end

function buffDebuffSystem:onStandBy(teamId)
    for _, entity in ipairs(self.pool) do
        if entity.team and entity.team.teamId ~= teamId
        or not entity.buffDebuff then
            goto continue
        end

        local effects = entity.buffDebuff.effects

        for i = #effects, 1, -1  do
            local effect = effects[i]

            if not effect.duration then
                goto continue_effect
            end

            if effect.turn >= effect.duration then
                if effect.onExpire then
                    effect.onExpire(entity)
                end

                table.remove(effects, i)
                -- print("removed effect", effect.name)
            else
                effect.turn = effect.turn + 1
            end
            
            ::continue_effect::
        end
        ::continue::
    end
end

function buffDebuffSystem:removeAll(animal)
    animal.buffDebuff.effects = {}
end

return buffDebuffSystem