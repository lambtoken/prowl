local mold = require "libs.mold"
local animal_stats = require "src.render.components.animal_stats"
local animal_pattern = require "src.render.components.animal_pattern"

return function(animalData)
    local c = mold.Container:new()
    c:setWidth("auto")
    c:setHeight("auto")
    c:setPosition("absolute")

    c:addChild(animal_stats(animalData))
    c:addChild(animal_pattern(animalData))
    return c
end