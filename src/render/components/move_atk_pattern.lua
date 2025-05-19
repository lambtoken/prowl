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

    for _, row in ipairs(pattern) do
        local r = mold.Container:new()
        r:setDirection("row")
        r:setWidth("auto")
        r:setHeight("auto")

        for _, cell in ipairs(row) do
            local c
            
            if cell == 1 then
                c = portrait(sprite)
            else
                c = mold.Container:new()
            end

            -- c:debug()

            c:setWidth("50px")
            c:setHeight("50px")
            c:playAnimation("rand_wave", true)
            
            r:addChild(c)
        end

        container:addChild(r)
    end

    container:setWidth("auto")
    container:setHeight("auto")

    return container
end

return generate_pattern