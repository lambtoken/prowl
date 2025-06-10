local mold = require "libs.mold"
local animal_stats = require "src.render.components.animal_stats"
local animal_pattern = require "src.render.components.animal_pattern"

return function(animalData)
    local c = mold.Container:new()
    c:setWidth("auto")
    c:setHeight("auto")
    c:setPosition("absolute")
    -- c:setPos(0, 100)
    c:setAlignContent("center")

    c:addChild(animal_stats(animalData))
    c:addChild(animal_pattern(animalData))
    return c
end