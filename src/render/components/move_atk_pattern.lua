local mold = require "libs.mold"
local portrait = require "src.render.components.portrait"

local function generate_pattern(pattern, kind)

    local sprite

    if kind == "attack" then
        sprite = "attack_mark"
    elseif kind == "move" then
        sprite = "move_mark"
    end

    local container = mold.Container:new()

    for index, row in ipairs(pattern) do
        local row = mold.Container:new()
        container:addChild(row)

        for index, cell in ipairs(row) do
            local c = portrait(kind)
            
            row:addChild(c)
        end
    end

    return container
end

-- pattern is a 2d matrix of 0s and 1s
local function new_atk_mov(mov_pattern, atk_pattern)
    local p = mold.Container:new()
        :setWidth("100px")
        :setHeight("100px")

    local mov_p = generate_pattern(mov_pattern, "mov")
        :setPosition("fixed")
        :setWidth("auto")
        :setHeight("auto")
    
    local atk_p = generate_pattern(mov_pattern, "atk")
        :setPosition("fixed")
        :setWidth("auto")
        :setHeight("auto")

    return p
end
