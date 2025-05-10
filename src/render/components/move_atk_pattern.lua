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

    for index, row in ipairs(pattern) do
        local r = mold.Container:new()
        r:setDirection("row")
        r:setWidth("auto")
        r:setHeight("auto")
        r:debug()

        for index, cell in ipairs(row) do
            local c
            
            if cell == 1 then
                c = portrait(sprite)
            else
                c = mold.Container:new()
            end

            -- c:debug()

            c:setWidth("50px")
            c:setHeight("50px")
            
            r:addChild(c)
        end

        container:addChild(r)
    end

    container:setWidth("auto")
    container:setHeight("auto")

    return container
end

-- pattern is a 2d matrix of 0s and 1s
-- local function new_atk_mov(mov_pattern, atk_pattern)
--     local p = mold.Container:new()
--         :setWidth("100px")
--         :setHeight("100px")

--     local mov_p = generate_pattern(mov_pattern, "mov")
--         -- :setPosition("fixed")
--         :setPos(1, 1)
--         :setWidth("100px")
--         :setHeight("100px")
    
--     local atk_p = generate_pattern(mov_pattern, "atk")
--         :setPosition("fixed")
--         :setWidth("auto")
--         :setHeight("auto")

--     p:addChild(mov_p)

--     return mov_p
-- end

return generate_pattern