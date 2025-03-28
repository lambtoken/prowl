local Concord = require("libs.concord")
local gs = require('src.state.GameState'):getInstance()
local EffectFactory = require "src.run.EffectFactory"
local effects = {}

local buffDebuffSystem = Concord.system({pool = {position, stats, crowdControl, state}})

function buffDebuffSystem:update(dt)
    for _, entity in ipairs(self.pool) do
        return gs.currentMatch
    end
end

function buffDebuffSystem:applyEffect(entity, name)
    if entity.buffDebuffSystem and entity.buffDebuffSystem.effects then
        
    end
end

function buffDebuffSystem:newEffect(name, source, stats, duration)
    duration = duration or 1

    local e = {
        name = name or "untitled effect",
        source = source,
        stats = stats,
        duration = duration
    }

    return e

end

function buffDebuffSystem:applyStatEffect(entity, source, mod, value, target, duration)
    duration = duration or 1

    local effect = {
        source = source,
        sourceId = source.metadata.id,
        stats = {
            EffectFactory.newStat(mod, value, target),
        },
        duration = duration,
        turn = 0
    }

    table.insert(entity.buffDebuff.effects, effect)
end

function buffDebuffSystem:applyPatternEffect(entity, mod, value, target, duration)
    duration = duration or 1

    local effect = {
        stats = {
            EffectFactory.newPattern(mod, value, target)
        },
        duration = duration,
        turn = 0
    }

    table.insert(entity.buffDebuff.effects, effect)
end

function buffDebuffSystem:onStandBy()
    for _, entity in ipairs(self.pool) do

        local effects = entity.effect.effects

        for i = #effects, 1, -1  do
            local effect = effects[i]

            if not effect.duration then
                return
            end

            if effect.turn > effect.duration then
                -- if effects[effect.name].onExpire then
                --     effects[effect.name].onExpire(tag.entity)
                -- end

                table.remove(effects, i)
            else
                effect.turn = effect.turn + 1
            end
        end
    end
end

return buffDebuffSystem