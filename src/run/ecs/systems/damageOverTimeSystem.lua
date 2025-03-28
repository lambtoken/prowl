local Concord = require("libs.concord")
local gs = require('src.state.GameState'):getInstance()

local damageOverTimeSystem = Concord.system({pool = {dot}})

function damageOverTimeSystem:update(dt)
    for _, entity in ipairs(self.pool) do

    end
end

function damageOverTimeSystem:onStandBy()
    for _, entity in ipairs(self.pool) do

        local effects = entity.dot.effects

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

return damageOverTimeSystem