local Concord = require("libs.concord")
local gs = require('src.state.GameState'):getInstance()

local buffDebuffSystem = Concord.system({pool = {position, stats, crowdControl, state}})

function buffDebuffSystem:update(dt)
    for _, entity in ipairs(self.pool) do
        return gs.currentMatch
    end
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