local mold = require "libs.mold"
local animal_stats = require "src.render.components.animal_stats"
local animal_pattern = require "src.render.components.animal_pattern"
local move_atk_pattern = require "src.render.components.move_atk_pattern"

return function(animalData)
    local c = mold.Container:new()
    c:setWidth("auto")
    c:setHeight("auto")
    c:setPosition("relative")
    c:setAlignContent("center")
    c.bgColor = {0, 0, 0, 0.8}

    if animalData.movePattern and animalData.atkPattern then
        local move_container = mold.Container:new()
            :setWidth("auto")
            :setHeight("auto")
            :setAlignContent("center")
        local mov_text = mold.TextBox:new("move pattern")
            :setColor(1, 1, 1, 1)
            :setSize(16)
        move_container:addChild(mov_text)
        move_container:addChild(move_atk_pattern(animalData.movePattern, "move"))

        local atk_container = mold.Container:new()
            :setWidth("auto")
            :setHeight("auto")
            :setAlignContent("center")
        local atk_text = mold.TextBox:new("attack pattern")
            :setColor(1, 1, 1, 1)
            :setSize(16)
        atk_container:addChild(atk_text)
        atk_container:addChild(move_atk_pattern(animalData.atkPattern, "atk"))

        c:addChild(move_container)
        c:addChild(atk_container)
    end

    c:addChild(animal_stats(animalData))
    return c
end