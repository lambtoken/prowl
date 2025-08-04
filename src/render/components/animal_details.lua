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

    if animalData.passive and animalData.passive.description then
        local passive_container = mold.Container:new()
            :setWidth("auto")
            :setHeight("auto")
            :setAlignContent("center")
            :setMargin("10px", "bottom")

        passive_container.bgColor = {0.2, 0.2, 0.2, 0.8}
        
        local passive_title = mold.TextBox:new("Passive Ability")
            :setColor(1, 1, 0.8, 1)  
            :setSize(22)
            :setMargin("5px", "bottom")
        
        local passive_desc = mold.TextBox:new(animalData.passive.description)
            :setColor(0.9, 0.9, 0.9, 1)  
            :setSize(18)
        
        passive_container:addChild(passive_title)
        passive_container:addChild(passive_desc)
        c:addChild(passive_container)
    end

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