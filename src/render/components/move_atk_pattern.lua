local mold = require "libs.mold"
local portrait = require "src.render.components.portrait"

local function generate_pattern(pattern, kind)

    local sprite

    if kind == "atk" then
        sprite = "attackMark"
    elseif kind == "move" then
        sprite = "moveMark"
    end

    local container = mold.Container:new()

    container:setMode("squish")
    for _, row in ipairs(pattern) do
        local r = mold.Container:new()
        r:setDirection("row")
        r:setWidth("100%")
        r:setHeight("100%")

        for _, cell in ipairs(row) do
            local c
            
            if cell == 1 then
                c = portrait(sprite)
                c:setScaleBy("width")
            else
                c = mold.Container:new()
            end

            -- c:debug()

            c:setWidth("100%")
            c:setHeight("100%")
            c:playAnimation("rand_wave", true)
            
            r:addChild(c)
        end

        container:addChild(r)
    end

    container:setWidth("256px")
    container:setHeight("256px")

    return container
end

return generate_pattern