local mold = require "libs.mold"
local RM = require("src.render.RenderManager"):getInstance()
local spriteTable = require "src.render.spriteTable"

local function new_portrait(entity_name)

    local p = mold.QuadBox:new(RM.image, spriteTable[entity_name][1] * RM.spriteSize, spriteTable[entity_name][2] * RM.spriteSize, RM.spriteSize, RM.spriteSize)
    p:setWidth("100px")
    p:setHeight("100px")

    return p

end

return new_portrait