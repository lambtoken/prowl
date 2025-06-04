local mold = require "libs.mold"
local generate_pattern = require "src.render.components.generate_pattern"

local function patterns(entityData)
    local c = mold.Container:new()
        :setWidth("auto")
        :setHeight("auto")
        -- :setDirection("row")

    local atk_container = mold.Container:new()
        :setWidth("auto")
        :setHeight("auto")
    local atk_text = mold.TextBox:new("attack pattern")
    atk_container:addChild(atk_text)
    atk_container:addChild(generate_pattern(entityData.atkPattern, "add"))

    local move_container = mold.Container:new()
        :setWidth("auto")
        :setHeight("auto")
    local mov_text = mold.TextBox:new("move pattern")
    move_container:addChild(mov_text)
    move_container:addChild(generate_pattern(entityData.movePattern, "add"))

    c:addChild(move_container)
    c:addChild(atk_container)
    return c
end

return patterns