local mold = require "libs.mold"
local new_stats = require "src.render.components.tiny_stats"
local new_pattern = require "src.render.components.tiny_pattern"
local items = require "src.generation.items"

local function item_details(name)
    local item = items[name]

    local c = mold.Container:new()
    c:setDirection("row")
    c:setWidth("auto")
    c:setHeight("auto")
    c.bgColor = {0, 0, 0, 1}

    local name = mold.TextBox:new(item.name)
        :setSize(20)
        :debug()

    name.color = {1, 1, 1, 1}
    
    -- c:addChild(name)

    -- item description or passive descriptions missing rn

    if #item.stats > 0 then
        c:addChild(new_stats(item.stats))
    end

    for _, p in ipairs(item.pattern) do
        c:addChild(new_pattern(p))
    end

    c:resize()
    return c
end

return item_details