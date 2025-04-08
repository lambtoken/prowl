local mold = require "libs.mold"
local RM = require("src.render.RenderManager"):getInstance()
local spriteTable = require "src.render.spriteTable"

local function new_stat(stat)
    local container = mold.Container:new()

    local key = mold.TextBox(stat)
        :setWidth("50%")
    local value = mold.TextBox(stat)
        :setWidth("50%")

    container:addChild(key)
    container:addChild(value)

    return container
end

local function new_stats(entity)

    local s = mold.Container:new()
    
    local col1 = mold.Container:new()
    local col2 = mold.Container:new()

    s:setWidth("500px")
    s:setHeight("500px")

    return s

end

-- name
-- hp: 20
-- atk: 2 def: 20
-- crit ls
-- pen luck

return new_stat