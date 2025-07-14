local mold = require "libs.mold"
local animal_pattern = require "src.render.components.animal_pattern"
-- local RM = require("src.render.RenderManager"):getInstance()

-- name
-- passives
-- patterns

local function tooltip(entity)
    local c = mold.Container:new()
    c:setWidth("auto")
    c:setHeight("auto")
    c:setPos(0, 0)
    c:setPosition("absolute")
    c.bgColor = {0, 0, 0, 0.7}

    if entity.stats and entity.stats.currentPatterns then
        local atk_pattern = entity.stats.currentPatterns.atkPattern
        local mov_pattern = entity.stats.currentPatterns.movePattern
        if atk_pattern and mov_pattern then
            local ani_pattern = animal_pattern(entity.stats.currentPatterns)
            c:addChild(ani_pattern)
        end
    end

    return c
end

return tooltip