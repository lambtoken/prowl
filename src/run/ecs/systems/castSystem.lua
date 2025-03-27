local Concord = require("libs.concord")
local callbackRegistry = {
    abc = function() end
}

local castSystem = Concord.system({pool = {cast, state, effect}})

function castSystem:update(dt)
    for _, entity in ipairs(self.pool) do
        for _, cast in ipairs(self.casts) do
            cast.elapsed_time = cast.elapsed_time + dt
    
            if cast.elapsed_time >= cast.cast_time then
                self:completeCast(cast)
            end
        end
    end
end

function castSystem:newCast(entity, on_complete, cast_time, data, unstoppable)

    local new_cast = {
        unstoppable = unstoppable,
        on_complete = on_complete,
        cast_time = cast_time,
        elapsed_time = 0,
        data = data
    }

    table.insert(entity.cast.casts, new_cast)

end

function castSystem:stopCasting(entity)
    entity.cast.casts = {}
end

function castSystem:completeCast(cast)
    callbackRegistry[cast.type](cast.data)
end

return castSystem