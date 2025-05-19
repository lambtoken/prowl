local mold = require "libs.mold"
local spriteTable = require "src.render.spriteTable"
local RM = require("src.render.RenderManager"):getInstance()

local SPRITE_SIZE = 7
local FIELD_SIZE = 28 -- SCREEN SIZE

local quads = {
    dot = {
        spriteTable["pattern_dots"][1] * RM.spriteSize, 
        spriteTable["pattern_dots"][2] * RM.spriteSize, 
    },
    remove = {
        spriteTable["pattern_remove"][1] * RM.spriteSize, 
        spriteTable["pattern_remove"][2] * RM.spriteSize, 
        RM.image
    },
    dir = {}
}

for i = 1, 3 do
    quads.dir[i] = {}
    for j = 1, 3 do
        if not (j == 2 and i == 2) then
            quads.dir[i][j] = {
                spriteTable["pattern_dir"][1] * RM.spriteSize + (j - 1) * SPRITE_SIZE, 
                spriteTable["pattern_dir"][2] * RM.spriteSize + (i - 1) * SPRITE_SIZE, 
            }
        end
    end
end

local function generate_pattern(pattern, pattern_type)
    local container = mold.Container:new()

    for y, row in ipairs(pattern) do
        local r = mold.Container:new()
        r:setDirection("row")
        r:setWidth("auto")
        r:setHeight("auto")
        -- r:debug()

        for x, cell in ipairs(row) do
            local c

            if cell == 1 then
                if pattern_type == "add" then
                    c = mold.QuadBox:new(RM.image, quads.dot[1], quads.dot[2], SPRITE_SIZE, SPRITE_SIZE)
                elseif pattern_type == "remove" then
                    c = mold.QuadBox:new(RM.image, quads.remove[1], quads.remove[2], SPRITE_SIZE, SPRITE_SIZE)
                elseif pattern_type == "extend" then
                    c = mold.QuadBox:new(RM.image, quads.dir[y][x][1], quads.dir[y][x][2], SPRITE_SIZE, SPRITE_SIZE)
                end
            else
                c = mold.Container:new()
            end

            c:setWidth(tostring(FIELD_SIZE) .. "px")
            c:setHeight(tostring(FIELD_SIZE) .. "px")

            r:addChild(c)
        end

        container:addChild(r)
    end

    container:setWidth("auto")
    container:setHeight("auto")

    return container
end

return generate_pattern